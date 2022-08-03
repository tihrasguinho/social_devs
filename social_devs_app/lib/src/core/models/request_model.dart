import 'dart:convert';

import 'user_model.dart';

class RequestModel {
  final String requestId;
  final String requestedAt;
  final UserModel user;

  RequestModel({
    required this.requestId,
    required this.requestedAt,
    required this.user,
  });

  RequestModel copyWith({
    String? requestId,
    String? requestedAt,
    UserModel? user,
  }) {
    return RequestModel(
      requestId: requestId ?? this.requestId,
      requestedAt: requestedAt ?? this.requestedAt,
      user: user ?? this.user,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'request_id': requestId,
      'requested_at': requestedAt,
      'user': user.toMap(),
    };
  }

  factory RequestModel.fromMap(Map<String, dynamic> map) {
    return RequestModel(
      requestId: map['request_id'] as String,
      requestedAt: map['requested_at'] as String,
      user: UserModel.fromMap(map['user'] as Map<String, dynamic>),
    );
  }

  String toJson() => json.encode(toMap());

  factory RequestModel.fromJson(String source) =>
      RequestModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'RequestModel(requestId: $requestId, requestedAt: $requestedAt, user: $user)';

  @override
  bool operator ==(covariant RequestModel other) {
    if (identical(this, other)) return true;

    return other.requestId == requestId && other.requestedAt == requestedAt && other.user == user;
  }

  @override
  int get hashCode => requestId.hashCode ^ requestedAt.hashCode ^ user.hashCode;
}
