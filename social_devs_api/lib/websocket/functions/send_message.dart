import 'package:custom_events/custom_events.dart';
import 'package:social_devs_api/exceptions/server_exception.dart';
import 'package:social_devs_api/others/jwt_builder.dart';
import 'package:social_devs_api/others/server_repository.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

Future<void> sendMessage(WebSocketChannel socket, Event event) async {
  try {
    final server = ServerRepository.instance;

    final id = JwtBuilder.verify(event.data['token']);

    await server.insertMessage({...event.data, 'sender_id': id});

    final messages = await server.selectMessages(id, event.data['receiver_id']);

    final response = Event(
      name: Events.GET_MESSAGES,
      data: {
        'messages': messages.map((e) => e.toMap()).toList(),
      },
    );

    if (server.clientExists(event.data['receiver_id'])) {
      final messages = await server.selectChats(event.data['receiver_id']);

      final chats = Event(
        name: Events.GET_CHATS,
        data: {
          'messages': messages.map((e) => e.toMap()).toList(),
        },
      );

      final receiver = server.getClient(event.data['receiver_id'])!;

      receiver.socket.sink.add(response.toJson());

      receiver.socket.sink.add(chats.toJson());
    }

    return socket.sink.add(response.toJson());
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
