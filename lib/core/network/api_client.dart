import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../utils/session_manager.dart';

class ApiClient {
  late final Dio _dio;

  ApiClient() {
    _dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    _dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final client = HttpClient();
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;
        return client;
      },
    );

    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        error: true,
      ));
    }

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = SessionManager.token; 
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
            
            await SessionManager.clearSession();
            
            // Wait for next tick to navigate
            Future.delayed(Duration.zero, () {
              Get.offAllNamed('/login');
              Get.snackbar('Session Expired', 'Please login again to continue.');
            });
          }
        }
        return handler.next(response);
      },
    ));
  }

  Dio get dio => _dio;
}
