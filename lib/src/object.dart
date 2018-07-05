import 'function.dart';

class JsObject {
  final Map<dynamic, JsObject> properties = {};

  //final Map<String, JsObject> prototype = {};
  String typeof = 'object';

  bool get isTruthy => true;

  dynamic get valueOf => properties;

  bool isLooselyEqualTo(JsObject other) {
    // TODO: Finish this stupidity
    return false;
  }

  JsObject getProperty(name) {
//    if (name == 'prototype') {
//      return new JsPrototype(prototype);
//    } else {
    return properties[name];
//    }
  }

  Map<dynamic, JsObject> get prototype {
    return properties['prototype']?.properties ?? <dynamic, JsObject>{};
  }

  JsObject newInstance() {
    var obj = new JsObject();
    var p = prototype;

    for (var key in p.keys) {
      var value = p[key];

      if (value is JsFunction) {
        obj.properties[key] = value.bind(obj);
      } else {
        obj.properties[key] = value;
      }
    }

    return obj;
  }

  @override
  String toString() => '[object Object]';

  JsObject setProperty(name, JsObject value) {
    return properties[name] = value;
  }
}

class JsPrototype extends JsObject {
  @override
  final Map<String, JsObject> properties;

  JsPrototype(this.properties);
}
