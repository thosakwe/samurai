import 'js_function.dart';
import 'js_property.dart';

abstract class JsValue {
  static get undefined => _undefined ??= new _JsUndefined();
  static _JsUndefined _undefined;
  final String typeof;
  Map<String, JsProperty> _properties;

  JsValue(this.typeof);

  Map<String, JsProperty> get properties => _properties ??= createProperties();

  Map<String, JsProperty> createProperties() {
    var properties = {};
    properties['toString'] = new JsProperty.normal('toString',
        new JsFunction.anonymous((context, arguments) {
      // TODO: JS String
    }));
    return properties;
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
