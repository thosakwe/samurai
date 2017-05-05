import 'dart:io';
import 'dart:mirrors';
import 'package:prototype/prototype.dart';
import 'samurai.dart';

JsContext applyIo(JsContext context) =>
    context..global.console = _buildConsole();

ProtoTypeInstance _buildConsole() {
  final ProtoType JsConsole =
      new ProtoType.extend(JsObject, name: 'Console', prototype: {
    #log: wrapFunction('log', (ctx, [args, named]) {
      if (args?.isNotEmpty == true)
        stdout.writeln(args.map(stringifyForJs).join(','));
    }),
    #info: wrapFunction('info', (ctx, [args, named]) {
      if (args?.isNotEmpty == true)
        stdout.writeln(args.map(stringifyForJs).join(','));
    }),
    #error: wrapFunction('error', (ctx, [args, named]) {
      if (args?.isNotEmpty == true)
        stderr.writeln(args.map(stringifyForJs).join(','));
    }),
  });

  return JsConsole.instance();
}

String stringifyForJs(x) {
  if (x is ProtoTypeInstance) {
    if (isJsPrimitive(x)) {
      if (x.isInstanceOf(JsNumber)) {
        var n = x.samurai$$value as num;
        return n == n.toInt() ? n.toInt().toString() : n.toString();
      } else
        return x.samurai$$value.toString();
    } else if (x.isInstanceOf(JsFunction)) {
      if (x.samurai$$nativeFunction != null)
        return 'function ${x.samurai$$nativeName}() { [native code] }';
      else
        return 'TODO: STRINGIFY FUNCTIONS';
      // TODO: Stringify Functions
    } else {
      var map = x.members.keys.fold<Map<String, String>>({}, (out, k) {
        return out..[MirrorSystem.getName(k)] = stringifyForJs(x.members[k]);
      });
      return 'Object: $map';
    }
  } else
    return x == null ? 'undefined' : x.toString();
}
