import 'package:flutter_modular/flutter_modular.dart';

import 'signin/signin_page.dart';
import 'signin/signin_controller.dart';

import 'signup/signup_page.dart';

class AuthModule extends Module {
  @override
  List<Bind> get binds => [
        Bind.factory<SigninController>((i) => SigninController(i(), i())),
      ];

  @override
  List<ModularRoute> get routes => [
        ChildRoute('/signin', child: (_, __) => const SigninPage()),
        ChildRoute('/signup', child: (_, __) => const SignupPage()),
      ];
}
