import 'package:parsejs/parsejs.dart';
import 'values/values.dart';
import 'context.dart';
import 'scope.dart';

resolveExpression(
    Function printDebug, JsScope scope, JsContext context, Expression node) {
  printDebug('Resolving this ${node.runtimeType}');
  if (node is LiteralExpression) {
    return resolveLiteral(printDebug, scope, context, node);
  }

  if (node is MemberExpression) {
    var object = resolveExpression(printDebug, scope, context, node.object);
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

  if (node is ThisExpression) {
    return scope.innermostThis;
  }
}

resolveLiteral(Function printDebug, JsScope scope, JsContext context,
    LiteralExpression node) {
  if (node.isBool) {
    return boolean(node.boolValue);
  } else if (node.isNull) {
    return JsNull.instance();
  } else if (node.isNumber) {
    return number(node.numberValue);
  } else if (node.isString) {
    return string(node.stringValue);
  }
}
