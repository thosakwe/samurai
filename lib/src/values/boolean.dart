import 'package:prototype/prototype.dart';
import '../value.dart';

final ProtoType JsBoolean = new ProtoType.extend(JsObject, name: 'Boolean',
    constructor: (ctx, [args, named]) {
  ctx.samurai$$value = args[0];
});

ProtoTypeInstance wrapBoolean(bool value) => JsBoolean.instance([value]);
