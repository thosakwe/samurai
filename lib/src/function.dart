import 'package:parsejs/parsejs.dart';
import 'package:symbol_table/symbol_table.dart';
import 'arguments.dart';
import 'context.dart';
import 'literal.dart';
import 'object.dart';
import 'samurai.dart';

// TODO: Prototype
class JsFunction extends JsObject {
  final JsObject Function(Samurai, JsArguments, SamuraiContext) f;
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

  void set name(String value) => properties['name'] = new JsString(value);

  JsFunction bind(JsObject newContext) {
    return new JsFunction(newContext, f)
      ..properties.addAll(properties)
      ..closureScope = closureScope.fork()
      ..declaration = declaration;
  }

  @override
  String toString() {
    return isAnonymous ? '[Function]' : '[Function: $name]';
  }
}
