import 'dart:async';

import 'package:flutter_modular/flutter_modular.dart';
import 'package:hive_flutter/hive_flutter.dart';

class MainGuard extends RouteGuard {
  MainGuard() : super(redirectTo: '/auth/signin');

  @override
  FutureOr<bool> canActivate(String path, ParallelRoute route) {
    final app = Hive.box('app');

    return app.get('user') != null ? true : false;
  }
}
