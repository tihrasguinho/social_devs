import 'package:social_devs_app/src/core/models/user_model.dart';
import 'package:social_devs_app/src/core/others/custom_uno.dart';

import 'package:uno/uno.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:asuka/asuka.dart' as asuka;

class FriendsRepository {
  final CustomUno _customUno;

  FriendsRepository(this._customUno);

  final app = Hive.box('app');

  final friends = Hive.box<UserModel>('friends');

  Future<void> getFriends() async {
    try {
      final response = await _customUno.uno.get('/friends');

      final list = response.data['friends'] as List;

      for (final item in list) {
        final friend = UserModel.fromMap(item);

        await friends.put(friend.id, friend);
      }
    } on UnoError catch (e) {
      return asuka.AsukaSnackbar.warning(e.response?.data['error']).show();
    } on Exception catch (e) {
      return asuka.AsukaSnackbar.warning(e.toString()).show();
    }
  }
}
