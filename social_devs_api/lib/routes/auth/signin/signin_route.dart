import 'dart:async';
import 'dart:convert';

import 'package:bcrypt/bcrypt.dart';
import 'package:shelf/shelf.dart';
import 'package:social_devs_api/exceptions/params_exception.dart';
import 'package:social_devs_api/others/jwt_builder.dart';
import 'package:social_devs_api/others/server_repository.dart';

import 'signin_params.dart';

FutureOr<Response> signInRoute(Request request) async {
  try {
    final server = ServerRepository.instance;

    final body = await request.readAsString();

    final params = SigninParams.fromJson(body)..validate();

    final user = await server.selectUser(params.email);

    if (user == null) {
      return Response(
        404,
        body: jsonEncode({'error': 'user_not_found'}),
      );
    }

    if (!BCrypt.checkpw(params.password, user.password)) {
      return Response(
        401,
        body: jsonEncode({'error': 'wrong_password'}),
      );
    }

    final accessToken = JwtBuilder.generate(user.id);

    final refreshToken = JwtBuilder.generate(user.id, isRefresh: true);

    return Response(
      200,
      body: jsonEncode(
        {
          'message': 'User successfully loged in!',
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
  } on Exception catch (e) {
    return Response(
      500,
      body: jsonEncode({'error': e.toString()}),
    );
  }
}
