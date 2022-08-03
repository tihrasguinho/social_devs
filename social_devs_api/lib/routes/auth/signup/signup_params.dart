import 'dart:convert';

import 'package:email_validator/email_validator.dart';
import 'package:social_devs_api/exceptions/params_exception.dart';

class SignupParams {
  final String name;
  final String username;
  final String email;
  final String password;

  SignupParams({
    required this.name,
    required this.username,
    required this.email,
    required this.password,
  });

  void validate() {
    if (name.isEmpty) {
      throw ParamsException('name_not_provided');
    }

    if (!EmailValidator.validate(email)) {
      throw ParamsException('invalid_email');
    }

    if (password.isEmpty) {
      throw ParamsException('password_not_provided');
    }

    if (password.length < 6) {
      throw ParamsException('weak_password');
    }
  }

  SignupParams copyWith({
    String? name,
    String? username,
    String? email,
    String? password,
  }) {
    return SignupParams(
      name: name ?? this.name,
      username: username ?? this.username,
      email: email ?? this.email,
      password: password ?? this.password,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'username': username,
      'email': email,
      'password': password,
    };
  }

  factory SignupParams.fromMap(Map<String, dynamic> map) {
    return SignupParams(
      name: map['name'] ?? '',
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      password: map['password'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory SignupParams.fromJson(String source) =>
      SignupParams.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'SignupParams(name: $name, username: $username, email: $email, password: $password)';
  }

  @override
  bool operator ==(covariant SignupParams other) {
    if (identical(this, other)) return true;

    return other.name == name &&
        other.username == username &&
        other.email == email &&
        other.password == password;
  }

  @override
  int get hashCode {
    return name.hashCode ^ username.hashCode ^ email.hashCode ^ password.hashCode;
  }
}
