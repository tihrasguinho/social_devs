// ignore_for_file: public_member_api_docs, sort_constructors_first, depend_on_referenced_packages
import 'package:web_socket_channel/web_socket_channel.dart';

class ClientEntity {
  final String id;
  final WebSocketChannel socket;

  ClientEntity({
    required this.id,
    required this.socket,
  });
}
