import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SessionManager {
  static const _storage = FlutterSecureStorage();

  // In-memory cache for synchronous access
  static bool _isLoggedIn = false;
  static String? _userId;
  static String? _email;
  static String? _fullName;
  static String? _token;

  static Future<void> init() async {
    final loggedInStr = await _storage.read(key: 'isLoggedIn');
    _isLoggedIn = loggedInStr == 'true';
    _userId = await _storage.read(key: 'userId');
    _email = await _storage.read(key: 'email');
    _fullName = await _storage.read(key: 'fullName');
    _token = await _storage.read(key: 'token');
  }

  static Future<void> saveSession(String userId, String email, String fullName, {String? token}) async {
    _isLoggedIn = true;
    _userId = userId;
    _email = email;
    _fullName = fullName;

    await _storage.write(key: 'isLoggedIn', value: 'true');
    await _storage.write(key: 'userId', value: userId);
    await _storage.write(key: 'email', value: email);
    await _storage.write(key: 'fullName', value: fullName);
    
    if (token != null && token.isNotEmpty) {
      _token = token;
      await _storage.write(key: 'token', value: token);
    }
  }

  static Future<void> clearSession() async {
    _isLoggedIn = false;
    _userId = null;
    _email = null;
    _fullName = null;
    _token = null;

    await _storage.delete(key: 'isLoggedIn');
    await _storage.delete(key: 'userId');
    await _storage.delete(key: 'email');
    await _storage.delete(key: 'fullName');
    await _storage.delete(key: 'token');
  }

  static bool get isLoggedIn => _isLoggedIn;
  static String? get userId => _userId;
  static String? get email => _email;
  static String? get fullName => _fullName;
  static String? get token => _token;
}
