import '../../domain/entities/auth_user.dart';

class AuthUserModel extends AuthUser {
  AuthUserModel({
    required super.id,
    required super.fullName,
    required super.email,
    required super.phone,
    required super.role,
    super.token,
  });

  factory AuthUserModel.fromJson(Map<String, dynamic> json, {String? extraToken}) {
    return AuthUserModel(
      id: json['_id'] ?? json['id'] ?? json['buyerId'] ?? '',
      fullName: json['FullName'] ?? json['fullName'] ?? '',
      email: json['Email'] ?? json['email'] ?? '',
      phone: json['Phone'] ?? json['phone'] ?? '',
      role: json['Role'] ?? json['role'] ?? '',
      token: extraToken ?? json['token'] ?? json['accessToken'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'FullName': fullName,
      'Email': email,
      'Phone': phone,
      'Role': role,
    };
  }
}
