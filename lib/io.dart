import 'dart:io';
import 'package:prototype/prototype.dart';
import 'samurai.dart';

const JsPolyfill SAMURAI_IO = const _SamuraiIo();

class _SamuraiIo implements JsPolyfill {
  const _SamuraiIo();

  @override
  void call(JsContext context) {
    context..global.console = _buildConsole();
  }
}

ProtoTypeInstance _buildConsole() {
  final ProtoType JsConsole =
      new ProtoType.extend(JsObject, name: 'Console', prototype: {
    #log: wrapFunction('log', (ctx, [args, named]) {
      if (args?.isNotEmpty == true)
        stdout.writeln(args.map(stringifyForJs).join());
    }),
    #info: wrapFunction('info', (ctx, [args, named]) {
      if (args?.isNotEmpty == true)
        stdout.writeln(args.map(stringifyForJs).join());
    }),
    #error: wrapFunction('error', (ctx, [args, named]) {
      if (args?.isNotEmpty == true)
        stderr.writeln(args.map(stringifyForJs).join());
    }),
  });

  return JsConsole.instance();
}
