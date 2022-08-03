import 'dart:convert';

class FriendRequestEntity {
  final String id;
  final String friend_id;
  final String user_id;
  final String created_at;

  FriendRequestEntity({
    required this.id,
    required this.friend_id,
    required this.user_id,
    required this.created_at,
  });

  FriendRequestEntity copyWith({
    String? id,
    String? friend_id,
    String? user_id,
    String? created_at,
  }) {
    return FriendRequestEntity(
      id: id ?? this.id,
      friend_id: friend_id ?? this.friend_id,
      user_id: user_id ?? this.user_id,
      created_at: created_at ?? this.created_at,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'friend_id': friend_id,
      'user_id': user_id,
      'created_at': created_at.toString(),
    };
  }

  factory FriendRequestEntity.fromMap(Map<String, dynamic> map) {
    return FriendRequestEntity(
      id: map['id'] ?? '',
      friend_id: map['friend_id'] ?? '',
      user_id: map['user_id'] ?? '',
      created_at: map['created_at'].toString(),
    );
  }

  String toJson() => json.encode(toMap());

  factory FriendRequestEntity.fromJson(String source) =>
      FriendRequestEntity.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'FriendRequestEntity(id: $id, friend_id: $friend_id, user_id: $user_id, created_at: $created_at)';
  }

  @override
  bool operator ==(covariant FriendRequestEntity other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.friend_id == friend_id &&
        other.user_id == user_id &&
        other.created_at == created_at;
  }

  @override
  int get hashCode {
    return id.hashCode ^ friend_id.hashCode ^ user_id.hashCode ^ created_at.hashCode;
  }
}
