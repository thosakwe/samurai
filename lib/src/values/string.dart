import 'package:prototype/prototype.dart';
import '../value.dart';

final ProtoType JsString = new ProtoType.extend(JsObject, name: 'String',
    constructor: (ctx, [args, named]) {
  ctx.samurai$$value = args[0].toString();
});

ProtoTypeInstance wrapString(value) => JsString.instance([value]);
