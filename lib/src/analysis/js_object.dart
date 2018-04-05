import 'js_function.dart';
import 'js_property.dart';
import 'js_value.dart';

class JsObject extends JsValue {
  JsObject() : super(JsTypeOf.object);

  static JsValue assign(JsValue src, JsValue object) {
    src.properties.forEach((name, property) {
      object.properties[name] = new JsProperty.normal(
          name, property.getter.apply(src, new JsArgumentList()));
    });

    return object;
  }
}
