import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

import 'main_controller.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final MainController controller = Modular.get();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: RouterOutlet(),
    );
  }
}
