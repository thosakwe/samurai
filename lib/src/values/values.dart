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
