import 'js_property.dart';

abstract class JsValue {
  final Map<String, JsProperty> properties = {};
  String get typeof;
}

abstract class JsTypeOf {
  static const String string = 'string',
      number = 'number',
      undefined = 'undefined',
      object = 'object',
      function = 'function';
}
