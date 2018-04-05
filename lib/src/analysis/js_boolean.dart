import 'js_value.dart';

class JsBoolean extends JsValue {
  static final JsBoolean true$ = new JsBoolean(true),
      false$ = new JsBoolean(false);
  final bool value;

  JsBoolean(this.value) : super(JsTypeOf.boolean);

  @override
  String toString() {
    return value.toString();
  }
}
