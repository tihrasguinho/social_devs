import 'package:custom_environment/custom_environment.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:social_devs_api/exceptions/server_exception.dart';

class JwtBuilder {
  static String generate(String id, {bool isRefresh = false}) {
    try {
      final env = CustomEnvironment.instance;

      final jwt = JWT({'id': id});

      return jwt.sign(
        SecretKey(isRefresh ? env.get('jwt_refresh') : env.get('jwt_token')),
        expiresIn: isRefresh ? Duration(days: 15) : Duration(hours: 1),
      );
    } on JWTError catch (e) {
      throw ServerException(401, e.message);
    } on Exception {
      rethrow;
    }
  }

  static String verify(String authorization, {bool isRefresh = false}) {
    try {
      final env = CustomEnvironment.instance;

      final full = RegExp(r'^Bearer [0-9a-zA-Z]*\.[0-9a-zA-Z]*\.[0-9a-zA-Z-_]*$');

      if (!full.hasMatch(authorization)) {
        throw ServerException(401, 'invalid_token');
      }

      final token = authorization.split(' ').last;

      final jwt = JWT.verify(
        token,
        SecretKey(isRefresh ? env.get('jwt_refresh') : env.get('jwt_token')),
      );

      return jwt.payload['id'];
    } on JWTError catch (e) {
      throw ServerException(401, e.message);
    } on Exception {
      rethrow;
    }
  }
}
