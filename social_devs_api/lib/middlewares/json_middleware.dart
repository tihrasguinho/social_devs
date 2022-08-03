import 'package:shelf/shelf.dart';

Middleware jsonMiddleware() {
  return createMiddleware(
    responseHandler: (response) {
      return response.change(
        headers: {
          'content-type': 'application/json; charset=utf-8',
        },
      );
    },
  );
}
