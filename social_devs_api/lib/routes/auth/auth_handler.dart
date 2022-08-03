import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import 'refresh_token/refresh_token_route.dart';
import 'signin/signin_route.dart';
import 'signup/signup_route.dart';

Handler get authHandler {
  final router = Router();

  router.post('/signin', signInRoute);

  router.post('/signup', signUpRoute);

  router.get('/refresh', refreshTokenRoute);

  return router;
}
