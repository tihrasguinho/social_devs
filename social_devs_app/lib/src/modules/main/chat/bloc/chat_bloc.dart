// ignore_for_file: depend_on_referenced_packages

import 'package:bloc/bloc.dart';
import 'package:custom_events/custom_events.dart';
import 'package:meta/meta.dart';
import 'package:social_devs_app/src/core/models/message_model.dart';
import 'package:social_devs_app/src/modules/main/chat/chat_repository.dart';
import 'package:social_devs_app/src/modules/main/main_controller.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final MainController _main;
  final ChatRepository _repository;

  ChatBloc(this._main, this._repository) : super(const InitialMessages()) {
    _main.socket.listen((message) {
      final event = Event.fromJson(message);

      if (event.name == Events.GET_MESSAGES) {
        final list = event.data['messages'] as List;

        add(LoadMessages(list.map((e) => MessageModel.fromMap(e)).toList()));
      }
    });

    on<LoadMessages>((event, emit) {
      emit(const InitialMessages());

      emit(LoadedMessages(event.messages));
    });

    on<GetMessages>((event, emit) async {
      emit(const LoadingMessages());

      final messages = await _repository.getMessages(event.friendId);

      emit(LoadedMessages(messages ?? []));
    });
  }
}
