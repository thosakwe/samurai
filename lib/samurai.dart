library samurai;

import 'src/context.dart';
export 'src/values/values.dart';
export 'src/context.dart';
export 'src/interpreter.dart';
export 'src/scope.dart';
export 'src/value.dart';
export 'src/variable.dart';

/// Runs on a [JsContext]; usually used to add new functionality to a JS environment.
abstract class JsPolyfill {
  void call(JsContext context);
}

JsContext createJsContext({JsContext context, Iterable<JsPolyfill> polyfills}) {
  var ctx = context ?? new SamuraiDefaultContext();
  if (polyfills?.isNotEmpty == true) polyfills.forEach((p) => p(ctx));
  return ctx;
}
