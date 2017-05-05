import 'package:parsejs/parsejs.dart';
import 'context.dart';
import 'expressions.dart';
import 'package:prototype/prototype.dart';
import 'scope.dart';
import 'values/values.dart';

/// A JavaScript interpreter.
class Samurai extends RecursiveVisitor {
  // TODO: Call stack
  JsContext _context;
  final bool debug;

  /// The root scope in which variables are resolved.
  JsScope scope = new JsScope();

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
    if (node is FunctionExpression) return visitFunctionNode(node.function);
    var result = resolveExpression(printDebug, scope, context, node, this);
    printDebug('Result: $result');
    return result;
  }

  ProtoTypeInstance visitFunctionNode(FunctionNode node) {
    return JsFunction.instance()
      ..samurai$$functionNode = node
      ..samurai$$nativeName = node.name?.value
      ..samurai$$nativeFunction = (ctx, [List args, named]) {
        pushScope();

        for (int i = 0; i < node.params.length; i++) {
          var param = node.params[i];

          if (i < args.length) {
            scope[param.value] = args[i];
          } else
            scope[param.value] = null;
        }

        var r = visitStatement(node.body);
        popScope();
        return r;
      };
  }

  visitFunctionDeclaration(FunctionDeclaration node) {
    var name = node.function.name.value;
    var func = visitFunctionNode(node.function)..samurai$$nativeName = name;
    scope[name] = func;
    return func;
  }

  @override
  visitIf(IfStatement node) {
    var cond = visitExpression(node.condition);
    return visitStatement(isTruthy(cond) ? node.then : node.otherwise);
  }

  @override
  visitProgram(Program node) {
    var result = null;

    // Hoist functions
    for (var stmt in node.body) {
      if (stmt is FunctionDeclaration) result = visitFunctionDeclaration(stmt);
    }

    for (var stmt in node.body) {
      if (stmt is! FunctionDeclaration) result = visitStatement(stmt);
    }

    return result;
  }

  visitStatement(Statement node) {
    if (node == null) return null;

    printDebug('Visiting this ${node.runtimeType}: ${node?.location}');

    if (node is BlockStatement) {
      var result;
      for (var stmt in node.body) result = visitStatement(stmt);
      return result;
    } else if (node is ExpressionStatement)
      return visitExpression(node.expression);
    else if (node is IfStatement)
      return visitIf(node);
    else if (node is ReturnStatement)
      return visitExpression(node.argument);
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

  void pushScope() {
    scope = scope.fork();
  }

  void popScope() {
    scope = scope.parent;
  }
}
