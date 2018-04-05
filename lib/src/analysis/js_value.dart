import 'js_property.dart';

abstract class JsValue {
  final Map<String, JsProperty> properties = {};
  static _JsUndefined _undefined;

  static get undefined => _undefined ??= new _JsUndefined();

  String get typeof;
}

abstract class JsTypeOf {
  static const String string = 'string',
      number = 'number',
      undefined = 'undefined',
      object = 'object',
      function = 'function';
}

class _JsUndefined extends JsValue {
  @override
  String get typeof => JsTypeOf.undefined;

  @override
  String toString() {
    return 'undefined';
  }
}
