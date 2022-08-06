import 'package:asuka/asuka.dart' as asuka;
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:social_devs_app/src/core/models/user_model.dart';
import 'package:social_devs_app/src/core/widgets/video_view_widget.dart';

import 'chat_repository.dart';

class ChatController {
  final ChatRepository _repository;

  final friends = Hive.box<UserModel>('friends');

  final app = Hive.box('app');

  final picker = ImagePicker();

  final input = TextEditingController();

  ChatController(this._repository);

  UserModel getFriend(String id) {
    return friends.get(id)!;
  }

  // ? Send TEXT message

  void sendTextMessage(String friendId) async {
    if (input.text.isEmpty) return;

    await _repository.sendTextMessage(input.text, friendId);

    input.clear();
  }

  // ? Send IMAGE message

  void sendImageMessage(String friendId) async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) {
      return asuka.AsukaSnackbar.warning('Falha ao carregar imagem!').show();
    }

    final name = pickedFile.name;

    final image = await pickedFile.readAsBytes();

    await _repository.sendImageMessage(image, name, friendId);
  }

  // ? Send VIDEO message

  void sendVideoMessage(String friendId) async {
    final pickedFile = await picker.pickVideo(source: ImageSource.gallery);

    if (pickedFile == null) {
      return asuka.AsukaSnackbar.warning('Falha ao carregar imagem!').show();
    }

    final name = pickedFile.name;

    final video = await pickedFile.readAsBytes();

    await _repository.sendVideoMessage(video, name, friendId);
  }

  // ? PopUP Image

  void openImage(String url) async {
    await asuka.showDialog(
      barrierColor: Colors.black38,
      builder: (context) {
        return Dialog(
          clipBehavior: Clip.antiAlias,
          child: Image.network(
            url,
            fit: BoxFit.cover,
          ),
        );
      },
    );
  }

  // ? PopUP Video

  void openVideo(String url) async {
    await asuka.showDialog(
      barrierColor: Colors.black38,
      builder: (context) {
        return Dialog(
          clipBehavior: Clip.antiAlias,
          child: VideoViewWidget(url: url),
        );
      },
    );
  }
}
