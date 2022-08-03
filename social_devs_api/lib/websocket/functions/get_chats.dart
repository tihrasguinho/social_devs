import 'package:custom_events/custom_events.dart';
import 'package:social_devs_api/exceptions/server_exception.dart';
import 'package:social_devs_api/others/jwt_builder.dart';
import 'package:social_devs_api/others/server_repository.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

Future<void> getChats(WebSocketChannel socket, Event event) async {
  try {
    final server = ServerRepository.instance;

    final id = JwtBuilder.verify(event.data['token']);

    final messages = await server.selectChats(id);

    final response = Event(
      name: Events.GET_CHATS,
      data: {
        'messages': messages.map((e) => e.toMap()).toList(),
      },
    );

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
