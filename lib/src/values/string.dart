import 'package:prototype/prototype.dart';
import '../value.dart';

final ProtoType JsString = new ProtoType.extend(JsObject, name: 'String',
    constructor: (ctx, [args, named]) {
  ctx.value = args[0].toString();
});

ProtoTypeInstance string(value) => JsString.instance([value]);
