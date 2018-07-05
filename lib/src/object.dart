import 'package:collection/collection.dart';

class JsObject {
  final Map<dynamic, JsObject> properties = {};
  final Map<String, JsObject> prototype = {};
  String typeof = 'object';

  bool get isTruthy => true;

  dynamic get valueOf => properties;

  bool isLooselyEqualTo(JsObject other) {
    // TODO: Finish this stupidity
    return false;
  }

  JsObject getProperty(name) {
    if (name == 'prototype') {
      return new JsPrototype(prototype);
    } else {
      return properties[name];
    }
  }

  JsObject newInstance() {
    // TODO: Bind functions?
    return new JsObject()..properties.addAll(prototype);
  }

  @override
  String toString() => '[object Object]';
}

class JsPrototype extends JsObject {
  @override
  final Map<String, JsObject> properties;

  JsPrototype(this.properties);
}
