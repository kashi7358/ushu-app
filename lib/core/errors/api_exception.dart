import 'app_exception.dart';

class ApiException extends AppException {
  final int? statusCode;

  const ApiException(String message, {this.statusCode}) 
      : super(message, 'API Error');
}
