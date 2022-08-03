import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_multipart/form_data.dart';
import 'package:social_devs_api/exceptions/server_exception.dart';
import 'package:social_devs_api/others/server_repository.dart';

FutureOr<Response> uploadUserImageRoute(Request request) async {
  try {
    if (request.isMultipartForm) {
      final server = ServerRepository.instance;

      final id = request.context['id'] as String;

      Uint8List image = Uint8List.fromList([]);

      await for (final form in request.multipartFormData) {
        if (form.name == 'image') {
          image = await form.part.readBytes();
        }
      }

      if (image.isEmpty) {
        return Response(
          400,
          body: jsonEncode(
            {
              'error': 'Falha ao efetuar o upload da imagem!',
            },
          ),
        );
      }

      final inKB = image.lengthInBytes / 1024;
      final inMB = inKB / 1024;

      if (inMB > 2.0) {
        return Response(
          400,
          body: jsonEncode(
            {
              'error': 'Tamanho máximo permitido é de 2Mb!',
            },
          ),
        );
      }

      final original = decodeImage(image)!;

      final resized = copyResizeCropSquare(original, 1024);

      final thumb = copyResizeCropSquare(original, 256);

      await File('../images/$id-image.jpeg').writeAsBytes(encodeJpg(resized, quality: 85));

      await File('../images/$id-thumbnail.jpeg').writeAsBytes(encodeJpg(thumb, quality: 85));

      final user = await server.updateUser(id, {
        'image': '$id-image.jpeg',
        'thumbnail': '$id-thumbnail.jpeg',
      });

      return Response(
        200,
        body: jsonEncode(
          {
            'message': 'Imagem enviada com sucesso!',
            'user': user.toPublicMap(),
          },
        ),
      );
    } else {
      return Response(
        400,
        body: jsonEncode(
          {
            'error': 'Método não disponível.',
          },
        ),
      );
    }
  } on ServerException catch (e) {
    return Response(
      e.statusCode,
      body: jsonEncode({'error': e.error}),
    );
  } on Exception catch (e) {
    return Response(
      500,
      body: jsonEncode({'error': e.toString()}),
    );
  }
}
