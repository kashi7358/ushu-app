import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import '../utils/session_manager.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  late final Dio _dio;

  ApiClient._internal() {
    _dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 35),
      receiveTimeout: const Duration(seconds: 35),
      sendTimeout: const Duration(seconds: 35),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    if (kDebugMode) {
      _dio.httpClientAdapter = IOHttpClientAdapter(
        createHttpClient: () {
          final client = HttpClient();
          client.badCertificateCallback =
              (X509Certificate cert, String host, int port) => true;
          return client;
        },
      );

      _dio.interceptors.add(LogInterceptor(
        request: true,
        requestHeader: false,
        requestBody: true,
        responseHeader: false,
        responseBody: false,
        error: true,
      ));
    }

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        final sellerToken = SessionManager.sellerToken;
        final buyerToken = SessionManager.token;
        final token = (sellerToken != null && sellerToken.isNotEmpty) ? sellerToken : buyerToken;
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onResponse: (response, handler) async {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          if (data['success'] == false && 
              data['message'] != null && 
              data['message'].toString().contains('Access Denied')) {
            // Only clear session in background, do NOT kick user out to login screen
            await SessionManager.clearSession();
          }
        }
        return handler.next(response);
      },
      onError: (DioException err, handler) async {
        if (err.response?.statusCode == 401) {
          await SessionManager.clearSession();
        }

        final isTimeout = err.type == DioExceptionType.connectionTimeout ||
            err.type == DioExceptionType.receiveTimeout ||
            err.type == DioExceptionType.sendTimeout ||
            err.type == DioExceptionType.connectionError;

        final extra = err.requestOptions.extra;
        final int retryCount = extra['retry_count'] ?? 0;

        if (isTimeout && retryCount < 2) {
          extra['retry_count'] = retryCount + 1;
          await Future.delayed(Duration(milliseconds: 1200 * (retryCount + 1)));
          try {
            final response = await _dio.fetch(err.requestOptions);
            return handler.resolve(response);
          } catch (e) {
            if (e is DioException) {
              return handler.next(e);
            }
          }
        }
        return handler.next(err);
      },
    ));
  }

  Dio get dio => _dio;
}
