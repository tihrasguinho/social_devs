import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import 'upload_user_image/upload_user_image_route.dart';

Handler get imagesHandler {
  final router = Router();

  router.post('/upload-user-image', uploadUserImageRoute);

  return router;
}
