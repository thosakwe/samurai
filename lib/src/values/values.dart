import 'package:prototype/prototype.dart';
import 'boolean.dart';
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
      return obj.samurai$$value == 0 || obj.samurai$$value == double.NAN;
    else if (obj.isInstanceOf(JsString))
      return obj.samurai$$value?.isNotEmpty == true;

    return !obj.isInstanceOf(JsNull);
  }
}
