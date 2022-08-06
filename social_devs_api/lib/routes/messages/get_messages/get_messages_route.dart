import 'dart:async';
import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:social_devs_api/exceptions/server_exception.dart';
import 'package:social_devs_api/others/server_repository.dart';

FutureOr<Response> getMessagesRoute(Request request, String friendId) async {
  try {
    final id = request.context['id'] as String;

    final server = ServerRepository.instance;

    final messages = await server.selectMessages(id, friendId);

    return Response(
      200,
      body: jsonEncode(
        {
          'messages': messages.map((e) => e.toMap()).toList(),
        },
      ),
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
