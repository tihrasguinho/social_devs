import 'dart:async';
import 'dart:convert';

import 'package:custom_events/custom_events.dart';
import 'package:shelf/shelf.dart';
import 'package:social_devs_api/exceptions/params_exception.dart';
import 'package:social_devs_api/exceptions/server_exception.dart';
import 'package:social_devs_api/others/server_repository.dart';

FutureOr<Response> sendTextMessageRoute(Request request) async {
  try {
    final server = ServerRepository.instance;

    final body = await request.readAsString();

    final id = request.context['id'] as String;

    final params = _Params.fromJson(body)..validateParams();

    final values = <String, dynamic>{
      'sender_id': id,
      'receiver_id': params.receiver_id,
      'message': params.message,
      'type': 'text',
    };

    await server.insertMessage(values);

    final messages = await server.selectMessages(id, params.receiver_id);

    final event = Event(
      name: Events.GET_MESSAGES,
      data: {
        'messages': messages.map((e) => e.toMap()).toList(),
      },
    );

    // ? Send the list of messages to friend connected in!

    if (server.getClientList().any((e) => e == params.receiver_id)) {
      final friend = server.getClient(params.receiver_id)!;
      friend.socket.sink.add(event.toJson());
    }

    // ? Update the list of messages of user connected in

    final client = server.getClient(id)!;
    client.socket.sink.add(event.toJson());

    return Response(
      201,
      body: jsonEncode(
        {
          'message': 'Message sended!',
        },
      ),
    );
  } on ParamsException catch (e) {
    return Response(
      400,
      body: jsonEncode({'error': e.error}),
    );
  } on ServerException catch (e) {
    return Response(
      e.statusCode,
      body: jsonEncode({'error': e.error}),
    );
  } on Exception catch (e) {
    return Response(
      500,
      body: jsonEncode({'error': e.toString()}),
    );
  }
}

class _Params {
  final String message;
  final String receiver_id;

  _Params({
    required this.message,
    required this.receiver_id,
  });

  void validateParams() {
    if (message.isEmpty) {
      throw ParamsException('empty-message-not-provided');
    } else if (receiver_id.isEmpty) {
      throw ParamsException('receiver-id-not-provided');
    }
  }

  _Params copyWith({
    String? message,
    String? receiver_id,
  }) {
    return _Params(
      message: message ?? this.message,
      receiver_id: receiver_id ?? this.receiver_id,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'message': message,
      'receiver_id': receiver_id,
    };
  }

  factory _Params.fromMap(Map<String, dynamic> map) {
    return _Params(
      message: map['message'] as String,
      receiver_id: map['receiver_id'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory _Params.fromJson(String source) =>
      _Params.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => '_Params(message: $message, receiver_id: $receiver_id)';

  @override
  bool operator ==(covariant _Params other) {
    if (identical(this, other)) return true;

    return other.message == message && other.receiver_id == receiver_id;
  }

  @override
  int get hashCode => message.hashCode ^ receiver_id.hashCode;
}
