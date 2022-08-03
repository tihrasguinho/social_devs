import 'dart:convert';

import 'package:email_validator/email_validator.dart';
import 'package:social_devs_api/exceptions/params_exception.dart';

class SigninParams {
  final String email;
  final String password;

  SigninParams({
    required this.email,
    required this.password,
  });

  void validate() {
    if (!EmailValidator.validate(email)) {
      throw ParamsException('invalid_email');
    }

    if (password.isEmpty) {
      throw ParamsException('password_not_provided');
    }
  }

  SigninParams copyWith({
    String? email,
    String? password,
  }) {
    return SigninParams(
      email: email ?? this.email,
      password: password ?? this.password,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'email': email,
      'password': password,
    };
  }

  factory SigninParams.fromMap(Map<String, dynamic> map) {
    return SigninParams(
      email: map['email'] as String,
      password: map['password'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory SigninParams.fromJson(String source) =>
      SigninParams.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'SigninParams(email: $email, password: $password)';

  @override
  bool operator ==(covariant SigninParams other) {
    if (identical(this, other)) return true;

    return other.email == email && other.password == password;
  }

  @override
  int get hashCode => email.hashCode ^ password.hashCode;
}
