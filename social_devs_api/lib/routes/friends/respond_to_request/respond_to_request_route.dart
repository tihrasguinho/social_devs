import 'dart:async';
import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:social_devs_api/exceptions/params_exception.dart';
import 'package:social_devs_api/exceptions/server_exception.dart';
import 'package:social_devs_api/others/server_regexes.dart';
import 'package:social_devs_api/others/server_repository.dart';

FutureOr<Response> respondToRequestRoute(Request request) async {
  try {
    final server = ServerRepository.instance;

    final body = await request.readAsString();

    final params = _Params.fromJson(body)..validateParams();

    final req = await server.selectFriendRequestById(params.request_id);

    if (req != null) {
      if (params.status) {
        await server.insertFriend(req.user_id, req.friend_id);

        await server.deleteFriendRequest(req.id);

        return Response(
          201,
          body: jsonEncode(
            {
              'message': 'Friend added!',
            },
          ),
        );
      } else {
        await server.deleteFriendRequest(req.id);

        return Response(
          200,
          body: jsonEncode(
            {
              'message': 'Friend rejected!',
            },
          ),
        );
      }
    } else {
      return Response(
        404,
        body: jsonEncode(
          {
            'error': 'Friend request not found!',
          },
        ),
      );
    }
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
  final String request_id;
  final bool status;

  _Params({
    required this.request_id,
    required this.status,
  });

  void validateParams() {
    if (!ServerRegexes.uuidRegex.hasMatch(request_id)) {
      throw ParamsException('Invalid friend request id!');
    }
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'request_id': request_id,
      'status': status,
    };
  }

  factory _Params.fromMap(Map<String, dynamic> map) {
    return _Params(
      request_id: map['request_id'] ?? '',
      status: map['status'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory _Params.fromJson(String source) =>
      _Params.fromMap(json.decode(source) as Map<String, dynamic>);
}
