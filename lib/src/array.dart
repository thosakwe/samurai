import 'object.dart';

class JsArray extends JsObject {
  final List<JsObject> valueOf = [];

  JsArray() {
    typeof = 'array';
  }

  // TODO: Set index???
  // TODO: Value of

  @override
  String toString() {
    if (valueOf.isEmpty) {
      return '';
    } else if (valueOf.length == 1) {
      return valueOf[0].toString();
    } else {
      return valueOf.map((x) => x.toString()).join(',');
    }
  }

  @override
  JsObject getProperty(name) {
    if (name is num) {
      // TODO: RangeError?
      return valueOf[name.toInt()];
    } else {
      return super.getProperty(name);
    }
  }
}
