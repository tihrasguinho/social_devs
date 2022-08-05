import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:social_devs_app/src/core/models/request_model.dart';
import 'package:social_devs_app/src/core/models/user_model.dart';
import 'package:social_devs_app/src/core/others/custom_uno.dart';
import 'package:asuka/asuka.dart' as asuka;
import 'package:uno/uno.dart';

import 'profile_repository.dart';

class ProfileController {
  final CustomUno _customUno;
  final ProfileRepository _repository;

  ProfileController(this._customUno, this._repository);

  final friends = Hive.box<UserModel>('friends');

  final requests = ValueNotifier<List<RequestModel>>([]);

  void updateFriendList(List<UserModel> list) async {
    for (var item in list) {
      await friends.put(item.id, item);
    }
  }

  void updateList(List<RequestModel> list) {
    requests.value = list;
  }

  void removeRequestItem(String id) {
    if (kDebugMode) print(requests.value.any((e) => e.requestId == id));

    requests.value = requests.value..removeWhere((e) => e.requestId == id);
  }

  Future<void> getFriendRequests() async {
    try {
      final response = await _customUno.uno.get('/friends/requests');

      final list = response.data['requests'] as List;

      updateList(list.map((e) => RequestModel.fromMap(e)).toList());
    } on UnoError catch (e) {
      return asuka.AsukaSnackbar.alert(e.response?.data['error']).show();
    } on Exception catch (e) {
      return asuka.AsukaSnackbar.alert(e.toString()).show();
    }
  }

  Future<void> acceptFriend(String requestId) async {
    try {
      final response = await _customUno.uno.post(
        '/friends/respond-to-request',
        data: {
          'request_id': requestId,
          'status': true,
        },
      );

      removeRequestItem(requestId);

      return asuka.AsukaSnackbar.success(response.data['message']).show();
    } on UnoError catch (e) {
      return asuka.AsukaSnackbar.alert(e.response?.data['error']).show();
    } on Exception catch (e) {
      return asuka.AsukaSnackbar.alert(e.toString()).show();
    }
  }

  Future<void> getFriends() async {
    try {
      final response = await _customUno.uno.get('/friends');

      final list = response.data['friends'] as List;

      updateFriendList(list.map((e) => UserModel.fromMap(e)).toList());
    } on UnoError catch (e) {
      return asuka.AsukaSnackbar.alert(e.response?.data['error']).show();
    } on Exception catch (e) {
      return asuka.AsukaSnackbar.alert(e.toString()).show();
    }
  }

  Future changePhoto() async {
    await _repository.changePhoto();
  }
}
