import 'package:samurai/samurai.dart';
import 'package:test/test.dart';

main() {
  test('declare with value', () {
    var samurai = new Samurai(debug: true);
    samurai.run('var one = 1;');

    var one = samurai.scope['one'];
    expect(one.isInstanceOf(JsNumber), isTrue);
    expect(one.isInstanceOf(JsObject), isTrue);
    expect(one.value, equals(1));
  });

  test('declare without value', () {
    var samurai = new Samurai(debug: true);
    samurai.run('var one;');

    var one = samurai.scope['one'];
    expect(one.isInstanceOf(JsNull), isTrue);
    expect(one.isInstanceOf(JsObject), isFalse);
  });

}
