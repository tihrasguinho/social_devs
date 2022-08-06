part of 'chat_bloc.dart';

@immutable
abstract class ChatEvent {}

class LoadMessages extends ChatEvent {
  final List<MessageModel> messages;

  LoadMessages(this.messages);
}

class GetMessages extends ChatEvent {
  final String friendId;

  GetMessages(this.friendId);
}
