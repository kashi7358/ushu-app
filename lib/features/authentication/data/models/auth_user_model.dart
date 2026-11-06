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
    final Map<String, dynamic> buyerMap = (json['buyer'] is Map<String, dynamic>)
        ? json['buyer'] as Map<String, dynamic>
        : (json['user'] is Map<String, dynamic>)
            ? json['user'] as Map<String, dynamic>
            : (json['data'] is Map<String, dynamic>)
                ? json['data'] as Map<String, dynamic>
                : json;

    final token = extraToken ??
        json['token']?.toString() ??
        json['accessToken']?.toString() ??
        json['authToken']?.toString() ??
        buyerMap['token']?.toString() ??
        buyerMap['accessToken']?.toString() ??
        buyerMap['authToken']?.toString();

    return AuthUserModel(
      id: buyerMap['_id']?.toString() ??
          buyerMap['id']?.toString() ??
          buyerMap['buyerId']?.toString() ??
          json['_id']?.toString() ??
          json['id']?.toString() ??
          json['buyerId']?.toString() ??
          '',
      fullName: buyerMap['FullName']?.toString() ??
          buyerMap['fullName']?.toString() ??
          json['FullName']?.toString() ??
          json['fullName']?.toString() ??
          '',
      email: buyerMap['Email']?.toString() ??
          buyerMap['email']?.toString() ??
          json['Email']?.toString() ??
          json['email']?.toString() ??
          '',
      phone: buyerMap['Phone']?.toString() ??
          buyerMap['phone']?.toString() ??
          json['Phone']?.toString() ??
          json['phone']?.toString() ??
          '',
      role: buyerMap['Role']?.toString() ??
          buyerMap['role']?.toString() ??
          json['Role']?.toString() ??
          json['role']?.toString() ??
          '',
      token: token,
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
