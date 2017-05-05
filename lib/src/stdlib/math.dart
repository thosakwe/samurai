import 'dart:math' as math;
import 'package:prototype/prototype.dart';
import '../values/values.dart';
import '../value.dart';

ProtoTypeInstance buildMath() {
  // TODO: Some math unsupported in Dart!!!
  var _rnd = new math.Random();
  return object()
        ..E = wrapNumber(math.E)
        ..LN2 = wrapNumber(math.LN2)
        ..LN10 = wrapNumber(math.LN10)
        ..LOG2E = wrapNumber(math.LOG2E)
        ..LOG10E = wrapNumber(math.LOG10E)
        ..PI = wrapNumber(math.PI)
        ..SQRT1_2 = wrapNumber(math.SQRT1_2)
        ..SQRT2 = wrapNumber(math.SQRT2)
        ..abs = _single('abs', (num x) => x.abs())
        ..acos = _single('acos', math.acos)
        ..acosh = _single(
            'acosh', (num x) => math.log(x + math.sqrt((math.pow(x, 2)) - 1.0)))
        ..asin = _single('asin', math.asin)
        ..asinh = _single('asinh', _asinh)
        ..atan = _single('atan', math.atan)
        ..atanh =
            _single('atanh', (num x) => 0.5 * math.log((1.0 + x) / (1.0 - x)))
        ..atan2 = _double('atan2', math.atan2)
        ..cbrt = _single('cbrt',
            (num x) => throw new UnsupportedError('cbrt is not yet supported!'))
        ..ceil = _single('ceil', (num x) => x.ceil())
        ..clz32 = _single(
            'clz32',
            (num x) =>
                throw new UnsupportedError('clz32 is not yet supported!'))
        ..cos = _single('cos', math.cos)
        ..cosh = _single('cosh', _cosh)
        ..deg = _single('deg', _deg)
        ..exp = _single('exp', math.exp)
        ..expm1 = _single('exmp1', (num x) => math.exp(x) - 1)
        ..floor = _single('floor', (num x) => x.floor())
        ..fround = _single('fround', (num x) => x.roundToDouble())
        ..hypot = wrapFunction(
            'hypot',
            (ctx, [args, named]) =>
                throw new UnsupportedError('hypot is not yet supported!'))
        ..imul = _double('imul', (num x, num y) => x.toInt() * y.toInt())
        ..log = _single('log', math.log)
        ..log1p = _single('log1p', (num x) => math.log(x + 1))
        ..log2 = _single('log2', (num x) => math.log(x) / math.log(2))
        ..max = wrapFunction('max', _max)
        ..min = wrapFunction('min', _min)
        ..pow = _double('pow', math.pow)
        ..rad = _single('rad', _toRadians)
        ..random = wrapFunction('random', (ctx, [args, named]) {
          return wrapNumber(_rnd.nextDouble());
        })
        ..round = _single('round', (num x) => x.toInt())
        ..sign = _single('sign', (num x) => x.sign)
        ..sin = _single('sin', math.sin)
        ..sinh = _single('sinh', _sinh)
        ..sqrt = _single('sqrt', math.sqrt)
        ..tan = _single('tan', math.tan)
        ..tanh = _single('tanh', _tanh)
        ..trunc = _single(
            'trunc',
            (num x) =>
                throw new UnsupportedError('trunc is not yet supported!'))
        ..toSource =
            wrapFunction('toSource', (ctx, [args, named]) => wrapString('Math'))

      //
      ;
}

ProtoTypeInstance _max(ProtoTypeInstance ctx, [List args, named]) {
  if (args.isEmpty) return wrapNumber(double.NEGATIVE_INFINITY);
  var result = double.NAN;

  for (var arg in args) {
    var n = numerifyForJs(arg);
    if (n == null) continue;
    if (result.isNaN || n > result) result = n;
  }

  return result.isNaN ? JsNaN : wrapNumber(result);
}

ProtoTypeInstance _min(ProtoTypeInstance ctx, [List args, named]) {
  if (args.isEmpty) return wrapNumber(double.INFINITY);
  var result = double.NAN;

  for (var arg in args) {
    var n = numerifyForJs(arg);
    if (n == null) continue;
    if (result.isNaN || n < result) result = n;
  }

  return result.isNaN ? JsNaN : wrapNumber(result);
}

num _deg(num x) => x * (180.0 / math.PI);

num _toRadians(num x) => x * (math.PI / 180.0);

num _cosh(num x) {
  var rads = _toRadians(x);
  return (math.exp(rads) + math.exp(rads * -1)) / 2.0;
}

num _sinh(num x) {
  var rads = _toRadians(x);
  return (math.exp(rads) - math.exp(rads * -1)) / 2.0;
}

num _tanh(num x) => _sinh(x) / _cosh(x);

num _asinh(num x) {
  return math.log(x + math.sqrt((x * x) + 1.0));
}

ProtoTypeInstance _single(String name, num func(num x)) {
  return wrapFunction(name, (ctx, [args, named]) {
    if (args.isEmpty) {
      return JsNaN;
    } else {
      return wrapNumber(func(numerifyForJs(args.first)));
    }
  });
}

ProtoTypeInstance _double(String name, num func(num x, num y)) {
  return wrapFunction(name, (ctx, [args, named]) {
    if (args.length < 2) {
      return JsNaN;
    } else {
      return wrapNumber(
          func(numerifyForJs(args.first), numerifyForJs(args[1])));
    }
  });
}
