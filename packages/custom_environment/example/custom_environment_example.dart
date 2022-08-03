import 'package:custom_environment/custom_environment.dart';

void main() {
  final env = CustomEnvironment.instance;

  print(env.get<int>('port'));

  print(env.get<String>('host'));
}
