// ignore_for_file: depend_on_referenced_packages

import 'package:custom_events/custom_events.dart';
import 'package:social_devs_api/entities/client_entity.dart';
import 'package:social_devs_api/exceptions/server_exception.dart';
import 'package:social_devs_api/others/jwt_builder.dart';
import 'package:social_devs_api/others/server_repository.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

void registerUser(
  WebSocketChannel socket,
  Event event,
) {
  try {
    final server = ServerRepository.instance;

    final id = JwtBuilder.verify(event.data['token']);

    server.addClient(ClientEntity(id: id, socket: socket));

    final response = Event(
      name: Events.REGISTER_USER,
      data: {
        'message': 'Conectado com sucesso!',
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
