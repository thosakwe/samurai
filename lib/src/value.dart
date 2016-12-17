import 'package:prototype/prototype.dart';

final ProtoType JsObject = new ProtoType(name: 'Object');
ProtoTypeInstance object() => JsObject.instance();

/*/// Represents data in JavaScript.
class JsValue {
  Node declaration;
  ProtoType type = JsObject;

  JsValue({this.declaration});
}*/