import 'dart:convert';

import 'package:social_devs_api/others/server_repository.dart';

class UserEntity {
  final String id;
  final String name;
  final String username;
  final String email;
  final String password;
  final String image;
  final String thumbnail;
  final DateTime created_at;
  final DateTime updated_at;

  UserEntity({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    required this.password,
    required this.image,
    required this.thumbnail,
    required this.created_at,
    required this.updated_at,
  });

  UserEntity copyWith({
    String? id,
    String? name,
    String? username,
    String? email,
    String? password,
    String? image,
    String? thumbnail,
    DateTime? created_at,
    DateTime? updated_at,
  }) {
    return UserEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      username: username ?? this.username,
      email: email ?? this.email,
      password: password ?? this.password,
      image: image ?? this.image,
      thumbnail: thumbnail ?? this.thumbnail,
      created_at: created_at ?? this.created_at,
      updated_at: updated_at ?? this.updated_at,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'username': username,
      'email': email,
      'password': password,
      'image': image,
      'thumbnail': thumbnail,
      'created_at': created_at.millisecondsSinceEpoch,
      'updated_at': updated_at.millisecondsSinceEpoch,
    };
  }

  Map<String, dynamic> toPublicMap() {
    final server = ServerRepository.instance;

    return <String, dynamic>{
      'id': id,
      'name': name,
      'username': username,
      'email': email,
      'image': image.isEmpty ? image : '${server.host}/users/$id/$image',
      'thumbnail': thumbnail.isEmpty ? thumbnail : '${server.host}/users/$id/$thumbnail',
      'created_at': created_at.toString(),
    };
  }

  factory UserEntity.fromMap(Map<String, dynamic> map) {
    return UserEntity(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      password: map['password'] ?? '',
      image: map['image'] ?? '',
      thumbnail: map['thumbnail'] ?? '',
      created_at: map['created_at'] ?? DateTime.now().toUtc(),
      updated_at: map['updated_at'] ?? DateTime.now().toUtc(),
    );
  }

  String toJson() => json.encode(toMap());

  factory UserEntity.fromJson(String source) =>
      UserEntity.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'UserEntity(id: $id, name: $name, username: $username, email: $email, password: $password, image: $image, thumbnail: $thumbnail, created_at: $created_at, updated_at: $updated_at)';
  }

  @override
  bool operator ==(covariant UserEntity other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.name == name &&
        other.username == username &&
        other.email == email &&
        other.password == password &&
        other.image == image &&
        other.thumbnail == thumbnail &&
        other.created_at == created_at &&
        other.updated_at == updated_at;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        username.hashCode ^
        email.hashCode ^
        password.hashCode ^
        image.hashCode ^
        thumbnail.hashCode ^
        created_at.hashCode ^
        updated_at.hashCode;
  }
}
