import 'js_function.dart';
import 'js_property.dart';
import 'js_value.dart';
import 'package:code_buffer/code_buffer.dart';

class JsObject extends JsValue {
  JsObject() : super(JsTypeOf.object);

  static JsValue assign(JsValue src, JsValue object) {
    src.properties.forEach((name, property) {
      object.properties[name] = new JsProperty.normal(
          name, property.getter.apply(src, new JsArgumentList()));
    });

    return object;
  }

  @override
  void prettyPrint(CodeBuffer buf) {
    if (properties.isEmpty) {
      buf.write('{}');
      return;
    }

    if (properties.length == 1) {
      buf.write('{ ');
    } else if (properties.isNotEmpty) {
      buf
        ..writeln('{')
        ..indent();
    }

    int i = 0;
    properties.forEach((name, property) {
      var value = property.getter.apply(this, new JsArgumentList());
      buf.write('$name: $value');
      if (i++ < properties.length - 1) buf.write(', ');
      buf.writeln();
    });

    if (properties.length > 1) buf.outdent();
    buf.write('}');
  }

  @override
  String toString() {
    return '[object Object]';
  }
}
