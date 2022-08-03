import 'dart:convert';

import 'package:social_devs_app/src/core/models/message_model.dart';
import 'package:social_devs_app/src/core/models/user_model.dart';

class ChatModel {
  final UserModel friend;
  final MessageModel message;

  ChatModel({
    required this.friend,
    required this.message,
  });

  ChatModel copyWith({
    UserModel? friend,
    MessageModel? message,
  }) {
    return ChatModel(
      friend: friend ?? this.friend,
      message: message ?? this.message,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'friend': friend.toMap(),
      'message': message.toMap(),
    };
  }

  factory ChatModel.fromMap(Map<String, dynamic> map) {
    return ChatModel(
      friend: UserModel.fromMap(map['friend'] as Map<String, dynamic>),
      message: MessageModel.fromMap(map['message'] as Map<String, dynamic>),
    );
  }

  String toJson() => json.encode(toMap());

  factory ChatModel.fromJson(String source) =>
      ChatModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'ChatModel(friend: $friend, message: $message)';

  @override
  bool operator ==(covariant ChatModel other) {
    if (identical(this, other)) return true;

    return other.friend == friend && other.message == message;
  }

  @override
  int get hashCode => friend.hashCode ^ message.hashCode;
}
