#!/usr/bin/env dart
import 'dart:convert';
import 'dart:io';
import 'package:args/args.dart';
import 'package:charcode/charcode.dart';
import 'package:samurai/io.dart';
import 'package:samurai/samurai.dart';
import 'package:samurai/src/pubspec.update.g.dart';

final ArgParser PARSER = new ArgParser(allowTrailingOptions: true)
  ..addFlag('verbose',
      abbr: 'd', negatable: false, help: 'Print verbose debug output.')
  ..addFlag('help',
      abbr: 'h', negatable: false, help: 'Print this help information.')
  ..addFlag('version',
      abbr: 'v',
      negatable: false,
      help: 'Print the currently-installed Samurai version.')
  ..addFlag('repl',
      abbr: 'x', negatable: false, help: 'Run an interactive REPL.');

main(List<String> args) async {
  ArgResults results;

  try {
    results = PARSER.parse(args);
    if (results['help'])
      printHelp(stdout);
    else if (results['version'])
      print('v${PACKAGE_VERSION}');
    else if (results['repl']) {
      final List<String> lines = [];
      final stack = <int>[];
      int index = 0;

      var samurai = new Samurai(
          context: applyIo(new SamuraiDefaultContext()),
          debug: results['verbose']);
      stdin.lineMode = false;
      stdout.write('> ');

      void flush() {
        if (stack.isNotEmpty) {
          var str = UTF8.decode(stack);
          stack.clear();

          if (str.isNotEmpty && str.codeUnitAt(0) == $esc) return;
          lines.insert(index++, str);

          try {
            var result = samurai.run(str, filename: '<stdin>');
            print(stringifyForJs(result));
          } catch (e) {
            // TODO: Print samurai stack
            stderr.writeln('${e.runtimeType}: $e');
          } finally {
            stdout.write('> ');
          }
        }
      }

      stdin.expand((list) => list).listen((ch) {
        if (ch == $cr || ch == $lf) {
          if (ch == $lf && stack.isNotEmpty && stack.last == $cr)
            stack.removeLast();
          flush();
        } else if (stack.length >= 2 &&
            stack.first == $esc &&
            stack[1] == $lbracket) {
          stack.clear();

          switch (ch) {
            case $A:
              if (index > 0)
                stdout.write('\r> ' + lines[--index]);
              else
                stdout.write('\r> ');
              return;
            case $B:
              if (index < lines.length - 1)
                stdout.write('\r> ' + lines[++index]);
              else
                stdout.write('\r> ');
              return;
            default:
              stdout.write('\r> ');
              return;
          }
        } else {
          stack.add(ch);
        }
      }).onDone(flush);
    } else if (results.rest.isEmpty)
      throw new ArgParserException('no input file');
    else {
      var file = new File(results.rest.first);
      var contents = await file.readAsString();
      var samurai = new Samurai(
          context: applyIo(new SamuraiDefaultContext()),
          debug: results['verbose']);
      samurai.run(contents, filename: file.path);
    }
  } on ArgParserException catch (e) {
    stderr.writeln('fatal error: ${e.message}');
    printHelp(stderr);
    exitCode = 1;
  } catch (e, st) {
    stderr.writeln(e);
    if (results['verbose']) stderr.writeln(st);
  }
}

printHelp(StringSink out) {
  out
    ..writeln('usage: samurai [options...] <filename>')
    ..writeln()
    ..writeln('Options:')
    ..writeln(PARSER.usage);
}
