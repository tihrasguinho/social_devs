import 'dart:async';
import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:social_devs_api/entities/user_entity.dart';
import 'package:social_devs_api/exceptions/server_exception.dart';
import 'package:social_devs_api/others/server_repository.dart';

FutureOr<Response> queryUsersRoute(Request request) async {
  try {
    final server = ServerRepository.instance;

    final id = request.context['id'] as String;

    final params = request.url.queryParameters.isEmpty
        ? null
        : Map<String, String>.from(request.url.queryParameters);

    final users = (await server.selectUsers(params))..removeWhere((e) => e.id == id);

    var perPage = int.tryParse(request.url.queryParameters['per_page'] ?? '10') ?? 10;

    if (perPage <= 4) {
      perPage = 5;
    }

    final pages = _pagination(users, perPage: perPage);

    var page = int.tryParse(request.url.queryParameters['page'] ?? '1') ?? 1;

    if (!pages.asMap().containsKey(page - 1)) {
      page = pages.length;
    }

    return Response(
      200,
      body: jsonEncode(
        {
          'message': 'Listing users!',
          'page': page,
          'users': pages[page - 1].map((e) => e.toPublicMap()).toList(),
        },
      ),
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

List<List<UserEntity>> _pagination(List<UserEntity> users, {int perPage = 10}) {
  var base = List<UserEntity>.from(users);

  final pagination = <List<UserEntity>>[];

  while (base.isNotEmpty) {
    pagination.add(base.take(perPage).toList());

    base = base.skip(perPage).toList();
  }

  return pagination;
}
