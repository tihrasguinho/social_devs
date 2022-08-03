import 'package:bubble/bubble.dart';
import 'package:custom_events/custom_events.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:social_devs_app/src/core/models/message_model.dart';
import 'package:social_devs_app/src/core/models/user_model.dart';
import 'package:social_devs_app/src/modules/main/main_controller.dart';

import 'chat_controller.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key, required this.friendId}) : super(key: key);

  final String friendId;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final MainController main = Modular.get();
  final ChatController controller = Modular.get();

  late UserModel friend;

  @override
  void initState() {
    super.initState();

    friend = controller.getFriend(widget.friendId);

    final event = Event(
      name: Events.GET_MESSAGES,
      data: {
        'receiver_id': friend.id,
        'token': 'Bearer ${controller.app.get('access_token')}',
      },
    );

    main.sendEvent(event);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(friend.name),
      ),
      body: Column(
        children: [
          Expanded(
            child: ValueListenableBuilder<List<MessageModel>>(
              valueListenable: controller.messagesNotifier,
              builder: (context, messages, child) {
                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.only(bottom: 4.0),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final model = messages[index];

                    return Bubble(
                      margin: BubbleEdges.only(
                        right: model.isMe ? 16.0 : 100.0,
                        left: model.isMe ? 100.0 : 16.0,
                        bottom: 4.0,
                        top: 4.0,
                      ),
                      padding: const BubbleEdges.only(
                        left: 16.0,
                        right: 16.0,
                        bottom: 8.0,
                        top: 12.0,
                      ),
                      alignment: model.isMe ? Alignment.centerRight : Alignment.centerLeft,
                      nip: model.isMe ? BubbleNip.rightBottom : BubbleNip.leftBottom,
                      radius: const Radius.circular(16.0),
                      elevation: 2,
                      color: model.isMe ? Theme.of(context).primaryColor : Colors.white,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            model.message,
                            style: Theme.of(context).textTheme.subtitle1!.copyWith(
                                  color: model.isMe ? Colors.white : Colors.black,
                                ),
                          ),
                          Text(
                            model.time,
                            style: Theme.of(context).textTheme.overline!.copyWith(
                                  color: model.isMe ? Colors.white60 : Colors.black54,
                                ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Material(
            color: Colors.white,
            elevation: 4,
            child: Row(
              children: [
                Flexible(
                  child: TextField(
                    maxLines: 5,
                    minLines: 1,
                    controller: controller.input,
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      hintText: 'Escreva algo...',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => controller.sendMessage(friend.id),
                  icon: Transform.rotate(
                    angle: -0.5,
                    child: const Icon(Icons.send_rounded),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
