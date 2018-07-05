import 'package:symbol_table/symbol_table.dart';
import 'object.dart';
import 'stack.dart';

class SamuraiContext {
  final SymbolTable<JsObject> scope;
  final CallStack callStack;

  SamuraiContext(this.scope, this.callStack);

  SamuraiContext createChild() {
    return new SamuraiContext(scope.createChild(), callStack);
  }
}
