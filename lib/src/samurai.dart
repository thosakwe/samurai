import 'dart:async';
import 'package:parsejs/parsejs.dart';
import 'package:symbol_table/symbol_table.dart';
import 'array.dart';
import 'arguments.dart';
import 'function.dart';
import 'literal.dart';
import 'object.dart';

class Samurai {
  final List<Completer> awaiting = <Completer>[];
  final SymbolTable<JsObject> scope = new SymbolTable();
  final JsObject global = new JsObject();

  Samurai() {
    scope
      ..context = global
      ..create('global', value: global);
  }

  JsObject visitProgram(Program node) {
    // TODO: Hoist functions, declarations into global scope.
    JsObject out;

    for (var stmt in node.body) {
      var result = visitStatement(stmt, scope);

      if (stmt is ExpressionStatement) {
        out = result;
      }
    }

    return out;
  }

  JsObject visitStatement(Statement node, SymbolTable<JsObject> scope) {
    if (node is ExpressionStatement) {
      return visitExpression(node.expression, scope);
    }

    if (node is ReturnStatement) {
      return visitExpression(node.argument, scope);
    }

    if (node is BlockStatement) {
      for (var stmt in node.body) {
        var result = visitStatement(stmt, scope.createChild());

        if (stmt is ReturnStatement) {
          return result;
        }
      }

      return null;
    }

    if (node is VariableDeclaration) {
      for (var decl in node.declarations) {
        // TODO: What if it already exists?
        scope.create(decl.name.value, value: visitExpression(decl.init, scope));
      }
    }

    // TODO: Throw proper error
    throw new ArgumentError(node.runtimeType.toString());
  }

  JsObject visitExpression(Expression node, SymbolTable<JsObject> scope) {
    if (node is NameExpression) {
      // TODO: ReferenceError on undefined...?
      var ref = scope.resolve(node.name.value)?.value ??
          scope.context.properties[node.name.value];
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

        var childScope = scope.createChild(values: {'arguments': arguments});

        if (node.isNew) {
          var result = target.newInstance();
          target.f(this, arguments, childScope..context = result);
          return result;
        } else {
          return target.f(this, arguments, childScope);
        }
      } else {
        // TODO: Throw proper error
        if (node.isNew) {
          throw 'TypeError: ${target?.valueOf ??
              'undefined'} is not a constructor';
        } else {
          throw 'TypeError: ${target?.valueOf ??
              'undefined'} is not a function';
        }
      }
    }

    if (node is FunctionExpression) {
      var function = new JsFunction(scope.context, (samurai, arguments, scope) {
        for (double i = 0.0; i < node.function.params.length; i++) {
          scope.create(node.function.params[i.toInt()].value,
              value: arguments.properties[i]);
        }

        return visitStatement(node.function.body, scope);
      });

      function.properties['length'] = new JsNumber(node.function.params.length);
      function.properties['name'] =
          new JsString(node.function.name?.value ?? 'anonymous');

      // TODO: What about hoisting???
      if (node.function.name != null) {
        scope.create(node.function.name.value, value: function, constant: true);
      }

      return function;
    }

    if (node is ArrayExpression) {
      var items = node.expressions.map((e) => visitExpression(e, scope));
      return new JsArray()..valueOf.addAll(items);
    }

    // TODO: Throw proper error
    throw new ArgumentError();
  }
}
