part of 'chat_bloc.dart';

@immutable
abstract class ChatState {
  final List<MessageModel> messages;

  const ChatState(this.messages);
}

class InitialMessages extends ChatState {
  const InitialMessages() : super(const []);
}

class LoadedMessages extends ChatState {
  const LoadedMessages(super.messages);
}

class LoadingMessages extends ChatState {
  const LoadingMessages() : super(const []);
}
