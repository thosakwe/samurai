import 'package:name_from_symbol/name_from_symbol.dart';
import 'package:parsejs/parsejs.dart';
import 'package:prototype/prototype.dart';
import 'boolean.dart';
import 'function.dart';
import 'null.dart';
import 'number.dart';
import 'string.dart';
export 'boolean.dart';
export 'function.dart';
export 'null.dart';
export 'number.dart';
export 'string.dart';

bool isJsPrimitive(ProtoTypeInstance x) {
  return x.isInstanceOf(JsBoolean) ||
      x.isInstanceOf(JsNull) ||
      x.isInstanceOf(JsNumber) ||
      x.isInstanceOf(JsString);
}

bool isJsString(x) {
  return x != null && x is ProtoTypeInstance && x.isInstanceOf(JsString);
}

bool isTruthy(x) {
  if (x == null || x == false)
    return false;
  else if (x is! ProtoTypeInstance)
    return x == true;
  else {
    var obj = x as ProtoTypeInstance;

    if (obj.isInstanceOf(JsBoolean))
      return obj.samurai$$value == true;
    else if (obj.isInstanceOf(JsNumber))
      return obj.samurai$$value != 0 && obj.samurai$$value != double.NAN;
    else if (obj.isInstanceOf(JsString))
      return obj.samurai$$value?.isNotEmpty == true;

    return !obj.isInstanceOf(JsNull);
  }
}

num numerifyForJs(x) {
  if (x == null || x is! ProtoTypeInstance)
    return null;
  else {
    var obj = x as ProtoTypeInstance;
    if (obj.isInstanceOf(JsNull))
      return 0;
    else if (obj.isInstanceOf(JsNumber) && obj.samurai$$value != null) {
      return obj.samurai$$value;
    } else if (obj.isInstanceOf(JsString)) {
      var value = obj.samurai$$value as String;
      if (value?.isEmpty == true) return 0;

      try {
        return num.parse(obj.samurai$$value);
      } catch (e) {
        return double.NAN;
      }
    } else if (obj.isInstanceOf(JsBoolean)) {
      return obj.samurai$$value == true ? 1 : 0;
    } else {
      return double.NAN;
    }
  }
}

String stringifyForJs(x) {
  if (x is ProtoTypeInstance) {
    if (isJsPrimitive(x)) {
      if (x.isInstanceOf(JsNumber)) {
        var n = x.samurai$$value as num;
        if (n == double.INFINITY)
          return 'Infinity';
        else if (n == double.NEGATIVE_INFINITY)
          return '-Infinity';
        else if (n == double.NAN || n.isNaN) return 'NaN';
        return n == n.toInt() ? n.toInt().toString() : n.toString();
      } else
        return x.samurai$$value.toString();
    } else if (x.isInstanceOf(JsFunction)) {
      if (x.samurai$$functionNode is FunctionNode) {
        var func = x.samurai$$functionNode as FunctionNode;
        var buf = new StringBuffer('function');

        if (x.samurai$$nativeName?.isNotEmpty == true)
          buf.write(' ${x.samurai$$nativeName} ');

        buf.write('(');

        for (int i = 0; i < func.params.length; i++) {
          if (i > 0) buf.write(', ');
          buf.write(func.params[i].value);
        }

        buf.write(') {}');
        return buf.toString();
      } else if (x.samurai$$nativeFunction != null)
        return 'function ${x.samurai$$nativeName}() { [native code] }';
      else
        return 'TODO: STRINGIFY FUNCTIONS';
      // TODO: Stringify Functions
    } else {
      var map = x.members.keys.fold<Map<String, String>>({}, (out, k) {
        return out..[nameFromSymbol(k)] = stringifyForJs(x.members[k]);
      });
      return 'Object: $map';
    }
  } else
    return x == null ? 'undefined' : x.toString();
}
