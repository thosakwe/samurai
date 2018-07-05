import 'package:parsejs/parsejs.dart';
import 'package:symbol_table/symbol_table.dart';
import 'arguments.dart';
import 'literal.dart';
import 'object.dart';
import 'samurai.dart';

// TODO: Prototype
class JsFunction extends JsObject {
  final JsObject Function(Samurai, JsArguments, SymbolTable<JsObject>) f;
  final JsObject context;
  SymbolTable<JsObject> closureScope;
  Node declaration;

  JsFunction(this.context, this.f) {
    properties['length'] = new JsNumber(0);
    properties['name'] = new JsString('anonymous');
    properties['prototype'] = new JsObject();
  }

  bool get isAnonymous {
    return properties['name'] == null ||
        properties['name'].toString() == 'anonymous';
  }

  String get name {
    if (isAnonymous) {
      return '(anonymous function)';
    } else {
      return properties['name'].toString();
    }
  }

  @override
  String toString() {
    return isAnonymous ? '[Function]' : '[Function: $name]';
  }
}
