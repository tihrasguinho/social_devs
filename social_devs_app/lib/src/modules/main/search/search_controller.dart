import 'dart:async';

import 'package:uno/uno.dart';
import 'package:flutter/material.dart';
import 'package:asuka/asuka.dart' as asuka;
import 'package:social_devs_app/src/core/models/user_model.dart';
import 'package:social_devs_app/src/core/others/custom_uno.dart';

import 'search_bloc.dart';
import 'search_events.dart';

class SearchController {
  final CustomUno _customUno;
  final SearchBloc _bloc;

  SearchController(this._customUno, this._bloc);

  final input = TextEditingController();

  final searching = ValueNotifier<bool>(false);

  final users = ValueNotifier<List<UserModel>>([]);

  Timer? debounce;

  void setSearching(bool value) {
    searching.value = value;
  }

  void searchByUsername(String text) {
    if (debounce?.isActive ?? false) debounce?.cancel();

    debounce = Timer(const Duration(milliseconds: 500), () async {
      _bloc.add(GetUsersEvent(text));
    });
  }

  Future<void> getUsers(String username) async {
    try {
      final response = await _customUno.uno.get('/users?username=$username');

      final list = response.data['users'] as List;

      users.value = list.map((e) => UserModel.fromMap(e)).toList();

      return;
    } on UnoError catch (e) {
      return asuka.AsukaSnackbar.alert(e.response?.data['error']).show();
    } on Exception catch (e) {
      return asuka.AsukaSnackbar.alert(e.toString()).show();
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
