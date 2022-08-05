import 'dart:convert';

import 'package:social_devs_api/others/server_repository.dart';

class MessageEntity {
  final String id;
  final String message;
  final String type;
  final String sender_id;
  final String receiver_id;
  final DateTime created_at;
  final DateTime updated_at;

  MessageEntity({
    required this.id,
    required this.message,
    required this.type,
    required this.sender_id,
    required this.receiver_id,
    required this.created_at,
    required this.updated_at,
  });

  MessageEntity copyWith({
    String? id,
    String? message,
    String? type,
    String? sender_id,
    String? receiver_id,
    DateTime? created_at,
    DateTime? updated_at,
  }) {
    return MessageEntity(
      id: id ?? this.id,
      message: message ?? this.message,
      type: type ?? this.type,
      sender_id: sender_id ?? this.sender_id,
      receiver_id: receiver_id ?? this.receiver_id,
      created_at: created_at ?? this.created_at,
      updated_at: updated_at ?? this.updated_at,
    );
  }

  Map<String, dynamic> toMap() {
    final server = ServerRepository.instance;

    final $message = type == 'image' ? '${server.host}/messages/$message' : message;

    return <String, dynamic>{
      'id': id,
      'message': $message,
      'type': type,
      'sender_id': sender_id,
      'receiver_id': receiver_id,
      'created_at': created_at.millisecondsSinceEpoch,
      'updated_at': updated_at.millisecondsSinceEpoch,
    };
  }

  factory MessageEntity.fromMap(Map<String, dynamic> map) {
    return MessageEntity(
      id: map['id'] ?? '',
      message: map['message'] ?? '',
      type: map['type'] ?? '',
      sender_id: map['sender_id'] ?? '',
      receiver_id: map['receiver_id'] ?? '',
      created_at: map['created_at'] ?? DateTime.now().toUtc(),
      updated_at: map['updated_at'] ?? DateTime.now().toUtc(),
    );
  }

  String toJson() => json.encode(toMap());

  factory MessageEntity.fromJson(String source) =>
      MessageEntity.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'MessageEntity(id: $id, message: $message, type: $type, sender_id: $sender_id, receiver_id: $receiver_id, created_at: $created_at, updated_at: $updated_at)';
  }

  @override
  bool operator ==(covariant MessageEntity other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.message == message &&
        other.type == type &&
        other.sender_id == sender_id &&
        other.receiver_id == receiver_id &&
        other.created_at == created_at &&
        other.updated_at == updated_at;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        message.hashCode ^
        type.hashCode ^
        sender_id.hashCode ^
        receiver_id.hashCode ^
        created_at.hashCode ^
        updated_at.hashCode;
  }
}
