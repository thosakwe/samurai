import 'package:prototype/prototype.dart';
import '../value.dart';

final ProtoType JsFunction =
    new ProtoType.extend(JsObject, name: 'Function', prototype: {
  #bind: (ctx, [args, named]) {
    var fn = JsObject.instance()..members.addAll(ctx.members);
    return fn..samurai$$this = args.first;
  }
});

ProtoTypeInstance wrapFunction(String name, ProtoTypeFunction function) =>
    JsFunction.instance()
      ..samurai$$nativeFunction = function
      ..samurai$$nativeName = name;
