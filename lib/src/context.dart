import 'package:prototype/prototype.dart';
import 'values/values.dart';
import 'value.dart';

/// A JavaScript execution context.
class JsContext {
  /// The object to be used as the global scope.
  ProtoTypeInstance global;
}

class SamuraiDefaultContext extends JsContext {
  SamuraiDefaultContext() {
    global = _buildGlobal();
    global.global = global;
  }

  ProtoTypeInstance _buildGlobal() {
    return object()..samurai = boolean(true);
  }
}