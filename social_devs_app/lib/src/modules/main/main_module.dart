import 'package:flutter_modular/flutter_modular.dart';

import 'main_controller.dart';
import 'main_page.dart';

import 'chat/chat_controller.dart';
import 'chat/chat_page.dart';

import 'home/home_controller.dart';
import 'home/home_page.dart';

import 'profile/profile_controller.dart';
import 'profile/profile_page.dart';

import 'search/search_controller.dart';
import 'search/search_page.dart';

class MainModule extends Module {
  @override
  List<Bind> get binds => [
        Bind.singleton<MainController>(
          (i) => MainController(),
          onDispose: (controller) => controller.dispose(),
        ),
        Bind.factory<HomeController>((i) => HomeController()),
        Bind.factory<ProfileController>((i) => ProfileController(i())),
        Bind.factory<SearchController>((i) => SearchController(i())),
        Bind.factory<ChatController>((i) => ChatController()),
      ];

  @override
  List<ModularRoute> get routes => [
        ChildRoute(
          '/',
          child: (_, __) => const MainPage(),
          children: [
            ChildRoute('/home', child: (_, __) => const HomePage()),
            ChildRoute(
              '/search',
              child: (_, __) => const SearchPage(),
              transition: TransitionType.rightToLeftWithFade,
            ),
            ChildRoute(
              '/profile',
              child: (_, __) => const ProfilePage(),
              transition: TransitionType.rightToLeftWithFade,
            ),
            ChildRoute(
              '/chat/:friendId',
              child: (_, args) => ChatPage(
                friendId: args.params['friendId'],
              ),
              transition: TransitionType.rightToLeftWithFade,
            ),
          ],
        ),
      ];
}
