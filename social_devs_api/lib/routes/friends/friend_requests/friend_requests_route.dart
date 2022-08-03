import 'dart:async';
import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:social_devs_api/exceptions/server_exception.dart';
import 'package:social_devs_api/others/server_repository.dart';

FutureOr<Response> friendRequestsRoute(Request request) async {
  try {
    final server = ServerRepository.instance;

    final id = request.context['id'] as String;

    final requests = await server.selectFriendRequets(id);

    return Response(
      200,
      body: jsonEncode(
        {
          'requests': requests,
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
