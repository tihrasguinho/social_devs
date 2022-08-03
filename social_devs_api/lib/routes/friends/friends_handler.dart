import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import 'friend_requests/friend_requests_route.dart';
import 'respond_to_request/respond_to_request_route.dart';
import 'select_friends/select_friends_route.dart';
import 'send_friend_request/send_friend_request_route.dart';

Handler get friendsHandler {
  final router = Router();

  router.get('/', selectFriendsRoute);

  router.post('/send-request', sendFriendRequestRoute);

  router.get('/requests', friendRequestsRoute);

  router.post('/respond-to-request', respondToRequestRoute);

  return router;
}
