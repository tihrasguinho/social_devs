import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:shelf/shelf.dart';
import 'package:shelf_multipart/form_data.dart';

import 'package:social_devs_api/exceptions/params_exception.dart';
import 'package:social_devs_api/exceptions/server_exception.dart';
import 'package:social_devs_api/others/server_consts.dart';
import 'package:social_devs_api/others/server_repository.dart';

FutureOr<Response> sendVideoMessageRoute(Request request) async {
  try {
    if (request.isMultipartForm) {
      final server = ServerRepository.instance;

      final path = kDebugMode ? '../data/messages' : './app/data/messages';

      final id = request.context['id'] as String;

      final fields = <String, dynamic>{};

      await for (final form in request.multipartFormData) {
        if (form.name == 'video') {
          fields['video'] = await form.part.readBytes();
          fields['sufix'] = form.filename?.split('.').last ?? '';
        } else {
          fields[form.name] = await form.part.readString();
        }
      }

      final params = _Params.fromMap(fields)..validateParams();

      final now = DateTime.now().toUtc().millisecondsSinceEpoch;

      final original = File('$path/$now-$id-original.${params.sufix}');

      final converted = File('$path/$now-$id.mp4');

      await original.writeAsBytes(params.video);

      await Process.run('ffmpeg', [
        '-i',
        original.path,
        '-r',
        '24',
        '-c:a',
        'copy',
        '-c:v',
        'libx264',
        converted.path,
        '-hide_banner',
      ]);

      await original.delete();

      final values = <String, dynamic>{
        'message': converted.path.split('/').last,
        'type': 'video',
        'sender_id': id,
        'receiver_id': params.receiver_id,
      };

      await server.insertMessage(values);

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
            'error': 'method_not_allowed',
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
  final Uint8List video;
  final String sufix;
  final String receiver_id;

  _Params({
    required this.video,
    required this.sufix,
    required this.receiver_id,
  });

  void validateParams() {
    if (video.isEmpty) {
      throw ParamsException('video-upload-fail');
    } else if ((video.lengthInBytes / 1024) / 1024 > 5.0) {
      throw ParamsException('video-size-max-5mb');
    } else if (sufix.isEmpty) {
      throw ParamsException('fail-upload-video');
    } else if (!['mp4', 'avi', '3gp', 'flv', 'webm'].contains(sufix)) {
      throw ParamsException('video-format-not-allowed');
    } else if (receiver_id.isEmpty) {
      throw ParamsException('receiver-id-not-provided');
    }
  }

  _Params copyWith({
    Uint8List? video,
    String? sufix,
    String? receiver_id,
  }) {
    return _Params(
      video: video ?? this.video,
      sufix: sufix ?? this.sufix,
      receiver_id: receiver_id ?? this.receiver_id,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'video': video,
      'sufix': sufix,
      'receiver_id': receiver_id,
    };
  }

  factory _Params.fromMap(Map<String, dynamic> map) {
    return _Params(
      video: map['video'] as Uint8List,
      sufix: map['sufix'] as String,
      receiver_id: map['receiver_id'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  @override
  String toString() => '_Params(image: $video, sufix: $sufix, receiver_id: $receiver_id)';

  @override
  bool operator ==(covariant _Params other) {
    if (identical(this, other)) return true;

    return other.video == video && other.sufix == sufix && other.receiver_id == receiver_id;
  }

  @override
  int get hashCode => video.hashCode ^ sufix.hashCode ^ receiver_id.hashCode;
}
