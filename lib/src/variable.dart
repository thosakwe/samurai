import 'package:prototype/prototype.dart';

/// Represents a variable in JavaScript.
class JsVariable {
  final String name;
  ProtoTypeInstance value;

  JsVariable(this.name, [this.value]);
}