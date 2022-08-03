import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:social_devs_app/src/core/models/user_model.dart';

import 'src/app_module.dart';
import 'src/app_widget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  Hive.registerAdapter(UserAdapter());

  await Hive.openBox<UserModel>('friends');

  final app = await Hive.openBox('app');

  if (!app.containsKey('user')) await app.put('user', null);

  runApp(ModularApp(module: AppModule(), child: const AppWidget()));
}
