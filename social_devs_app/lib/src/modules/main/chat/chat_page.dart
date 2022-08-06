import 'package:bubble/bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:social_devs_app/src/core/models/user_model.dart';
import 'package:social_devs_app/src/core/widgets/video_view_widget.dart';
import 'package:social_devs_app/src/modules/main/chat/bloc/chat_bloc.dart';

import 'chat_controller.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key, required this.friendId}) : super(key: key);

  final String friendId;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ChatController controller = Modular.get();

  final ChatBloc bloc = Modular.get();

  late UserModel friend;

  @override
  void initState() {
    super.initState();

    friend = controller.getFriend(widget.friendId);

    bloc.add(GetMessages(friend.id));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundImage: friend.thumbnail.isEmpty ? null : NetworkImage(friend.thumbnail),
            ),
            const SizedBox(width: 8.0),
            Text(friend.name),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<ChatBloc, ChatState>(
              bloc: bloc,
              builder: (context, state) {
                if (state is LoadingMessages) {
                  return const Center(child: CircularProgressIndicator());
                }

                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.only(bottom: 4.0),
                  itemCount: state.messages.length,
                  itemBuilder: (context, index) {
                    final model = state.messages[index];

                    return Bubble(
                      margin: BubbleEdges.only(
                        right: model.isMe ? 16.0 : 128.0,
                        left: model.isMe ? 128.0 : 16.0,
                        bottom: 4.0,
                        top: 4.0,
                      ),
                      padding: model.isImage || model.isVideo
                          ? null
                          : const BubbleEdges.only(
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
                      style: const BubbleStyle(
                        padding: BubbleEdges.all(0.0),
                      ),
                      child: model.isImage
                          ? ConstrainedBox(
                              constraints: const BoxConstraints(
                                maxWidth: 196.0,
                              ),
                              child: Material(
                                clipBehavior: Clip.antiAlias,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(16.0),
                                  topRight: Radius.circular(16.0),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Image.network(
                                      model.message,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        right: 16.0,
                                        bottom: 8.0,
                                        top: 8.0,
                                      ),
                                      child: Text(
                                        model.time,
                                        style: Theme.of(context).textTheme.overline!.copyWith(
                                              color: model.isMe ? Colors.white60 : Colors.black54,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : model.isVideo
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Material(
                                      clipBehavior: Clip.antiAlias,
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(16.0),
                                        topRight: Radius.circular(16.0),
                                      ),
                                      child: VideoViewWidget(url: model.message),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        right: 16.0,
                                        bottom: 8.0,
                                        top: 8.0,
                                      ),
                                      child: Text(
                                        model.time,
                                        style: Theme.of(context).textTheme.overline!.copyWith(
                                              color: model.isMe ? Colors.white60 : Colors.black54,
                                            ),
                                      ),
                                    ),
                                  ],
                                )
                              : Column(
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
                  onPressed: () => controller.sendVideoMessage(friend.id),
                  icon: Transform.rotate(
                    angle: 0,
                    child: const Icon(Icons.attach_file),
                  ),
                ),
                IconButton(
                  onPressed: () => controller.sendTextMessage(friend.id),
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
