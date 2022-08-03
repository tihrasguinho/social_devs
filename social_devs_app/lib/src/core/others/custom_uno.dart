import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:social_devs_app/src/core/others/app_consts.dart';
import 'package:uno/uno.dart';

class CustomUno {
  late Uno _uno;

  Uno get uno => _uno;

  CustomUno() {
    final app = Hive.box('app');

    _uno = Uno(
      baseURL: API_URL,
      headers: {
        'authorization': 'Bearer ${app.get('access_token')}',
      },
    )
      ..interceptors.request.use(
        (request) {
          if (kDebugMode) print('Requesting to >>> ${request.uri.path} <<<');

          return request;
        },
        onError: (error) {
          return error;
        },
      )
      ..interceptors.response.use(
        (response) {
          return response;
        },
        onError: (error) async {
          if (error.response?.status == 401) {
            if (kDebugMode) {
              print('>>> Refreshing token <<<');
            }

            final $response = await Uno().get(
              '$API_URL/auth/refresh',
              headers: {
                'authorization': 'Bearer ${app.get('refresh_token')}',
              },
            );

            await app.put('access_token', $response.data['access_token']);

            _uno.headers['authorization'] = 'Bearer ${$response.data['access_token']}';

            return await _uno.request(
              error.request!.copyWith(
                headers: {
                  ...error.request!.headers,
                  'authorization': 'Bearer ${$response.data['access_token']}'
                },
              ),
            );
          } else {
            return error;
          }
        },
      );
  }
}
