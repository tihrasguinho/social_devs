import 'package:flutter_modular/flutter_modular.dart';

import 'chat/bloc/chat_bloc.dart';
import 'chat/chat_repository.dart';
import 'main_controller.dart';
import 'main_page.dart';

import 'chat/chat_controller.dart';
import 'chat/chat_page.dart';

import 'home/home_controller.dart';
import 'home/home_page.dart';

import 'profile/profile_controller.dart';
import 'profile/profile_page.dart';

import 'profile/profile_repository.dart';
import 'search/search_page.dart';
import 'search/search_controller.dart';
import 'search/search_repository.dart';
import 'search/search_bloc.dart';

class MainModule extends Module {
  @override
  List<Bind> get binds => [
        Bind.singleton<MainController>(
          (i) => MainController(),
          onDispose: (controller) => controller.dispose(),
        ),
        Bind.factory<HomeController>((i) => HomeController()),
        Bind.factory<ProfileController>((i) => ProfileController(i(), i())),
        Bind.factory<SearchController>((i) => SearchController(i(), i())),

        // * ProfilePage

        Bind.factory<ProfileRepository>((i) => ProfileRepository(i())),

        // * SearchPage

        Bind.factory<SearchRepository>((i) => SearchRepository(i())),
        Bind.lazySingleton<SearchBloc>((i) => SearchBloc(i())),

        // * ChatPage

        Bind.factory((i) => ChatRepository(i())),
        Bind.factory<ChatController>((i) => ChatController(i())),
        Bind.lazySingleton<ChatBloc>((i) => ChatBloc(i(), i())),
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
