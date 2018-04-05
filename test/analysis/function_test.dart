import 'package:code_buffer/code_buffer.dart';
import 'package:samurai/samurai.dart';
import 'package:test/test.dart';

main() {
  var Todo = new JsFunction.anonymous(
    (context, arguments) {
      // this.completed = false;
      context.properties['completed'] =
          new JsProperty.normal('completed', JsBoolean.false$);
    },
    name: 'Todo',
  );

  Todo.prototype.properties['foo'] = new JsProperty.normal('foo');

  var buf = new CodeBuffer()..writeln('Todo:');
  var todo = Todo.newInstance(new JsArgumentList());
  todo.prettyPrint(buf);
  print(buf);

  test('toString()', () {
    expect(Todo.toString(), 'f Todo() { [native code] }');
  });
}
