import 'package:flutter_modular/flutter_modular.dart';

import 'core/guards/auth_guard.dart';
import 'core/guards/main_guard.dart';

import 'core/others/custom_uno.dart';

import 'modules/auth/auth_module.dart';
import 'modules/main/main_module.dart';

class AppModule extends Module {
  @override
  List<Bind> get binds => [
        Bind.singleton<CustomUno>((i) => CustomUno()),
      ];

  @override
  List<ModularRoute> get routes => [
        ModuleRoute(
          '/',
          module: MainModule(),
          guards: [MainGuard()],
          duration: const Duration(milliseconds: 150),
          transition: TransitionType.fadeIn,
        ),
        ModuleRoute(
          '/auth',
          module: AuthModule(),
          guards: [AuthGuard()],
          duration: const Duration(milliseconds: 150),
          transition: TransitionType.fadeIn,
        ),
      ];
}
