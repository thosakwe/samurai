import 'package:collection/collection.dart';
import 'js_object.dart';
import 'js_property.dart';
import 'js_value.dart';

abstract class JsFunction extends JsValue {
  final JsObject prototype = new JsObject();
  final String name;
  final JsValue context;

  JsFunction({this.name, this.context}) {
    prototype.properties['call'] = new JsProperty.readOnly('call',
        new JsFunction.anonymous((context, arguments) {
      // First arg is `this`, second is arguments
      return apply(arguments[0], arguments.skip(1).toList());
    }));
  }

  factory JsFunction.anonymous(
      JsValue Function(JsValue context, JsArgumentList arguments) f,
      {String name,
      JsValue context}) = _AnonymousJsFunction;

  @override
  String get typeof => JsTypeOf.function;

  JsFunction bind(JsValue context) => new _BoundJsFunction(this, context);

  JsValue apply(JsValue context, JsArgumentList arguments);
}

class _AnonymousJsFunction extends JsFunction {
  final JsValue Function(JsValue context, JsArgumentList arguments) f;

  _AnonymousJsFunction(this.f, {String name, JsValue context})
      : super(name: name, context: context);

  @override
  JsValue apply(JsValue context, JsArgumentList arguments) {
    return f(context, arguments);
  }
}

class _BoundJsFunction extends JsFunction {
  final JsFunction parent;
  final JsValue context;

  _BoundJsFunction(this.parent, this.context)
      : super(name: parent.name, context: context);

  @override
  JsValue apply(JsValue context, JsArgumentList arguments) {
    return parent.apply(context, arguments);
  }
}

class JsArgumentList extends DelegatingList<JsValue> {
  JsArgumentList() : super([]);

  @override
  JsValue operator [](int index) {
    try {
      return super[index];
    } on RangeError {
      return JsValue.undefined;
    }
  }
}