import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:social_devs_app/src/core/models/chat_model.dart';

import 'home_controller.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late HomeController controller;

  @override
  void initState() {
    super.initState();

    controller = Modular.get<HomeController>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('socialDevs'),
        actions: [
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (context) => controller.items,
            onSelected: controller.actions,
          ),
        ],
      ),
      body: ValueListenableBuilder<List<ChatModel>>(
        valueListenable: controller.chats,
        builder: (context, chats, child) {
          return ListView.builder(
            padding: const EdgeInsets.only(top: 16.0),
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              final friend = chat.friend;
              final message = chat.message;

              return Tooltip(
                message: 'Clique para falar com ${friend.name}',
                waitDuration: const Duration(milliseconds: 500),
                child: ListTile(
                  onTap: () {
                    if (kIsWeb) {
                      Modular.to.navigate('/chat/${friend.id}');
                    } else {
                      Modular.to.pushNamed('/chat/${friend.id}');
                    }
                  },
                  title: Text(friend.name),
                  subtitle: message.isImage || message.isVideo
                      ? Row(
                          children: [
                            Icon(
                              message.isImage ? Icons.image : Icons.video_collection_rounded,
                              size: 16,
                            ),
                            const SizedBox(width: 4.0),
                            Text(message.isImage ? 'Imagem' : 'Video'),
                            const SizedBox(width: 4.0),
                            message.isMe
                                ? const Icon(Icons.check_circle_outline_rounded, size: 16)
                                : const SizedBox()
                          ],
                        )
                      : Row(
                          children: [
                            Text(message.isMe ? '"${message.message}"' : message.message),
                            const SizedBox(width: 4.0),
                            message.isMe
                                ? const Icon(Icons.check_circle_outline_rounded, size: 16)
                                : const SizedBox()
                          ],
                        ),
                  leading: CircleAvatar(
                    radius: 36,
                    backgroundImage:
                        friend.thumbnail.isEmpty ? null : NetworkImage(friend.thumbnail),
                  ),
                  trailing: Text(
                    message.time,
                    style: Theme.of(context).textTheme.overline,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
