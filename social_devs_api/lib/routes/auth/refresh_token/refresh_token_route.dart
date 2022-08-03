import 'dart:async';
import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:social_devs_api/exceptions/params_exception.dart';
import 'package:social_devs_api/exceptions/server_exception.dart';
import 'package:social_devs_api/others/jwt_builder.dart';
import 'package:social_devs_api/others/server_repository.dart';

FutureOr<Response> refreshTokenRoute(Request request) async {
  try {
    final server = ServerRepository.instance;

    final authorization = request.headers['authorization'] ?? '';

    final id = JwtBuilder.verify(authorization, isRefresh: true);

    if (!await server.userExists(id)) {
      return Response(
        400,
        body: jsonEncode(
          {'error': 'invalid_or_malformed_token'},
        ),
      );
    }

    final accessToken = JwtBuilder.generate(id);

    return Response(
      200,
      body: jsonEncode(
        {
          'message': 'Token refreshed!',
          'access_token': accessToken,
          'expires_in': Duration(hours: 1).inSeconds,
        },
      ),
    );
  } on ServerException catch (e) {
    return Response(
      e.statusCode,
      body: jsonEncode({'error': e.error}),
    );
  } on ParamsException catch (e) {
    return Response(
      400,
      body: jsonEncode({'error': e.error}),
    );
  } on Exception catch (e) {
    return Response(
      500,
      body: jsonEncode({'error': e.toString()}),
    );
  }
}
