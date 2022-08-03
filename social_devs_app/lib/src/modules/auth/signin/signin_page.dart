import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

import 'signin_controller.dart';

class SigninPage extends StatefulWidget {
  const SigninPage({Key? key}) : super(key: key);

  @override
  State<SigninPage> createState() => _SigninPageState();
}

class _SigninPageState extends State<SigninPage> {
  final controller = Modular.get<SigninController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 380.0,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'socialDevs',
                style: Theme.of(context).textTheme.headline5,
              ),
              const SizedBox(height: 24.0),
              TextField(
                controller: controller.email,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  labelText: 'Email',
                ),
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: controller.password,
                obscureText: true,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  labelText: 'Senha',
                ),
              ),
              const SizedBox(height: 16.0),
              MaterialButton(
                onPressed: () => controller.signIn(),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                color: Theme.of(context).primaryColorDark,
                child: SizedBox(
                  height: 46,
                  child: Center(
                    child: Text(
                      'Entrar',
                      style: Theme.of(context).textTheme.button!.copyWith(
                            color: Colors.white,
                          ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              TextButton(
                onPressed: () => Modular.to.navigate('/auth/signup'),
                child: const Text('Criar uma nova conta!'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
