import 'dart:convert';
import 'dart:io';

import 'package:image/image.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';

void main() async {
  final router = Router();

  router.post('/', (Request request) async {
    try {
      final body = await request.readAsString();

      final sec = request.url.queryParameters['sec'] ?? '00:00:01.000';

      final data = jsonDecode(body) as Map<String, dynamic>;

      if (!data.containsKey('url') || data['url'] == '') {
        return Response(
          400,
          body: jsonEncode(
            {
              'error': 'Video url not provided!',
            },
          ),
          headers: {
            'Content-Type': 'application/json',
          },
        );
      }

      final url = data['url'] as String;

      final regex = RegExp(r'(\.\w+$)');

      final format = regex.stringMatch(url);

      if (format == null) {
        return Response(
          400,
          body: jsonEncode(
            {
              'error': 'Invalid video format or not public URL!',
            },
          ),
          headers: {
            'Content-Type': 'application/json',
          },
        );
      }

      if (!['.mp4', '.avi', '.3gp', '.webm'].contains(format)) {
        return Response(
          400,
          body: jsonEncode(
            {
              'error': 'Video format not allowed!',
            },
          ),
          headers: {
            'Content-Type': 'application/json',
          },
        );
      }

      final filename = 'IMAGE-${DateTime.now().toUtc().millisecondsSinceEpoch}.png';

      Process.runSync(
        'ffmpeg',
        [
          '-i',
          url,
          '-ss',
          sec,
          '-vframes',
          '1',
          filename,
        ],
      );

      final file = File('./$filename');

      final bytes = await file.readAsBytes();

      await file.delete();

      final image = decodeImage(bytes)!;

      return Response(
        200,
        body: bytes,
        headers: {
          'Content-Type': 'image/png',
          'issuer': '@tihrasguinho.dev',
          'aspect-ratio': '${image.width / image.height}',
          'image-width': image.width.toString(),
          'image-heigth': image.height.toString(),
        },
      );
    } on Exception catch (e) {
      return Response(
        500,
        body: jsonEncode(
          {
            'error': e.toString(),
          },
        ),
        headers: {
          'Content-Type': 'application/json',
        },
      );
    }
  });

  router.all('/<ignored|.*>', (Request request) {
    return Response(
      404,
      body: jsonEncode(
        {
          'error': 'Route not found!',
        },
      ),
      headers: {
        'Content-Type': 'application/json',
      },
    );
  });

  final handler = Pipeline().addMiddleware(logRequests()).addHandler(router);

  final server = await io.serve(handler, '0.0.0.0', 8080);

  print('Api started http://${server.address.host}:${server.port}');
}
