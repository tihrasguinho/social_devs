import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

class UserModel {
  final String id;
  final String name;
  final String username;
  final String email;
  final String image;
  final String thumb;
  final String createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    required this.image,
    required this.thumb,
    required this.createdAt,
  });

  UserModel copyWith({
    String? id,
    String? name,
    String? username,
    String? email,
    String? image,
    String? thumb,
    String? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      username: username ?? this.username,
      email: email ?? this.email,
      image: image ?? this.image,
      thumb: thumb ?? this.thumb,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'username': username,
      'email': email,
      'image': image,
      'thumb': thumb,
      'created_at': createdAt,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      image: map['image'] ?? '',
      thumb: map['thumb'] ?? '',
      createdAt: map['created_at'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'UserModel(id: $id, name: $name, username: $username, email: $email, image: $image, thumb: $thumb, createdAt: $createdAt)';
  }

  @override
  bool operator ==(covariant UserModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.name == name &&
        other.username == username &&
        other.email == email &&
        other.image == image &&
        other.thumb == thumb &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        username.hashCode ^
        email.hashCode ^
        image.hashCode ^
        thumb.hashCode ^
        createdAt.hashCode;
  }
}

class UserAdapter extends TypeAdapter<UserModel> {
  @override
  int get typeId => 0;

  @override
  UserModel read(BinaryReader reader) {
    var numOfFields = reader.readByte();
    var fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    return UserModel(
      id: fields[0] as String,
      name: fields[1] as String,
      username: fields[2] as String,
      email: fields[3] as String,
      image: fields[4] as String,
      thumb: fields[5] as String,
      createdAt: fields[6] as String,
    );
  }

  @override
  void write(BinaryWriter writer, UserModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.username)
      ..writeByte(3)
      ..write(obj.email)
      ..writeByte(4)
      ..write(obj.image)
      ..writeByte(5)
      ..write(obj.thumb)
      ..writeByte(6)
      ..write(obj.createdAt);
  }
}
