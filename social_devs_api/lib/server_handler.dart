import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import 'routes/auth/auth_handler.dart';
import 'routes/friends/friends_handler.dart';
import 'routes/images/images_handler.dart';
import 'routes/messages/messages_handler.dart';
import 'routes/users/users_handler.dart';

import 'websocket/ws_handler.dart';

Handler get serverHandler {
  final router = Router();

  router.mount('/auth', authHandler);

  router.mount('/users', usersHandler);

  router.mount('/friends', friendsHandler);

  router.mount('/images', imagesHandler);

  router.mount('/messages', messagesHandler);

  router.mount('/', wsHandler);

  return router;
}
