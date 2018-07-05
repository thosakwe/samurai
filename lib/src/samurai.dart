import 'dart:async';
import 'package:parsejs/parsejs.dart';
import 'package:symbol_table/symbol_table.dart';
import 'array.dart';
import 'arguments.dart';
import 'context.dart';
import 'function.dart';
import 'literal.dart';
import 'object.dart';
import 'stack.dart';
import 'util.dart';

class Samurai {
  final List<Completer> awaiting = <Completer>[];
  final SymbolTable<JsObject> globalScope = new SymbolTable();
  final JsObject global = new JsObject();

  Samurai() {
    var decodeUriFunction = new JsFunction(global, (samurai, arguments, __) {
      try {
        return new JsString(
            Uri.decodeFull(arguments.getProperty(0.0)?.toString()));
      } catch (_) {
        return arguments.getProperty(0.0);
      }
    });

    var decodeUriComponentFunction =
        new JsFunction(global, (samurai, arguments, __) {
      try {
        return new JsString(
            Uri.decodeComponent(arguments.getProperty(0.0)?.toString()));
      } catch (_) {
        return arguments.getProperty(0.0);
      }
    });
    var encodeUriFunction = new JsFunction(global, (samurai, arguments, __) {
      try {
        return new JsString(
            Uri.encodeFull(arguments.getProperty(0.0)?.toString()));
      } catch (_) {
        return arguments.getProperty(0.0);
      }
    });

    var encodeUriComponentFunction =
        new JsFunction(global, (samurai, arguments, __) {
      try {
        return new JsString(
            Uri.encodeComponent(arguments.getProperty(0.0)?.toString()));
      } catch (_) {
        return arguments.getProperty(0.0);
      }
    });

    var evalFunction = new JsFunction(global, (_, arguments, ctx) {
      var src = arguments.getProperty(0.0)?.toString();
      if (src == null || src.trim().isEmpty) return null;

      try {
        var program = parsejs(src, filename: 'eval');
        return visitProgram(program, 'eval');
      } on ParseError catch (e) {
        throw ctx.callStack.error('Syntax', e.message);
      }
    });

    var isFinite = new JsFunction(global, (_, arguments, ctx) {
      return new JsBoolean(
          coerceToNumber(arguments.getProperty(0.0), this, ctx).isFinite);
    });

    var isNaN = new JsFunction(global, (_, arguments, ctx) {
      return new JsBoolean(
          coerceToNumber(arguments.getProperty(0.0), this, ctx).isNaN);
    });

    var parseFloatFunction = new JsFunction(global, (_, arguments, __) {
      var str = arguments.getProperty(0.0)?.toString();
      var v = str == null ? null : double.tryParse(str);
      return v == null ? null : new JsNumber(v);
    });

    var parseIntFunction = new JsFunction(global, (_, arguments, __) {
      var str = arguments.getProperty(0.0)?.toString();
      var baseArg = arguments.getProperty(1.0);
      var base = baseArg == null ? 10 : int.tryParse(baseArg.toString());
      if (base == null) return new JsNumber(double.nan);
      var v = str == null
          ? null
          : int.tryParse(str.replaceAll(new RegExp(r'^0x'), ''), radix: base);
      return v == null ? new JsNumber(double.nan) : new JsNumber(v);
    });

    var printFunction = new JsFunction(
      global,
      (samurai, arguments, scope) {
        arguments.valueOf.forEach(print);
      },
    );

    global.properties.addAll({
      'decodeURI': decodeUriFunction..name = 'decodeURI',
      'decodeURIComponent': decodeUriComponentFunction
        ..name = 'decodeURIComponent',
      'encodeURI': encodeUriFunction..name = 'encodeURI',
      'encodeURIComponent': encodeUriComponentFunction
        ..name = 'encodeURIComponent',
      'eval': evalFunction..name = 'eval',
      'Infinity': new JsNumber(double.infinity),
      'isFinite': isFinite..name = 'isFinite',
      'isNaN': isNaN..name = 'isNaN',
      'NaN': new JsNumber(double.nan),
      'parseFloat': parseFloatFunction..name = 'parseFloat',
      'parseInt': parseIntFunction..name = 'parseInt',
      'print': printFunction..properties['name'] = new JsString('print'),
    });

    globalScope
      ..context = global
      ..create('global', value: global);
  }

  JsObject visitProgram(Program node, [String stackName = '<entry>']) {
    var callStack = new CallStack();
    var ctx = new SamuraiContext(globalScope, callStack);
    callStack.push(node.filename, node.line, stackName);

    // TODO: Hoist functions, declarations into global scope.
    JsObject out;

    for (var stmt in node.body) {
      callStack.push(stmt.filename, stmt.line, stackName);
      var result = visitStatement(stmt, ctx, stackName);

      if (stmt is ExpressionStatement) {
        out = result;
      }

      callStack.pop();
    }

    callStack.pop();
    return out;
  }

  JsObject visitStatement(
      Statement node, SamuraiContext ctx, String stackName) {
    var scope = ctx.scope;
    var callStack = ctx.callStack;

    if (node is ExpressionStatement) {
      return visitExpression(node.expression, ctx);
    }

    if (node is ReturnStatement) {
      return visitExpression(node.argument, ctx);
    }

    if (node is BlockStatement) {
      for (var stmt in node.body) {
        callStack.push(stmt.filename, stmt.line, stackName);
        var result = visitStatement(stmt, ctx.createChild(), stackName);

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
        Variable<JsObject> symbol;
        var value = visitExpression(decl.init, ctx);

        try {
          symbol = scope.create(decl.name.value, value: value);
        } on StateError {
          symbol = scope.assign(decl.name.value, value);
        }

        if (value is JsFunction && value.isAnonymous && symbol != null) {
          value.properties['name'] = new JsString(symbol.name);
        }
      }

      return null;
    }

    if (node is FunctionDeclaration) {
      return visitFunctionNode(node.function, ctx);
    }

    throw callStack.error('Unsupported', node.runtimeType.toString());
  }

  JsObject visitExpression(Expression node, SamuraiContext ctx) {
    var scope = ctx.scope;
    var callStack = ctx.callStack;

    if (node is NameExpression) {
      if (node.name.value == 'undefined') {
        return null;
      }

      var ref = scope.resolve(node.name.value)?.value ??
          global.properties[node.name.value];

      if (ref == null) {
        throw callStack.error(
            'Reference', '${node.name.value} is not defined.');
      }

      return ref;
    }

    if (node is MemberExpression) {
      var target = visitExpression(node.object, ctx);
      return target?.getProperty(node.property.value);
    }

    if (node is ThisExpression) {
      return scope.context;
    }

    if (node is ObjectExpression) {
      var props = {};

      for (var prop in node.properties) {
        props[prop.nameString] = visitExpression(prop.expression, ctx);
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
      var condition = visitExpression(node.condition, ctx);
      return (condition?.isTruthy == true)
          ? visitExpression(node.then, ctx)
          : visitExpression(node.otherwise, ctx);
    }

    if (node is IndexExpression) {
      var target = visitExpression(node.object, ctx);
      var index = visitExpression(node.property, ctx);
      return target.properties[index.valueOf];
    }

    if (node is CallExpression) {
      var target = visitExpression(node.callee, ctx);

      if (target is JsFunction) {
        var arguments = new JsArguments(
            node.arguments.map((e) => visitExpression(e, ctx)).toList(),
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
          childScope.context = result;
          target.f(this, arguments, new SamuraiContext(childScope, callStack));
        } else {
          result = target.f(
              this, arguments, new SamuraiContext(childScope, callStack));
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
      return visitFunctionNode(node.function, ctx);
    }

    if (node is ArrayExpression) {
      var items = node.expressions.map((e) => visitExpression(e, ctx));
      return new JsArray()..valueOf.addAll(items);
    }

    if (node is BinaryExpression) {
      var left = visitExpression(node.left, ctx);
      var right = visitExpression(node.right, ctx);
      return performBinaryOperation(node.operator, left, right, ctx);
    }

    if (node is AssignmentExpression) {
      var l = node.left;

      if (l is NameExpression) {
        if (node.operator == '=') {
          return scope
              .assign(l.name.value, visitExpression(node.right, ctx))
              .value;
        } else {
          var trimmedOp = node.operator.substring(0, node.operator.length - 1);
          return scope
              .assign(
                l.name.value,
                performNumericalBinaryOperation(
                  trimmedOp,
                  visitExpression(l, ctx),
                  visitExpression(node.right, ctx),
                  ctx,
                ),
              )
              .value;
        }
      } else if (l is MemberExpression) {
        var left = visitExpression(l.object, ctx);

        if (node.operator == '=') {
          return left.setProperty(
              l.property.value, visitExpression(node.right, ctx));
        } else {
          var trimmedOp = node.operator.substring(0, node.operator.length - 1);
          return left.setProperty(
            l.property.value,
            performNumericalBinaryOperation(
              trimmedOp,
              left.getProperty(l.property.value),
              visitExpression(node.right, ctx),
              ctx,
            ),
          );
        }
      } else {
        throw callStack.error(
            'Reference', 'Invalid left-hand side in assignment');
      }
    }

    if (node is SequenceExpression) {
      return node.expressions.map((e) => visitExpression(e, ctx)).last;
    }

    if (node is UnaryExpression) {
      var expr = visitExpression(node.argument, ctx);

      // +, -, !, ~, typeof, void, delete
      switch (node.operator) {
        case 'typeof':
          return new JsString(expr?.typeof ?? 'undefined');
        case 'void':
          return null;
        default:
          throw callStack.error('Unsupported', node.operator);
      }
    }

    throw callStack.error('Unsupported', node.runtimeType.toString());
  }

  JsObject performBinaryOperation(
      String op, JsObject left, JsObject right, SamuraiContext ctx) {
    // TODO: May be: ==, !=, ===, !==, in, instanceof
    if (op == '==') {
      // TODO: Loose equality
      throw new UnimplementedError('== operator');
    } else if (op == '===') {
      // TODO: Override operator
      return new JsBoolean(left == right);
    } else if (op == '&&') {
      return (left?.isTruthy != true) ? left : right;
    } else if (op == '||') {
      return (left?.isTruthy == true) ? left : right;
    } else if (op == '<') {
      return safeBooleanOperation(left, right, this, ctx, (l, r) => l < r);
    } else if (op == '<=') {
      return safeBooleanOperation(left, right, this, ctx, (l, r) => l <= r);
    } else if (op == '>') {
      return safeBooleanOperation(left, right, this, ctx, (l, r) => l > r);
    } else if (op == '>=') {
      return safeBooleanOperation(left, right, this, ctx, (l, r) => l >= r);
    } else {
      return performNumericalBinaryOperation(op, left, right, ctx);
    }
  }

  JsObject performNumericalBinaryOperation(
      String op, JsObject left, JsObject right, SamuraiContext ctx) {
    if (op == '+' && (!canCoerceToNumber(left) || !canCoerceToNumber(right))) {
      // TODO: Append string...
      return new JsString(left.toString() + right.toString());
    } else {
      var l = coerceToNumber(left, this, ctx);
      var r = coerceToNumber(right, this, ctx);

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

  JsObject visitFunctionNode(FunctionNode node, SamuraiContext ctx) {
    JsFunction function;
    function = new JsFunction(ctx.scope.context, (samurai, arguments, ctx) {
      for (double i = 0.0; i < node.params.length; i++) {
        ctx.scope.create(node.params[i.toInt()].value,
            value: arguments.properties[i]);
      }

      return visitStatement(node.body, ctx, function.name);
    });
    function.declaration = node;
    function.properties['length'] = new JsNumber(node.params.length);
    function.properties['name'] = new JsString(node.name?.value ?? 'anonymous');

    // TODO: What about hoisting???
    if (node.name != null) {
      ctx.scope.create(node.name.value, value: function, constant: true);
    }

    function.closureScope = ctx.scope.fork();
    function.closureScope.context = ctx.scope.context;
    return function;
  }

  JsObject invoke(JsFunction target, List<JsObject> args, SamuraiContext ctx) {
    var scope = ctx.scope, callStack = ctx.callStack;
    var childScope = (target.closureScope ?? scope);
    var arguments = new JsArguments(args, target);
    childScope = childScope.createChild(values: {'arguments': arguments});
    childScope.context = target.context ?? scope.context;

    JsObject result;

    if (target.declaration != null) {
      callStack.push(
          target.declaration.filename, target.declaration.line, target.name);
    }

    result =
        target.f(this, arguments, new SamuraiContext(childScope, callStack));

    if (target.declaration != null) {
      callStack.pop();
    }

    return result;
  }
}
