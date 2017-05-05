import 'package:samurai/samurai.dart';
import 'package:test/test.dart';

main() {
  test('global', () {
    var samurai = new Samurai(debug: true);
    samurai.run('''
    var x = global.samurai;
    ''');

    var x = samurai.scope['x'];
    expect(x.isInstanceOf(JsBoolean), isTrue);
    expect(x.samurai$$value, isTrue);
  });

  test('this', () {
    var samurai = new Samurai();
    samurai.run('''
    var x = this.samurai;
    ''');

    var x = samurai.scope['x'];
    expect(x.isInstanceOf(JsBoolean), isTrue);
    expect(x.samurai$$value, isTrue);
  });
}