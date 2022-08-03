import 'package:asuka/asuka.dart' as asuka;
import 'package:social_devs_app/src/core/models/user_model.dart';
import 'package:social_devs_app/src/core/others/custom_uno.dart';
import 'package:uno/uno.dart';

class SearchController {
  final CustomUno _customUno;

  SearchController(this._customUno);

  Future<List<UserModel>?> getUsers() async {
    try {
      final response = await _customUno.uno.get('/users');

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

  Future sendFriendRequest(String friendId) async {
    try {
      final response = await _customUno.uno.post(
        '/friends/send-request',
        data: {
          'friend_id': friendId,
        },
      );

      return asuka.AsukaSnackbar.success(response.data['message']).show();
    } on UnoError catch (e) {
      return asuka.AsukaSnackbar.alert(e.response?.data['error']).show();
    } on Exception catch (e) {
      return asuka.AsukaSnackbar.alert(e.toString()).show();
    }
  }
}
