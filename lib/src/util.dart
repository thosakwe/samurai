import 'package:parsejs/parsejs.dart';
import 'array.dart';
import 'context.dart';
import 'function.dart';
import 'literal.dart';
import 'object.dart';
import 'samurai.dart';

bool canCoerceToNumber(JsObject object) {
  return object is JsNumber ||
      object is JsBoolean ||
      object is JsNull ||
      object == null ||
      (object is JsArray && object.valueOf.length != 1);
}

double coerceToNumber(JsObject object, Samurai samurai, SamuraiContext ctx) {
  if (object is JsNumber) {
    return object.valueOf;
  } else if (object == null) {
    return double.nan;
  } else if (object is JsNull) {
    return 0.0;
  } else if (object is JsBoolean) {
    return object.valueOf ? 1.0 : 0.0;
  } else if (object is JsArray && object.valueOf.isEmpty) {
    return 0.0;
  } else if (object is JsString) {
    return num.tryParse(object.valueOf)?.toDouble() ?? double.nan;
  } else {
    var valueOfFunc = object?.getProperty('valueOf');

    if (valueOfFunc != null) {
      if (valueOfFunc is JsFunction) {
        return coerceToNumber(
            samurai.invoke(valueOfFunc, [], ctx), samurai, ctx);
      } else {
        throw ctx.callStack.error(
            'Type', 'The .valueOf property for this object is not a function.');
      }
    } else {
      return double.nan;
    }
  }
}

JsBoolean safeBooleanOperation(JsObject left, JsObject right, Samurai samurai,
    SamuraiContext ctx, bool Function(num, num) f) {
  var l = coerceToNumber(left, samurai, ctx);
  var r = coerceToNumber(right, samurai, ctx);

  if (l.isNaN || r.isNaN) {
    return new JsBoolean(false);
  } else {
    return new JsBoolean(f(l, r));
  }
}
