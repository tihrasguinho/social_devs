import 'dart:typed_data';

import 'package:asuka/asuka.dart' as asuka;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:social_devs_app/src/core/models/message_model.dart';
import 'package:social_devs_app/src/core/others/custom_uno.dart';
import 'package:uno/uno.dart';

class ChatRepository {
  final CustomUno _customUno;

  ChatRepository(this._customUno);

  final app = Hive.box('app');

  // * GET LIST MESSAGES

  Future<List<MessageModel>?> getMessages(String friendId) async {
    try {
      final response = await _customUno.uno.get('/messages/get-messages/$friendId');

      final list = response.data['messages'] as List;

      return list.map((e) => MessageModel.fromMap(e)).toList();
    } on UnoError catch (e) {
      asuka.AsukaSnackbar.warning(
        e.response?.data['error'] ?? 'Falha ao enviar a mensagem!',
      ).show();

      return null;
    } on Exception catch (e) {
      asuka.AsukaSnackbar.warning('Falha: ${e.toString()}').show();

      return null;
    }
  }

  // * SEND IMAGE MESSAGE

  Future<void> sendImageMessage(Uint8List image, String filename, String friendID) async {
    try {
      final form = FormData();

      final mime = filename.split('.').last;

      form.addBytes(
        'image',
        image,
        contentType: 'image/$mime',
        filename: filename,
      );

      form.add('receiver_id', friendID);

      await _customUno.uno.post(
        '/messages/send-image-message',
        data: form,
      );
    } on UnoError catch (e) {
      return asuka.AsukaSnackbar.warning(
        e.response?.data['error'] ?? 'Falha ao enviar a mensagem!',
      ).show();
    } on Exception catch (e) {
      return asuka.AsukaSnackbar.warning('Falha: ${e.toString()}').show();
    }
  }

  // * SEND VIDEO MESSAGE

  Future<void> sendVideoMessage(Uint8List video, String filename, String friendID) async {
    try {
      final form = FormData();

      final mime = filename.split('.').last;

      form.addBytes(
        'video',
        video,
        contentType: 'video/$mime',
        filename: filename,
      );

      form.add('receiver_id', friendID);

      await _customUno.uno.post(
        '/messages/send-video-message',
        data: form,
      );
    } on UnoError catch (e) {
      return asuka.AsukaSnackbar.warning(
        e.response?.data['error'] ?? 'Falha ao enviar a mensagem!',
      ).show();
    } on Exception catch (e) {
      return asuka.AsukaSnackbar.warning('Falha: ${e.toString()}').show();
    }
  }

  // * SEND TEXT MESSAGE

  Future<void> sendTextMessage(String message, String friendId) async {
    try {
      await _customUno.uno.post(
        '/messages/send-text-message',
        data: {
          'message': message,
          'receiver_id': friendId,
        },
      );
    } on UnoError catch (e) {
      return asuka.AsukaSnackbar.warning(
        e.response?.data['error'] ?? 'Falha ao enviar a mensagem!',
      ).show();
    } on Exception catch (e) {
      return asuka.AsukaSnackbar.warning('Falha: ${e.toString()}').show();
    }
  }
}
