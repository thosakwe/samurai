import 'js_function.dart';
import 'js_value.dart';

class JsProperty {
  JsFunction _getter, _setter;
  JsValue _value;

  JsProperty._();

  JsProperty(JsFunction getter, JsFunction setter)
      : _getter = getter,
        _setter = setter;

  JsFunction get getter => _getter;

  JsFunction get setter => _setter;

  factory JsProperty.normal(String name) {
    var p = new JsProperty._();
    p._getter = new JsFunction.anonymous(
      (context, arguments) {
        return p._value;
      },
      name: 'get $name',
    );

    p._setter = new JsFunction.anonymous(
      (context, arguments) {
        return p._value = arguments[0];
      },
      name: 'set $name',
    );

    return p;
  }
}
