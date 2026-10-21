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
          return const NetworkException('Connection timed out. Please check your internet connection.');

        case DioExceptionType.badCertificate:
          return const NetworkException('Unable to establish a secure connection. Please try again.');

        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          final responseData = error.response?.data;
          String message = '';

          if (responseData != null && responseData is Map) {
            dynamic rawMsg = responseData['message'] ?? responseData['error'] ?? responseData['msg'];
            // Check nested validation errors array or map (Express.js standard)
            if (rawMsg == null && responseData['errors'] != null) {
              final errs = responseData['errors'];
              if (errs is List && errs.isNotEmpty) {
                final first = errs.first;
                if (first is Map) {
                  rawMsg = first['msg'] ?? first['message'] ?? first['error'];
                } else {
                  rawMsg = first.toString();
                }
              } else if (errs is Map && errs.isNotEmpty) {
                rawMsg = errs.values.first?.toString();
              }
            }

            if (rawMsg is List) {
              message = rawMsg.join(', ');
            } else if (rawMsg != null) {
              message = rawMsg.toString().trim();
            }
          } else if (responseData is String && responseData.isNotEmpty) {
            if (responseData.contains('<html') || responseData.contains('<!DOCTYPE')) {
              message = statusCode != null && statusCode >= 500
                  ? 'Server is temporarily unavailable. Please try again later.'
                  : 'An unexpected server response was received.';
            } else {
              message = responseData.trim();
            }
          }

          if (message.isEmpty || message == 'Something went wrong') {
            if (statusCode == 400) {
              message = 'Invalid request. Please check the provided information.';
            } else if (statusCode == 401) {
              message = 'Session expired. Please log in again.';
            } else if (statusCode == 403) {
              message = 'Access denied. You do not have permission for this action.';
            } else if (statusCode == 404) {
              message = 'Requested resource not found.';
            } else if (statusCode == 429) {
              message = 'Too many requests. Please wait a moment and try again.';
            } else if (statusCode != null && statusCode >= 500) {
              message = 'Server error ($statusCode). Please try again later.';
            } else {
              message = 'Something went wrong. Please try again.';
            }
          }

          return ApiException(message, statusCode: statusCode);

        case DioExceptionType.connectionError:
          if (error.error is HandshakeException || error.error is TlsException) {
            return const NetworkException('Unable to connect to server. Please try again.');
          }
          if (error.error is SocketException) {
            return const NetworkException('Unable to connect to server. Please check your internet connection.');
          }
          return const NetworkException('Unable to connect to server. Please check your internet connection.');

        case DioExceptionType.cancel:
          return const ApiException('Request was cancelled.');

        case DioExceptionType.unknown:
          if (error.error is SocketException) {
            return const NetworkException('Unable to connect to server. Please check your internet connection.');
          }
          if (error.error is HandshakeException || error.error is TlsException) {
            return const NetworkException('Unable to connect to server. Please try again.');
          }
          return const ApiException('Something went wrong. Please try again.');

        default:
          return const ApiException('Something went wrong. Please try again.');
      }
    } else if (error is AppException) {
      return error;
    } else if (error is SocketException) {
      return const NetworkException('Unable to connect to server. Please check your internet connection.');
    } else if (error is HandshakeException || error is TlsException) {
      return const NetworkException('Unable to connect to server. Please try again.');
    } else if (error is FormatException) {
      return const ApiException('Invalid data format received from server.');
    } else {
      return ApiException(error.toString());
    }
  }
}
