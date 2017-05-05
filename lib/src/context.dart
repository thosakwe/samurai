import 'package:prototype/prototype.dart';
import 'stdlib/stdlib.dart';
import 'values/values.dart';
import 'value.dart';

/// A JavaScript execution context.
class JsContext {
  /// The object to be used as the global scope.
  ProtoTypeInstance global;
}

class SamuraiDefaultContext extends JsContext {
  SamuraiDefaultContext() {
    global = _buildGlobal();
    global.global = global;
  }

  ProtoTypeInstance _buildGlobal() {
    return object()
      ..Math = buildMath()
      ..NaN = JsNaN
      ..samurai = wrapBoolean(true)
      ..decodeURI = wrapFunction('decodeURI', _decodeURI)
      ..decodeURIComponent =
          wrapFunction('decodeURIComponent', _decodeURIComponent)
      ..encodeURI = wrapFunction('encodeURIComponent', _encodeURI)
      ..encodeURIComponent =
          wrapFunction('encodeURIComponent', _encodeURIComponent)
      ..parseInt = wrapFunction('parseInt', _parseInt)
      ..parseFloat = wrapFunction('parseFloat', _parseFloat);
  }

  _decodeURI(ctx, [List args, named]) {
    if (args.isEmpty) {
      // TODO: throw exception
    } else
      return Uri.decodeFull(args.first.toString());
  }

  _decodeURIComponent(ctx, [List args, named]) {
    if (args.isEmpty) {
      // TODO: throw exception
    } else
      return Uri.decodeComponent(args.first.toString());
  }

  _encodeURI(ctx, [List args, named]) {
    if (args.isEmpty) {
      // TODO: throw exception
    } else
      return Uri.encodeFull(args.first.toString());
  }

  _encodeURIComponent(ctx, [List args, named]) {
    if (args.isEmpty) {
      // TODO: throw exception
    } else
      return Uri.encodeComponent(args.first.toString());
  }

  _parseInt(ctx, [List args, named]) {
    if (args.isEmpty) {
      // TODO: throw exception
    } else
      return int.parse(args.first.toString());
  }

  _parseFloat(ctx, [List args, named]) {
    if (args.isEmpty) {
      // TODO: throw exception
    } else
      return double.parse(args.first.toString());
  }
}
