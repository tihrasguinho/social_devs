import 'dart:async';
import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:social_devs_api/exceptions/server_exception.dart';
import 'package:social_devs_api/others/server_repository.dart';

FutureOr<Response> selectFriendsRoute(Request request) async {
  try {
    final server = ServerRepository.instance;

    final id = request.context['id'] as String;

    final friends = await server.selectFriends(id);

    return Response(
      200,
      body: jsonEncode(
        {
          'messages': 'Listing friends',
          'friends': friends.map((e) => e.toPublicMap()).toList(),
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
