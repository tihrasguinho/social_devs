import 'dart:async';
import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:social_devs_api/exceptions/server_exception.dart';
import 'package:social_devs_api/others/server_repository.dart';

FutureOr<Response> sendFriendRequestRoute(Request request) async {
  try {
    final server = ServerRepository.instance;

    final id = request.context['id'] as String;

    final body = jsonDecode(await request.readAsString()) as Map;

    if (!body.containsKey('friend_id')) {
      return Response(
        400,
        body: jsonEncode(
          {
            'error': 'Friend id not provided!',
          },
        ),
      );
    }

    final friendId = body['friend_id'] as String;

    if (id == friendId) {
      return Response(
        400,
        body: jsonEncode(
          {
            'error': 'Operation not allowed!',
          },
        ),
      );
    }

    if (!await server.userExists(friendId)) {
      return Response(
        404,
        body: jsonEncode(
          {
            'error': 'User not found!',
          },
        ),
      );
    }

    if (await server.friendRequestExists(id, friendId)) {
      return Response(
        409,
        body: jsonEncode(
          {
            'error': 'You already sent a friend request!',
          },
        ),
      );
    }

    await server.insertFriendRequest(id, friendId);

    return Response(
      200,
      body: jsonEncode(
        {
          'message': 'Friend request sent successfully!',
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
