import 'app_exception.dart';

class AuthException extends AppException {
  const AuthException(String message) : super(message, 'Authentication Error');
}
