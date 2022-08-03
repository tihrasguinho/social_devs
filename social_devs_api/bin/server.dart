import 'package:custom_environment/custom_environment.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import 'package:social_devs_api/middlewares/json_middleware.dart';
import 'package:social_devs_api/middlewares/jwt_middleware.dart';
import 'package:social_devs_api/others/server_repository.dart';
import 'package:social_devs_api/server_handler.dart';

void main() async {
  final env = CustomEnvironment.instance;

  await ServerRepository.init();

  final overrideHeaders = {
    ACCESS_CONTROL_ALLOW_ORIGIN: '*',
    'Content-Type': 'application/json;charset=utf-8'
  };

  final handler = Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(corsHeaders(headers: overrideHeaders))
      .addMiddleware(jsonMiddleware())
      .addMiddleware(jwtMiddleware())
      .addHandler(serverHandler);

  final server = await io.serve(handler, env.get<String>('host'), env.get('port'));

  print('Serving to http://${server.address.host}:${server.port}');
}
