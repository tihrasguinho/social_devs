import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:custom_events/custom_events.dart';
import 'package:image/image.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_multipart/form_data.dart';
import 'package:social_devs_api/exceptions/params_exception.dart';
import 'package:social_devs_api/exceptions/server_exception.dart';
import 'package:social_devs_api/others/server_consts.dart';

import 'package:social_devs_api/others/server_repository.dart';

FutureOr<Response> sendImageMessageRoute(Request request) async {
  try {
    if (request.isMultipartForm) {
      final server = ServerRepository.instance;

      final path = kDebugMode ? '../data/messages' : './app/data/messages';

      final id = request.context['id'] as String;

      final fields = <String, dynamic>{};

      await for (final form in request.multipartFormData) {
        if (form.name == 'image') {
          fields['image'] = await form.part.readBytes();
          fields['sufix'] = form.filename?.split('.').last.toLowerCase() ?? '';
        } else {
          fields[form.name] = await form.part.readString();
        }
      }

      final params = _Params.fromMap(fields)..validateParams();

      if (!await Directory(path).exists()) {
        await Directory(path).create(recursive: true);
      }

      final decoded = decodeImage(params.image)!;

      final now = DateTime.now().toUtc().millisecondsSinceEpoch;

      final filename = '$now-$id.jpeg';

      await File('$path/$filename').writeAsBytes(encodeJpg(decoded, quality: 75));

      final values = <String, dynamic>{
        'message': filename,
        'type': 'image',
        'sender_id': id,
        'receiver_id': params.receiver_id,
      };

      await server.insertMessage(values);

      final messages = await server.selectMessages(id, params.receiver_id);

      final event = Event(
        name: Events.GET_MESSAGES,
        data: {
          'messages': messages.map((e) => e.toMap()).toList(),
        },
      );

      // ? Send the list of messages to friend connected in!

      if (server.getClientList().any((e) => e == params.receiver_id)) {
        final friend = server.getClient(params.receiver_id)!;
        friend.socket.sink.add(event.toJson());
      }

      // ? Update the list of messages of user connected in

      final client = server.getClient(id)!;
      client.socket.sink.add(event.toJson());

      return Response(
        201,
        body: jsonEncode(
          {
            'message': 'Message sended!',
          },
        ),
      );
    } else {
      return Response(
        400,
        body: jsonEncode(
          {
            'error': 'method-not-available',
          },
        ),
      );
    }
  } on ParamsException catch (e) {
    return Response(
      400,
      body: jsonEncode({'error': e.error}),
    );
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

class _Params {
  final Uint8List image;
  final String sufix;
  final String receiver_id;

  _Params({
    required this.image,
    required this.sufix,
    required this.receiver_id,
  });

  void validateParams() {
    if (image.isEmpty) {
      throw ParamsException('image-upload-fail');
    } else if ((image.lengthInBytes / 1024) / 1024 > 2.0) {
      throw ParamsException('image-size-max-5mb');
    } else if (!['jpeg', 'jpg', 'png', 'webp'].contains(sufix)) {
      throw ParamsException('image-format-not-allowed');
    } else if (receiver_id.isEmpty) {
      throw ParamsException('receiver-id-not-provided');
    }
  }

  _Params copyWith({
    Uint8List? image,
    String? sufix,
    String? receiver_id,
  }) {
    return _Params(
      image: image ?? this.image,
      sufix: sufix ?? this.sufix,
      receiver_id: receiver_id ?? this.receiver_id,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'image': image,
      'sufix': sufix,
      'receiver_id': receiver_id,
    };
  }

  factory _Params.fromMap(Map<String, dynamic> map) {
    return _Params(
      image: map['image'] as Uint8List,
      sufix: map['sufix'] as String,
      receiver_id: map['receiver_id'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  @override
  String toString() => '_Params(image: $image, sufix: $sufix, receiver_id: $receiver_id)';

  @override
  bool operator ==(covariant _Params other) {
    if (identical(this, other)) return true;

    return other.image == image && other.sufix == sufix && other.receiver_id == receiver_id;
  }

  @override
  int get hashCode => image.hashCode ^ sufix.hashCode ^ receiver_id.hashCode;
}
