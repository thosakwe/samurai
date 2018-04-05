import 'package:samurai/samurai.dart';
import 'package:test/test.dart';

main() {
  var todo = new JsFunction.anonymous(
    (context, arguments) {},
    name: 'Todo',
  );

  test('toString()', () {
    print(todo);
  });
}
