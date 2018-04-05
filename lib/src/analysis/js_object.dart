import 'js_property.dart';
import 'js_value.dart';

class JsObject extends JsValue {
  @override
  String get typeof => JsTypeOf.object;
}