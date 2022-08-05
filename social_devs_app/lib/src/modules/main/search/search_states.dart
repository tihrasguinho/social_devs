import 'package:social_devs_app/src/core/models/user_model.dart';

abstract class SearchStates {
  final List<UserModel> users;

  SearchStates(this.users);
}

class LoadedUsersState extends SearchStates {
  LoadedUsersState(super.users);
}

class ClearUsersState extends SearchStates {
  ClearUsersState() : super([]);
}

class InitialUsersState extends SearchStates {
  InitialUsersState() : super([]);
}

class LoadingUsersState extends SearchStates {
  LoadingUsersState() : super([]);
}
