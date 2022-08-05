import 'dart:convert';
import 'dart:io';

import 'package:custom_events/custom_events.dart';
import 'package:image/image.dart';
import 'package:social_devs_api/exceptions/server_exception.dart';
import 'package:social_devs_api/others/jwt_builder.dart';
import 'package:social_devs_api/others/server_consts.dart';
import 'package:social_devs_api/others/server_repository.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

Future<void> sendMessage(WebSocketChannel socket, Event event) async {
  try {
    final server = ServerRepository.instance;

    final id = JwtBuilder.verify(event.data['token']);

    if (event.data['type'] == 'image') {
      final path = kDebugMode ? '../images/messages' : './app/images/messages';
      final encoded = event.data['image'] as String;
      final image = base64Decode(encoded);

      if (image.isEmpty) {
        final error = Event(
          name: Events.ERROR,
          data: {
            'error': 'Falha ao carregar a imagem!',
          },
        );

        return socket.sink.add(error.toJson());
      }

      final inKB = image.lengthInBytes / 1024;
      final inMB = inKB / 1024;

      if (inMB > 2.0) {
        final error = Event(
          name: Events.ERROR,
          data: {
            'error': 'Tamanho máximo permitido é de 2Mb!',
          },
        );

        return socket.sink.add(error.toJson());
      }

      final decoded = decodeImage(image)!;

      if (!await Directory(path).exists()) {
        await Directory(path).create(recursive: true);
      }

      final now = DateTime.now().toUtc().millisecondsSinceEpoch;
      final filename = '$now-$id.jpeg';

      await File('$path/$filename').writeAsBytes(
        encodeJpg(decoded, quality: 85),
      );

      final values = {
        'message': filename,
        'type': 'image',
        'sender_id': id,
        'receiver_id': event.data['receiver_id'],
      };

      await server.insertMessage(values);
    } else {
      await server.insertMessage({...event.data, 'sender_id': id});
    }

    final messages = await server.selectMessages(id, event.data['receiver_id']);

    final response = Event(
      name: Events.GET_MESSAGES,
      data: {
        'messages': messages.map((e) => e.toMap()).toList(),
      },
    );

    if (server.clientExists(event.data['receiver_id'])) {
      final fChats = await server.selectChats(event.data['receiver_id']);

      final fChatsEvent = Event(
        name: Events.GET_CHATS,
        data: {
          'messages': fChats.map((e) => e.toMap()).toList(),
        },
      );

      final receiver = server.getClient(event.data['receiver_id'])!;

      receiver.socket.sink.add(response.toJson());

      receiver.socket.sink.add(fChatsEvent.toJson());
    }

    final uChats = await server.selectChats(id);

    final uChatsEvent = Event(
      name: Events.GET_CHATS,
      data: {
        'messages': uChats.map((e) => e.toMap()).toList(),
      },
    );

    socket.sink.add(uChatsEvent.toJson());

    socket.sink.add(response.toJson());

    return;
  } on ServerException catch (e) {
    final response = Event(
      name: Events.ERROR,
      data: {
        'error': e.error,
      },
    );

    return socket.sink.add(response.toJson());
  } on Exception catch (e) {
    final response = Event(
      name: Events.ERROR,
      data: {
        'error': e.toString(),
      },
    );

    return socket.sink.add(response.toJson());
  }
}
