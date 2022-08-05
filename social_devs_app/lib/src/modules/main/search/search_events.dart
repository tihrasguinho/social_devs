abstract class SearchEvents {
  final String query;

  SearchEvents(this.query);
}

class InitialUsersEvent extends SearchEvents {
  InitialUsersEvent() : super('');
}

class GetUsersEvent extends SearchEvents {
  GetUsersEvent(super.query);
}

class ClearUsersEvent extends SearchEvents {
  ClearUsersEvent() : super('');
}
