import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import 'query_users/query_users_route.dart';

Handler get usersHandler {
  final router = Router();

  router.get('/', queryUsersRoute);

  return router;
}
