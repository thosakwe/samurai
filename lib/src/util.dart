import 'array.dart';
import 'literal.dart';
import 'object.dart';

bool canCoerceToNumber(JsObject object) {
  return object is JsNumber ||
      object is JsBoolean ||
      object is JsNull ||
      object == null ||
      (object is JsArray && object.valueOf.length != 1);
}

double coerceToNumber(JsObject object) {
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
  } else {
    return double.nan;
  }
}
