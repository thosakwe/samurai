import 'dart:io';
import 'package:cli_repl/cli_repl.dart';
import 'package:io/ansi.dart';
import 'package:logging/logging.dart';
import 'package:parsejs/parsejs.dart';
import 'package:samurai/samurai.dart';

main(List<String> args) async {
  var samurai = new Samurai();
  var logger = new Logger('samurai');
  samurai.global.properties['console'] = new JsConsole(logger);

  logger.onRecord.listen((rec) {
    if (rec.level == Level.SEVERE) {
      print(red.wrap(rec.toString()));
    } else if (rec.level == Level.WARNING) {
      print(yellow.wrap(rec.toString()));
    } else if (rec.level == Level.INFO) {
      print(cyan.wrap(rec.toString()));
    } else {
      print(rec);
    }
  });

  if (args.isNotEmpty) {
    try {
      var file = new File(args[0]);
      var node = parsejs(await file.readAsString(), filename: file.path);
      samurai.visitProgram(node);
    } on SamuraiException catch (e) {
      print(red.wrap(e.toString()));
    }
  } else {
    var repl = new Repl(prompt: '> ');

    for (var line in repl.run()) {
      try {
        var node = parsejs(line);
        var result = samurai.visitProgram(node);
        handleResult(result);
      } on ParseError catch (e) {
        print(red.wrap('SyntaxError: ${e.message}'));
      } catch (e) {
        print(red.wrap(e.toString()));
      }
    }
  }
}

void handleResult(JsObject obj) {
  var result = obj?.valueOf;

  if (obj is JsFunction) {
    print(cyan.wrap(obj.toString()));
  } else if (result == null) {
    print(darkGray.wrap('undefined'));
  } else if (result is String) {
    var value = "'${result.replaceAll("'", "\\'").replaceAll('\b', '\\b')
        .replaceAll('\f', '\\f').replaceAll('\r', '\\r').replaceAll(
        '\n', '\\n')
        .replaceAll('\t', '\\t')}'";
    print(green.wrap(value));
  } else if (result is bool) {
    print(yellow.wrap(result.toString()));
  } else if (result is num) {
    if (result.isNaN) {
      print(yellow.wrap('NaN'));
    } else if (result.isInfinite) {
      print(yellow.wrap(result.isNegative ? '-Infinity' : 'Infinity'));
    } else {
      var value = result == result.toInt() ? result.toInt() : result;
      print(yellow.wrap(value.toString()));
    }
  } else if (result is Map) {
    // TODO: Pretty print
    print(result);
  } else {
    print(result);
  }
}
