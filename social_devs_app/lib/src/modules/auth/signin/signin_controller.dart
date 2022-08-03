import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:social_devs_app/src/core/models/user_model.dart';
import 'package:uno/uno.dart';
import 'package:social_devs_app/src/core/others/custom_uno.dart';
import 'package:asuka/asuka.dart' as asuka;

class SigninController {
  final CustomUno _customUno;

  SigninController(this._customUno);

  final email = TextEditingController();
  final password = TextEditingController();

  final entry = OverlayEntry(
    builder: (_) => Container(
      color: Colors.white54,
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    ),
  );

  Future signIn() async {
    try {
      if (email.text.isEmpty || password.text.isEmpty) {
        return asuka.AsukaSnackbar.alert('Campos obrigatórios faltando!').show();
      }

      asuka.addOverlay(entry);

      final app = Hive.box('app');

      final response = await _customUno.uno.post(
        '/auth/signin',
        data: {
          'email': email.text,
          'password': password.text,
        },
      );

      final user = UserModel.fromMap(response.data['user']);

      await app.put('user', user.toJson());
      await app.put('access_token', response.data['access_token']);
      await app.put('refresh_token', response.data['refresh_token']);

      entry.remove();

      return Modular.to.navigate('/home');
    } on UnoError catch (e) {
      entry.remove();
      return asuka.AsukaSnackbar.alert(e.response?.data['error']).show();
    } on Exception catch (e) {
      entry.remove();
      return asuka.AsukaSnackbar.alert(e.toString()).show();
    }
  }
}
