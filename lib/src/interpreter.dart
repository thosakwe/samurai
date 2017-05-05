import 'package:parsejs/parsejs.dart';
import 'context.dart';
import 'expressions.dart';
import 'scope.dart';
import 'values/values.dart';

/// A JavaScript interpreter.
class Samurai extends RecursiveVisitor {
  // TODO: Call stack
  JsContext _context;
  final bool debug;

  /// The root scope in which variables are resolved.
  final JsScope scope = new JsScope();

  /// The [JsContext] in which code will run.
  JsContext get context => _context;

  Samurai({JsContext context, this.debug: false}) {
    _context = context ?? new SamuraiDefaultContext();
    scope.thisContext = _context.global;
  }

  void printDebug(msg) {
    if (debug == true) print(msg);
  }

  run(String code,
      {String filename,
      int firstLine: 1,
      bool handleNoise: true,
      bool annotations: true}) {
    return visitProgram(parsejs(code,
        filename: filename,
        firstLine: firstLine,
        handleNoise: handleNoise,
        annotations: annotations));
  }

  visitExpression(Expression node) {
    var result = resolveExpression(printDebug, scope, context, node);
    printDebug('Result: $result');
    return result;
  }

  @override
  visitIf(IfStatement node) {
    var cond = visitExpression(node.condition);
    return visitStatement(isTruthy(cond) ? node.then : node.otherwise);
  }

  @override
  visitProgram(Program node) {
    var result = null;

    for (var stmt in node.body) {
      result = visitStatement(stmt);
    }

    return result;
  }

  visitStatement(Statement node) {
    printDebug('Visiting this ${node.runtimeType}: ${node.location}');

    if (node is ExpressionStatement)
      return visitExpression(node.expression);
    else if (node is IfStatement)
      return visitIf(node);
    else if (node is VariableDeclaration) return visitVariableDeclaration(node);
  }

  @override
  visitVariableDeclaration(VariableDeclaration node) {
    for (var decl in node.declarations) {
      var name = decl.name.value;
      var value =
          decl.init != null ? visitExpression(decl.init) : JsNull.instance();
      printDebug('Setting $name to $value...');
      scope.innermost.create(name).value = value;
    }
  }
}
