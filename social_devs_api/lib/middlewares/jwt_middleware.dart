import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:social_devs_api/others/jwt_builder.dart';
import 'package:social_devs_api/others/server_repository.dart';
import 'package:social_devs_api/exceptions/server_exception.dart';

Middleware jwtMiddleware() {
  return (handler) {
    return (request) async {
      try {
        final routes = ['auth/signin', 'auth/signup', 'auth/refresh', 'ws'];

        if (routes.contains(request.url.path)) {
          return handler(request);
        }

        final server = ServerRepository.instance;

        final authorization = request.headers['authorization'] ?? '';

        final id = JwtBuilder.verify(authorization);

        if (!await server.userExists(id)) {
          return Response(
            401,
            body: jsonEncode(
              {
                'error': 'invalid_or_malformed_token',
              },
            ),
          );
        }

        final changed = request.change(context: {'id': id});

        return handler(changed);
      } on ServerException catch (e) {
        return Response(
          e.statusCode,
          body: jsonEncode(
            {
              'error': e.error,
            },
          ),
        );
      } on Exception catch (e) {
        return Response(
          500,
          body: jsonEncode(
            {
              'error': 'internal_error',
              'defail': e.toString(),
            },
          ),
        );
      }
    };
  };
}
