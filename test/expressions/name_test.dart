import 'package:samurai/samurai.dart';
import 'package:test/test.dart';

main() {
  test('undefined', () {
    var samurai = new Samurai();
    samurai.run('''
    var b = undefined;
    ''');

    expect(samurai.scope.getVariable('b'), isNotNull);
    expect(samurai.scope['b'], isNull);
  });

  test('value', () {
    var samurai = new Samurai();
    samurai.run('''
    var a = 3;
    var b = a;
    ''');

    var b = samurai.scope['b'];
    expect(b.isInstanceOf(JsNumber), isTrue);
    expect(b.samurai$$value, equals(3));
  });
}