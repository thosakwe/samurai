import 'literal.dart';
import 'object.dart';

class JsArguments extends JsObject {
  final List<JsObject> arguments;
  final JsObject callee;

  JsArguments(this.arguments, this.callee) {
    properties['callee'] = properties['caller'] = callee;
    properties['length'] = new JsNumber(arguments.length);

    for (int i = 0; i < arguments.length; i++) {
      properties[i.toDouble()] = arguments[i];
    }
  }
}