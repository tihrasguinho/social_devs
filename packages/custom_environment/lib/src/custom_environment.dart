import 'dart:io';

import 'package:custom_environment/src/custom_consts.dart';

class CustomEnvironment {
  static final Map<String, String> _map = {};

  Map<String, String> get values => _map;

  CustomEnvironment._() {
    _init();
  }

  static CustomEnvironment get instance => CustomEnvironment._();

  void _init() async {
    if (kDebugMode) {
      final file = File('.env');

      if (!file.existsSync()) {
        throw Exception('File .env not found!');
      }

      final lines = file.readAsLinesSync()..removeWhere((e) => e.isEmpty);

      for (var line in lines) {
        _map[line.split('=').first] = line.split('=').skip(1).toList().join('=');
      }
    } else {
      _map.addAll(Platform.environment);
    }
  }

  T get<T>(String key) {
    if (!_map.containsKey(key)) {
      throw Exception('Key not found!');
    }

    return _getType(T, _map[key]!);
  }

  dynamic _getType(Type type, String value) {
    switch (type) {
      case String:
        {
          return value.toString();
        }
      case int:
        {
          return int.parse(value);
        }

      case double:
        {
          return double.parse(value);
        }
      default:
        {
          return value.toString();
        }
    }
  }
}
