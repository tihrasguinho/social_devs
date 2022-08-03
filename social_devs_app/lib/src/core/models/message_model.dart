import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:social_devs_app/src/core/models/user_model.dart';

class MessageModel {
  final String id;
  final String message;
  final String type;
  final String senderId;
  final String receiverId;
  final int createdAt;
  final int updatedAt;

  MessageModel({
    required this.id,
    required this.message,
    required this.type,
    required this.senderId,
    required this.receiverId,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isMe {
    final app = Hive.box('app');
    final user = UserModel.fromJson(app.get('user'));

    return senderId == user.id;
  }

  String get time {
    final date = DateTime.fromMillisecondsSinceEpoch(createdAt);
    return DateFormat('HH:mm').format(date);
  }

  MessageModel copyWith({
    String? id,
    String? message,
    String? type,
    String? senderId,
    String? receiverId,
    int? createdAt,
    int? updatedAt,
  }) {
    return MessageModel(
      id: id ?? this.id,
      message: message ?? this.message,
      type: type ?? this.type,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'message': message,
      'type': type,
      'sender_id': senderId,
      'receiver_id': receiverId,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      id: map['id'] as String,
      message: map['message'] as String,
      type: map['type'] as String,
      senderId: map['sender_id'] as String,
      receiverId: map['receiver_id'] as String,
      createdAt: map['created_at'] as int,
      updatedAt: map['updated_at'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory MessageModel.fromJson(String source) =>
      MessageModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'MessageModel(id: $id, message: $message, type: $type, senderId: $senderId, receiverId: $receiverId, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(covariant MessageModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.message == message &&
        other.type == type &&
        other.senderId == senderId &&
        other.receiverId == receiverId &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        message.hashCode ^
        type.hashCode ^
        senderId.hashCode ^
        receiverId.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
}
