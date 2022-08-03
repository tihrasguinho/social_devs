import 'package:custom_events/custom_events.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:social_devs_app/src/core/models/chat_model.dart';
import 'package:social_devs_app/src/core/models/message_model.dart';
import 'package:social_devs_app/src/core/models/user_model.dart';
import 'package:social_devs_app/src/modules/main/main_controller.dart';

class HomeController {
  final app = Hive.box('app');
  final friends = Hive.box<UserModel>('friends');

  final _items = [
    'Perfil',
    'Procurar',
    'Configurações',
    'Sair',
  ];

  List<PopupMenuItem<String>> get items {
    final data = <PopupMenuItem<String>>[];

    for (var i = 0; i < _items.length; i++) {
      data.add(
        PopupMenuItem<String>(
          value: _items[i],
          child: Text(_items[i]),
        ),
      );
    }

    return data;
  }

  actions(String? value) async {
    switch (value) {
      case 'Perfil':
        {
          return Modular.to.navigate('/profile');
        }
      case 'Procurar':
        {
          return Modular.to.navigate('/search');
        }
      case 'Sair':
        {
          return await signOut();
        }
      default:
        {
          return;
        }
    }
  }

  final chats = ValueNotifier<List<ChatModel>>([]);

  void sortChats() {
    chats.value.sort((a, b) => b.message.createdAt.compareTo(a.message.createdAt));
    chats.value = List<ChatModel>.from(chats.value);
  }

  void addChat(ChatModel chat) {
    if (chats.value.any((e) => e.friend.id == chat.friend.id)) {
      removeChat(chat);
      chats.value.add(chat);
      sortChats();
    } else {
      chats.value.add(chat);
      sortChats();
    }
  }

  void removeChat(ChatModel chat) {
    chats.value.removeWhere((e) => e.friend.id == chat.friend.id);
    sortChats();
  }

  HomeController() {
    Modular.get<MainController>().socket.listen((data) {
      final event = Event.fromJson(data);

      if (event.name == Events.GET_CHATS) {
        final list = event.data['messages'] as List;

        final messages = list.map((e) => MessageModel.fromMap(e)).toList();

        for (var message in messages) {
          final userId = message.isMe ? message.receiverId : message.senderId;

          if (friends.containsKey(userId)) {
            addChat(
              ChatModel(
                friend: friends.get(userId)!,
                message: message,
              ),
            );
          }
        }
      }
    });

    final event = Event(
      name: Events.GET_CHATS,
      data: {
        'token': 'Bearer ${app.get('access_token')}',
      },
    );

    Modular.get<MainController>().sendEvent(event);
  }

  Future signOut() async {
    await app.delete('access_token');
    await app.delete('refresh_token');
    await friends.clear();
    await app.put('user', null);

    return Modular.to.navigate('/auth/signin');
  }
}
