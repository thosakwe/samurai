import 'js_function.dart';
import 'js_property.dart';

abstract class JsValue {
  static get undefined => _undefined ??= new _JsUndefined();
  static _JsUndefined _undefined;
  final Map<String, JsProperty> properties = {};

  final String typeof;

  JsValue(this.typeof) {
    properties['toString'] = new JsProperty.normal('toString',
        new JsFunction.anonymous((context, arguments) {
      // TODO: JS String
    }));
  }
}

abstract class JsTypeOf {
  static const String string = 'string',
      number = 'number',
      undefined = 'undefined',
      object = 'object',
      function = 'function';
}

class _JsUndefined extends JsValue {
  _JsUndefined() : super(JsTypeOf.undefined);

  @override
  String toString() {
    return 'undefined';
  }
}
