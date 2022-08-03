import 'dart:async';
import 'dart:convert';

import 'package:bcrypt/bcrypt.dart';
import 'package:shelf/shelf.dart';
import 'package:social_devs_api/exceptions/params_exception.dart';
import 'package:social_devs_api/exceptions/server_exception.dart';
import 'package:social_devs_api/others/jwt_builder.dart';
import 'package:social_devs_api/others/server_repository.dart';

import 'signup_params.dart';

FutureOr<Response> signUpRoute(Request request) async {
  try {
    final server = ServerRepository.instance;

    final body = await request.readAsString();

    final params = SignupParams.fromJson(body)..validate();

    final hashed = BCrypt.hashpw(params.password, BCrypt.gensalt());

    final user = await server.insertUser(params.toMap()..update('password', (_) => hashed));

    final accessToken = JwtBuilder.generate(user.id);

    final refreshToken = JwtBuilder.generate(user.id, isRefresh: true);

    return Response(
      201,
      body: jsonEncode(
        {
          'message': 'User successfully created!',
          'user': user.toPublicMap(),
          'access_token': accessToken,
          'refresh_token': refreshToken,
          'expires_in': Duration(hours: 1).inSeconds,
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
