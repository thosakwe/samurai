import 'package:samurai/samurai.dart';
import 'package:test/test.dart';

main() {
  test('undefined', () {
    var samurai = new Samurai();
    samurai.run('''
    var b = this;
    ''');

    expect(samurai.scope.getVariable('b'), isNotNull);
    expect(samurai.scope['b'], equals(samurai.scope.thisContext));
    expect(samurai.scope['b'], equals(samurai.context.global));
  });
}