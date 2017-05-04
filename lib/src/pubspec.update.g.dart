import 'dart:async';
import 'dart:convert';
import 'package:http/src/base_client.dart' as http;
import 'package:pub_semver/pub_semver.dart';

final Version PACKAGE_VERSION = new Version(0, 0, 0);
Future<Version> fetchCurrentVersion(http.BaseClient client) async {
  var response =
      await client.get('https://pub.dartlang.org/api/packages/samurai');
  var json = JSON.decode(response.body) as Map;
  if (!(json.containsKey('latest')) ||
      !(json['latest'].containsKey('pubspec')) ||
      !(json['latest']['pubspec'].containsKey('version'))) {
    throw new StateError(
        'GET https://pub.dartlang.org/api/packages/samurai returned an invalid pub API response.');
  }
  return new Version.parse(json['latest']['pubspec']['version']);
}

Future<Version> checkForUpdate(http.BaseClient client) async {
  var current = await fetchCurrentVersion(client);
  if (PACKAGE_VERSION.compareTo(current) < 0) {
    return current;
  }
  return null;
}
