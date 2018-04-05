import 'dart:collection';
import 'package:code_buffer/code_buffer.dart';
import 'js_function.dart';
import 'js_property.dart';

abstract class JsValue {
  static get undefined => _undefined ??= new _JsUndefined();
  static _JsUndefined _undefined;
  final String typeof;
  SplayTreeMap<String, JsProperty> _properties;

  JsValue(this.typeof);

  Map<String, JsProperty> get properties => _properties ??= createProperties();

  SplayTreeMap<String, JsProperty> createProperties() {
    var properties = new SplayTreeMap();
    properties['toString'] = new JsProperty.normal('toString',
        new JsFunction.anonymous((context, arguments) {
      // TODO: JS String
    }));
    return properties;
  }

  void prettyPrint(CodeBuffer buf) {
    buf.writeln(toString());
  }
}

abstract class JsTypeOf {
  static const String string = 'string',
      number = 'number',
      undefined = 'undefined',
      object = 'object',
      function = 'function',
      boolean = 'booleanA';
}

class _JsUndefined extends JsValue {
  _JsUndefined() : super(JsTypeOf.undefined);

  @override
  String toString() {
    return 'undefined';
  }
}
