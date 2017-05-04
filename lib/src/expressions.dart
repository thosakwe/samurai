import 'package:parsejs/parsejs.dart';
import 'package:prototype/prototype.dart';
import 'values/values.dart';
import 'context.dart';
import 'scope.dart';
import 'value.dart';

resolveExpression(
    Function printDebug, JsScope scope, JsContext context, Expression node) {
  printDebug('Resolving this ${node.runtimeType}');

  if (node is BinaryExpression) {
    _innerBinary() {
      var left =
          resolveExpression(printDebug, scope, context, node.left)?.value;
      var right =
          resolveExpression(printDebug, scope, context, node.right)?.value;

      // TODO: handle truthy, etc.
      switch (node.operator) {
        case '%':
          return left % right;
        case '*':
          return left * right;
        case '/':
          return left / right;
        case '+':
          return left + right;
        case '-':
          return left - right;
        case '<<':
          return left << right;
        case '>>':
          return left >> right;
        case '&':
          return left & right;
        case '|':
          return left | right;
        case '==':
          return left == right;
        case '!=':
          return left != right;
        case '&&':
          return left && right;
        case '||':
          return left || right;
      }
    }

    var result = _innerBinary();

    if (result is num)
      return wrapNumber(result);
    else if (result is String)
      return wrapString(result);
    else if (result is bool) return wrapBoolean(result);

    return result;
  }

  if (node is CallExpression) {
    var target = resolveExpression(printDebug, scope, context, node.callee);
    var args = node.arguments
        .map((expr) => resolveExpression(printDebug, scope, context, expr))
        .toList();

    if (target is ProtoTypeInstance) {
      if (target.isInstanceOf(JsFunction)) {
        if (node.isNew && target.samurai$$isConstructor == null)
          throw new _TypeErrorImpl('${errorify(target)} is not a constructor');

        if (target.samurai$$nativeFunction != null) {
          var func = target.samurai$$nativeFunction as ProtoTypeFunction;
          ProtoTypeInstance ctx =
              node.isNew ? JsObject.instance() : scope.thisContext;
          var result = func(ctx, args);
          return node.isNew ? ctx : result;
        } else {
          // TODO: Functions defined in code
          throw new UnsupportedError('TODO: Functions');
        }
      } else
        throw new _TypeErrorImpl('$target is not a function');
    } else
      throw new UnsupportedError(
          'Cannot call $target as though it were a JS function.');
  }

  if (node is LiteralExpression) {
    return resolveLiteral(printDebug, scope, context, node);
  }

  if (node is MemberExpression) {
    var object = resolveExpression(printDebug, scope, context, node.object);

    if (object == null)
      throw new _TypeErrorImpl(
          "Cannot read property '${node.property.value}' of undefined");

    return object[new Symbol(node.property.value)];
  }

  if (node is NameExpression) {
    if (node.name.value == 'undefined') return null;

    var result = scope[node.name.value];

    if (result != null)
      return result;
    else {
      var sym = new Symbol(node.name.value);
      if (context.global?.members?.containsKey(sym) == true) {
        return context.global.members[sym];
      }
    }
  }

  if (node is Expression) if (node is ThisExpression) {
    return scope.innermostThis;
  }
}

resolveLiteral(Function printDebug, JsScope scope, JsContext context,
    LiteralExpression node) {
  if (node.isBool) {
    return wrapBoolean(node.boolValue);
  } else if (node.isNull) {
    return JsNull.instance();
  } else if (node.isNumber) {
    return wrapNumber(node.numberValue);
  } else if (node.isString) {
    return wrapString(node.stringValue);
  }
}

String errorify(x) {
  if (x is ProtoTypeInstance &&
      x.isInstanceOf(JsFunction) &&
      x.samurai$$nativeName != null)
    return x.samurai$$nativeName;
  else
    return x.toString();
}

class _TypeErrorImpl extends TypeError {
  @override
  final String message;

  _TypeErrorImpl(this.message);

  @override
  Type get runtimeType => TypeError;

  @override
  String toString() => 'Uncaught TypeError: $message';
}
