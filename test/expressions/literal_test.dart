import 'package:samurai/samurai.dart';
import 'package:test/test.dart';

main() {
  group('bool', () {
    test('true', () {
      final samurai = new Samurai();
      samurai.run('var x = true;');
      var x = samurai.scope['x'];

      expect(x.isInstanceOf(JsBoolean), isTrue);
      expect(x.isInstanceOf(JsObject), isTrue);
      expect(x.samurai$$value, isTrue);
    });

    test('false', () {
      final samurai = new Samurai();
      samurai.run('var x = false;');
      var x = samurai.scope['x'];

      expect(x.isInstanceOf(JsBoolean), isTrue);
      expect(x.isInstanceOf(JsObject), isTrue);
      expect(x.samurai$$value, isFalse);
    });
  });
}
