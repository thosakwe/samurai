import 'js_object.dart';
import 'js_value.dart';

abstract class JsFunction extends JsValue {
  final JsObject prototype = new JsObject();
  final String name;
  final JsValue context;

  JsFunction({this.name, this.context});

  factory JsFunction.anonymous(
      JsValue Function(JsValue context, List<JsValue> arguments) f,
      {String name,
      JsValue context}) = _AnonymousJsFunction;

  @override
  String get typeof => JsTypeOf.function;

  JsFunction bind(JsValue context) => new _BoundJsFunction(this, context);

  JsValue apply(JsValue context, List<JsValue> arguments);
}

class _AnonymousJsFunction extends JsFunction {
  final JsValue Function(JsValue context, List<JsValue> arguments) f;

  _AnonymousJsFunction(this.f, {String name, JsValue context})
      : super(name: name, context: context);

  @override
  JsValue apply(JsValue context, List<JsValue> arguments) {
    return f(context, arguments);
  }
}

class _BoundJsFunction extends JsFunction {
  final JsFunction parent;
  final JsValue context;

  _BoundJsFunction(this.parent, this.context)
      : super(name: parent.name, context: context);

  @override
  JsValue apply(JsValue context, List<JsValue> arguments) {
    return parent.apply(context, arguments);
  }
}
