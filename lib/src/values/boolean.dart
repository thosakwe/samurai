import 'package:prototype/prototype.dart';
import '../value.dart';

final ProtoType JsBoolean = new ProtoType.extend(JsObject, name: 'Boolean',
    constructor: (ctx, [args, named]) {
  ctx.value = args[0];
});

ProtoTypeInstance boolean(bool value) => JsBoolean.instance([value]);
