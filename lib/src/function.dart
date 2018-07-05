import 'package:symbol_table/symbol_table.dart';
import 'arguments.dart';
import 'literal.dart';
import 'object.dart';
import 'samurai.dart';

// TODO: Prototype
class JsFunction extends JsObject {
  final JsObject Function(Samurai, JsArguments, SymbolTable<JsObject>) f;
  final JsObject context;

  JsFunction(this.context, this.f) {
    properties['length'] = new JsNumber(0);
    properties['name'] = new JsString('anonymous');
    properties['prototype'] = new JsObject();
  }

// TODO: toString()
}
