import 'package:asuka/asuka.dart' as asuka;
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:social_devs_app/src/core/models/user_model.dart';

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
}
