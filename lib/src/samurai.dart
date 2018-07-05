import 'dart:async';
import 'package:parsejs/parsejs.dart';
import 'package:symbol_table/symbol_table.dart';
import 'array.dart';
import 'arguments.dart';
import 'function.dart';
import 'literal.dart';
import 'object.dart';
import 'stack.dart';
import 'util.dart';

class Samurai {
  final List<Completer> awaiting = <Completer>[];
  final CallStack callStack = new CallStack();
  final SymbolTable<JsObject> scope = new SymbolTable();
  final JsObject global = new JsObject();

  Samurai() {
    var printFunction = new JsFunction(
      global,
      (samurai, arguments, scope) {
        arguments.valueOf.forEach(print);
      },
    );

    global.properties['print'] = printFunction
      ..properties['name'] = new JsString('print');

    scope
      ..context = global
      ..create('global', value: global);
  }

  JsObject visitProgram(Program node) {
    callStack.push(node.filename, node.line, '<entry>');

    // TODO: Hoist functions, declarations into global scope.
    JsObject out;

    for (var stmt in node.body) {
      callStack.push(stmt.filename, stmt.line, '<entry>');
      var result = visitStatement(stmt, scope, '<entry>');

      if (stmt is ExpressionStatement) {
        out = result;
      }

      callStack.pop();
    }

    callStack.pop();
    return out;
  }

  JsObject visitStatement(
      Statement node, SymbolTable<JsObject> scope, String stackName) {
    if (node is ExpressionStatement) {
      return visitExpression(node.expression, scope);
    }

    if (node is ReturnStatement) {
      return visitExpression(node.argument, scope);
    }

    if (node is BlockStatement) {
      for (var stmt in node.body) {
        callStack.push(stmt.filename, stmt.line, stackName);
        var result = visitStatement(stmt, scope.createChild(), stackName);

        if (stmt is ReturnStatement) {
          callStack.pop();
          return result;
        }
      }

      callStack.pop();
      return null;
    }

    if (node is VariableDeclaration) {
      for (var decl in node.declarations) {
        // TODO: What if it already exists?
        scope.create(decl.name.value, value: visitExpression(decl.init, scope));
      }

      return null;
    }

    if (node is FunctionDeclaration) {
      return visitFunctionNode(node.function, scope);
    }

    throw callStack.error('Unsupported', node.runtimeType.toString());
  }

  JsObject visitExpression(Expression node, SymbolTable<JsObject> scope) {
    if (node is NameExpression) {
      if (node.name.value == 'undefined') {
        return null;
      }

      var ref = scope.resolve(node.name.value)?.value ??
          scope.context.properties[node.name.value];

      if (ref == null) {
        throw callStack.error(
            'Reference', '${node.name.value} is not defined.');
      }

      return ref;
    }

    if (node is MemberExpression) {
      var target = visitExpression(node.object, scope);
      return target?.getProperty(node.property.value);
    }

    if (node is ThisExpression) {
      return scope.context;
    }

    if (node is ObjectExpression) {
      var props = {};

      for (var prop in node.properties) {
        props[prop.nameString] = visitExpression(prop.expression, scope);
      }

      return new JsObject()..properties.addAll(props);
    }

    if (node is LiteralExpression) {
      if (node.isBool) {
        return new JsBoolean(node.boolValue);
      } else if (node.isString) {
        return new JsString(node.stringValue);
      } else if (node.isNumber) {
        return new JsNumber(node.numberValue);
      } else if (node.isNull) {
        return new JsNull();
      }
    }

    if (node is ConditionalExpression) {
      var condition = visitExpression(node.condition, scope);
      return condition.isTruthy
          ? visitExpression(node.then, scope)
          : visitExpression(node.otherwise, scope);
    }

    if (node is IndexExpression) {
      var target = visitExpression(node.object, scope);
      var index = visitExpression(node.property, scope);
      return target.properties[index.valueOf];
    }

    if (node is CallExpression) {
      var target = visitExpression(node.callee, scope);

      if (target is JsFunction) {
        var arguments = new JsArguments(
            node.arguments.map((e) => visitExpression(e, scope)).toList(),
            target);

        var childScope = (target.closureScope ?? scope);
        childScope = childScope.createChild(values: {'arguments': arguments});
        childScope.context = target.context ?? scope.context;

        JsObject result;

        if (target.declaration != null) {
          callStack.push(target.declaration.filename, target.declaration.line,
              target.name);
        }

        if (node.isNew) {
          result = target.newInstance();
          target.f(this, arguments, childScope..context = result);
        } else {
          result = target.f(this, arguments, childScope);
        }

        if (target.declaration != null) {
          callStack.pop();
        }

        return result;
      } else {
        if (node.isNew) {
          throw callStack.error(
              'Type',
              '${target?.valueOf ??
                  'undefined'} is not a constructor.');
        } else {
          throw callStack.error(
              'Type',
              '${target?.valueOf ??
                  'undefined'} is not a function.');
        }
      }
    }

    if (node is FunctionExpression) {
      return visitFunctionNode(node.function, scope);
    }

    if (node is ArrayExpression) {
      var items = node.expressions.map((e) => visitExpression(e, scope));
      return new JsArray()..valueOf.addAll(items);
    }

    if (node is BinaryExpression) {
      var left = visitExpression(node.left, scope);
      var right = visitExpression(node.right, scope);
      return performBinaryOperation(node.operator, left, right);
    }

    if (node is AssignmentExpression) {
      var l = node.left;

      if (l is NameExpression) {
        if (node.operator == '=') {
          return scope
              .assign(l.name.value, visitExpression(node.right, scope))
              .value;
        } else {
          var trimmedOp = node.operator.substring(0, node.operator.length - 1);
          return scope
              .assign(
                l.name.value,
                performNumericalBinaryOperation(
                  trimmedOp,
                  visitExpression(l, scope),
                  visitExpression(node.right, scope),
                ),
              )
              .value;
        }
      } else if (l is MemberExpression) {
        var left = visitExpression(l.object, scope);

        if (node.operator == '=') {
          return left.setProperty(
              l.property.value, visitExpression(node.right, scope));
        } else {
          var trimmedOp = node.operator.substring(0, node.operator.length - 1);
          return left.setProperty(
            l.property.value,
            performNumericalBinaryOperation(
              trimmedOp,
              left.getProperty(l.property.value),
              visitExpression(node.right, scope),
            ),
          );
        }
      } else {
        throw callStack.error(
            'Reference', 'Invalid left-hand side in assignment');
      }
    }

    if (node is SequenceExpression) {
      return node.expressions.map((e) => visitExpression(e, scope)).last;
    }

    throw callStack.error('Unsupported', node.runtimeType.toString());
  }

  JsObject performBinaryOperation(String op, JsObject left, JsObject right) {
    // TODO: May be: ==, !=, ===, !==, in, instanceof
    if (op == '==') {
      // TODO: Loose equality
      throw new UnimplementedError('== operator');
    } else if (op == '===') {
      // TODO: Override operator
      return new JsBoolean(left == right);
    } else if (op == '&&') {
      return !left.isTruthy ? left : right;
    } else if (op == '||') {
      return left.isTruthy ? left : right;
    } else if (op == '<') {
      return safeBooleanOperation(left, right, (l, r) => l < r);
    } else if (op == '<=') {
      return safeBooleanOperation(left, right, (l, r) => l <= r);
    } else if (op == '>') {
      return safeBooleanOperation(left, right, (l, r) => l > r);
    } else if (op == '>=') {
      return safeBooleanOperation(left, right, (l, r) => l >= r);
    } else {
      return performNumericalBinaryOperation(op, left, right);
    }
  }

  JsObject performNumericalBinaryOperation(
      String op, JsObject left, JsObject right) {
    if (op == '+' && (!canCoerceToNumber(left) || !canCoerceToNumber(right))) {
      // TODO: Append string...
      return new JsString(left.toString() + right.toString());
    } else {
      var l = coerceToNumber(left);
      var r = coerceToNumber(right);

      if (l.isNaN || r.isNaN) {
        return new JsNumber(double.nan);
      }

      // =, +=, -=, *=, /=, %=, <<=, >>=, >>>=, |=, ^=, &=
      switch (op) {
        case '+':
          return new JsNumber(l + r);
        case '-':
          return new JsNumber(l - r);
        case '*':
          return new JsNumber(l * r);
        case '/':
          return new JsNumber(l / r);
        case '%':
          return new JsNumber(l % r);
        case '<<':
          return new JsNumber(l.toInt() << r.toInt());
        case '>>':
          return new JsNumber(l.toInt() >> r.toInt());
        case '>>>':
          // TODO: Is a zero-filled right shift relevant with Dart?
          return new JsNumber(l.toInt() >> r.toInt());
        case '|':
          return new JsNumber(l.toInt() | r.toInt());
        case '^':
          return new JsNumber(l.toInt() ^ r.toInt());
        case '&':
          return new JsNumber(l.toInt() & r.toInt());
        default:
          throw new ArgumentError();
      }
    }
  }

  JsObject visitFunctionNode(FunctionNode node, SymbolTable<JsObject> scope) {
    JsFunction function;
    function = new JsFunction(scope.context, (samurai, arguments, scope) {
      for (double i = 0.0; i < node.params.length; i++) {
        scope.create(node.params[i.toInt()].value,
            value: arguments.properties[i]);
      }

      return visitStatement(node.body, scope, function.name);
    });
    function.declaration = node;
    function.properties['length'] = new JsNumber(node.params.length);
    function.properties['name'] = new JsString(node.name?.value ?? 'anonymous');

    // TODO: What about hoisting???
    if (node.name != null) {
      scope.create(node.name.value, value: function, constant: true);
    }

    function.closureScope = scope.fork();
    return function;
  }
}
