import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<void> saveSession(String userId, String email, String fullName, {String? token}) async {
    await _prefs.setBool('isLoggedIn', true);
    await _prefs.setString('userId', userId);
    await _prefs.setString('email', email);
    await _prefs.setString('fullName', fullName);
    if (token != null && token.isNotEmpty) {
      await _prefs.setString('token', token);
    }
  }

  static Future<void> clearSession() async {
    await _prefs.clear();
  }

  static bool get isLoggedIn => _prefs.getBool('isLoggedIn') ?? false;
  static String? get userId => _prefs.getString('userId');
  static String? get email => _prefs.getString('email');
  static String? get fullName => _prefs.getString('fullName');
  static String? get token => _prefs.getString('token');
}
