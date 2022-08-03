import 'package:custom_events/custom_events.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:social_devs_app/src/core/others/app_consts.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class MainController {
  final app = Hive.box('app');

  final _socket = WebSocketChannel.connect(Uri.parse(WS_URL));

  late final socket = _socket.stream.asBroadcastStream();

  void sendEvent(Event event) => _socket.sink.add(event.toJson());

  MainController() {
    registerUser();
  }

  void registerUser() {
    final event = Event(
      name: Events.REGISTER_USER,
      data: {
        'token': 'Bearer ${app.get('access_token')}',
      },
    );

    sendEvent(event);
  }

  void dispose() {
    _socket.sink.close();
  }
}
