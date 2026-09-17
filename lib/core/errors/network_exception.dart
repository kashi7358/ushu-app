import 'app_exception.dart';

class NetworkException extends AppException {
  const NetworkException(String message) : super(message, 'Network Error');
}
