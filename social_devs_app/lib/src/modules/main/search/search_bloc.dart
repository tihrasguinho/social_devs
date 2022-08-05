import 'package:bloc/bloc.dart';

import 'search_repository.dart';
import 'search_events.dart';
import 'search_states.dart';

class SearchBloc extends Bloc<SearchEvents, SearchStates> {
  final SearchRepository _repository;

  SearchBloc(this._repository) : super(InitialUsersState()) {
    on<GetUsersEvent>((event, emit) async {
      emit(LoadingUsersState());

      final users = await _repository.getUsers(event.query);

      emit(LoadedUsersState(users));
    });

    on<ClearUsersEvent>((event, emit) async {
      emit(LoadingUsersState());

      final users = await _repository.getUsers('');

      emit(LoadedUsersState(users));
    });
  }
}
