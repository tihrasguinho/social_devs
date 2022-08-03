import 'package:custom_events/custom_events.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:social_devs_app/src/core/models/message_model.dart';
import 'package:social_devs_app/src/core/models/user_model.dart';
import 'package:social_devs_app/src/modules/main/main_controller.dart';

class ChatController {
  final friends = Hive.box<UserModel>('friends');
  final app = Hive.box('app');

  final input = TextEditingController();

  final messagesNotifier = ValueNotifier<List<MessageModel>>([]);

  List<MessageModel> get messages => messagesNotifier.value;

  void setMessages(List<MessageModel> msgs) {
    messagesNotifier.value = msgs;
  }

  ChatController() {
    Modular.get<MainController>().socket.listen((message) {
      final event = Event.fromJson(message);

      if (event.name == Events.GET_MESSAGES) {
        final list = event.data['messages'] as List;

        setMessages(list.map((e) => MessageModel.fromMap(e)).toList());
      }
    });
  }

  UserModel getFriend(String id) {
    return friends.get(id)!;
  }

  void sendMessage(String friendId) async {
    if (input.text.isEmpty) return;

    final event = Event(
      name: Events.SEND_MESSAGE,
      data: {
        'receiver_id': friendId,
        'message': input.text,
        'type': 'text',
        'token': 'Bearer ${app.get('access_token')}',
      },
    );

    Modular.get<MainController>().sendEvent(event);

    input.clear();
  }
}
