import 'package:cli_repl/cli_repl.dart';
import 'package:io/ansi.dart';
import 'package:parsejs/parsejs.dart';
import 'package:samurai/samurai.dart';

main() async {
  var repl = new Repl(prompt: '> ');
  var samurai = new Samurai();

  for (var line in repl.run()) {
    var node = parsejs(line, parseAsExpression: true);
    var result = samurai.visitProgram(node)?.valueOf;

    if (result == null) {
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
      var value = result == result.toInt() ? result.toInt() : result;
      print(yellow.wrap(value.toString()));
    } else if (result is Map) {
      // TODO: Pretty print
      print(result);
    } else {
      print(result);
    }
  }
}
