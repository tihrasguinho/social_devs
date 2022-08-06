import 'package:custom_events/custom_events.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:social_devs_api/others/server_repository.dart';
import 'package:social_devs_api/websocket/functions/get_chats.dart';
import 'package:social_devs_api/websocket/functions/get_messages.dart';
import 'package:social_devs_api/websocket/functions/register_user.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

Handler get wsHandler {
  final router = Router();

  router.get(
    '/ws',
    webSocketHandler((WebSocketChannel socket) {
      final server = ServerRepository.instance;

      socket.stream.listen(
        (data) async {
          final event = Event.fromJson(data);

          switch (event.name) {
            case Events.REGISTER_USER:
              {
                registerUser(socket, event);

                break;
              }
            case Events.GET_MESSAGES:
              {
                await getMessages(socket, event);

                break;
              }
            case Events.GET_CHATS:
              {
                await getChats(socket, event);

                break;
              }
            default:
              {
                break;
              }
          }
        },
        onDone: () {
          server.removeClient(socket);
        },
      );
    }),
  );

  return router;
}
