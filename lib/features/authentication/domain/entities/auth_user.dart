class AuthUser {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String role;
  final String? token;
  
  AuthUser({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.role,
    this.token,
  });
}
