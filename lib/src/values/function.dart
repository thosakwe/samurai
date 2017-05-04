import 'package:prototype/prototype.dart';
import '../value.dart';

final ProtoType JsFunction = new ProtoType.extend(JsObject, name: 'Function');

ProtoTypeInstance wrapFunction(String name, ProtoTypeFunction function) =>
    JsFunction.instance()
      ..samurai$$nativeFunction = function
      ..samurai$$nativeName = name;
