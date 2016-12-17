import 'package:prototype/prototype.dart';
import '../value.dart';

final ProtoType JsNumber = new ProtoType.extend(JsObject,
    name: 'Number', constructor: (ctx, [args, named]) {
  ctx.value = args[0];
});

ProtoTypeInstance number(num value) => JsNumber.instance([value]);