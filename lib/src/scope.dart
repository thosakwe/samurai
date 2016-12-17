import 'package:prototype/prototype.dart';
import 'variable.dart';

/// A tree of scopes usable in closures.
class JsScope {
  JsScope parent, child;
  ProtoTypeInstance thisContext;
  final List<JsVariable> variables = [];

  /// The most specific [JsScope] within this tree.
  JsScope get innermost {
    JsScope search = this;

    while (search.child != null) search = search.child;

    return search;
  }

  /// Gets the innermost `this` context.
  ProtoTypeInstance get innermostThis {
    JsScope search = innermost;

    while (search != null) {
      if (search.thisContext != null) {
        return search.thisContext;
      }

      search = search.parent;
    }

    return null;
  }

  ProtoTypeInstance operator [](String name) => getValue(name);

  void operator []=(String name, ProtoTypeInstance value) {
    setValue(name, value);
  }

  /// Creates an empty [JsVariable] with the given [name] at the current level.
  JsVariable create(String name) {
    var variable = new JsVariable(name);
    variables.add(variable);
    return variable;
  }

  /// Creates, and returns, a new [JsScope] within [innermost].
  JsScope fork() {
    var target = innermost;
    var child = new JsScope()..parent = target;
    target.child = child;
    return child;
  }

  /// Finds the first [JsVariable] with the given [name].
  JsVariable getVariable(String name) {
    var search = innermost;

    do {
      for (var variable in search.variables) {
        if (variable.name == name) return variable;
      }

      search = search.parent;
    } while (search != null);

    return null;
  }

  /// Resolves the first value with the given name.
  ProtoTypeInstance getValue(String name) => getVariable(name)?.value;

  /// Resolves the given [name], or creates a new [JsVariable].
  JsVariable resolveOrCreate(String name) =>
      getVariable(name) ?? innermost.create(name);

  /// Sets a [value] for [name] in the innermost scope possible.
  JsVariable setValue(String name, ProtoTypeInstance value) =>
      resolveOrCreate(name)..value = value;
}
