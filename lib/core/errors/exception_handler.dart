import 'package:dio/dio.dart';
import 'dart:io';
import 'app_exception.dart';
import 'api_exception.dart';
import 'network_exception.dart';

class ExceptionHandler {
  ExceptionHandler._();

  static AppException handle(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return const NetworkException('Connection timed out. Please try again.');
        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          final responseData = error.response?.data;
          String message = 'Something went wrong';
          if (responseData != null && responseData is Map && responseData['message'] != null) {
            message = responseData['message'];
          }
          return ApiException(message, statusCode: statusCode);
        case DioExceptionType.connectionError:
          return const NetworkException('Unable to connect to the server. Please check your internet connection.');
        case DioExceptionType.cancel:
          return const ApiException('Request to API server was cancelled');
        case DioExceptionType.unknown:
          if (error.error is SocketException) {
            return const NetworkException('Unable to connect to the server. Please check your internet connection.');
          }
          return const ApiException('Unexpected error occurred');
        default:
          return const ApiException('Something went wrong');
      }
    } else if (error is AppException) {
      return error;
    } else {
      return ApiException(error.toString());
    }
  }
}
