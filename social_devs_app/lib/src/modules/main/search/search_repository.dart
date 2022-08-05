import 'package:social_devs_app/src/core/models/user_model.dart';
import 'package:social_devs_app/src/core/others/custom_uno.dart';
import 'package:uno/uno.dart';
import 'package:asuka/asuka.dart' as asuka;

class SearchRepository {
  final CustomUno _customUno;

  SearchRepository(this._customUno);

  Future<List<UserModel>> getUsers(String username) async {
    try {
      final response = await _customUno.uno.get('/users?username=$username');

      final list = response.data['users'] as List;

      return list.map((e) => UserModel.fromMap(e)).toList();
    } on UnoError catch (e) {
      asuka.AsukaSnackbar.alert(e.response?.data['error']).show();

      return [];
    } on Exception catch (e) {
      asuka.AsukaSnackbar.alert(e.toString()).show();

      return [];
    }
  }
}
