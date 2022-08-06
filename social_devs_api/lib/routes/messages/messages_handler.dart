import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import 'get_messages/get_messages_route.dart';
import 'send_image_message/send_image_message_route.dart';
import 'send_text_message/send_text_message_route.dart';
import 'send_video_message/send_video_message_route.dart';

Handler get messagesHandler {
  final router = Router();

  router.get('/get-messages/<friendId>', getMessagesRoute);

  router.post('/send-text-message', sendTextMessageRoute);

  router.post('/send-video-message', sendVideoMessageRoute);

  router.post('/send-image-message', sendImageMessageRoute);

  return router;
}
