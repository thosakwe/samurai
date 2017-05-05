import 'package:prototype/prototype.dart';
import '../value.dart';

final ProtoType JsNumber = new ProtoType.extend(JsObject,
    name: 'Number', constructor: (ctx, [args, named]) {
  ctx.samurai$$value = args[0];
});

final ProtoTypeInstance JsNaN = wrapNumber(double.NAN);

ProtoTypeInstance wrapNumber(num value) => JsNumber.instance([value]);