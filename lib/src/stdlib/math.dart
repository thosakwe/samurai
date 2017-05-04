import 'dart:math' as math;
import 'package:prototype/prototype.dart';
import '../values/values.dart';
import '../value.dart';

ProtoTypeInstance buildMath() {
  return object()
    ..E = wrapNumber(math.E)
    ..LN2 = wrapNumber(math.LN2)
    ..LN10 = wrapNumber(math.LN10)
    ..LOG2E = wrapNumber(math.LOG2E)
    ..LOG10E = wrapNumber(math.LOG10E)
    ..PI = wrapNumber(math.PI)
    ..SQRT1_2 = wrapNumber(math.SQRT1_2)
    ..SQRT2 = wrapNumber(math.SQRT2);
}

ProtoTypeInstance _single(String name, func(num x)) {
  return wrapFunction(name, (ctx, [args, named]) {
    if (args.isEmpty) {
      // TODO: throw exception
    } else {
      // TODO: wrap...
    }
  });
}
