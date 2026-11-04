import 'package:dio/dio.dart';
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
      _dio.interceptors.add(LogInterceptor(
        request: true,
        requestHeader: false,
        requestBody: false,
        responseHeader: false,
        responseBody: false,
        error: true,
      ));
    }

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        if (!options.headers.containsKey('Authorization')) {
          final path = options.path.toLowerCase();
          final bool isSellerEndpoint = path.contains('/seller') ||
              (path.contains('/store') && !path.contains('/store/get/')) ||
              path.contains('/dashboard') ||
              path.contains('/seller-copilot') ||
              path.contains('/product/create/') ||
              path.contains('/product/all/') ||
              path.contains('/product/delete/') ||
              path.contains('/product/update-product/') ||
              path.contains('/flashsale/create') ||
              path.contains('/flashsale/all') ||
              path.contains('/flashsale/update/') ||
              path.contains('/flashsale/delete/') ||
              path.contains('/order/seller-orders') ||
              path.contains('/order/delivered-orders') ||
              path.contains('/return/seller-refunded-orders') ||
              path.contains('/banner/create') ||
              path.contains('/banner/all') ||
              path.contains('/banner/update-seller/');

          final String? token = isSellerEndpoint
              ? SessionManager.sellerToken
              : SessionManager.token;

          if (token != null && token.isNotEmpty) {
            String clean = token.trim();
            if (clean.toLowerCase().startsWith('bearer ')) {
              clean = clean.substring(7).trim();
            }
            options.headers['Authorization'] = 'Bearer $clean';
            options.headers['auth-token'] = clean;
            options.headers['token'] = clean;
          }
        }
        return handler.next(options);
      },
      onResponse: (response, handler) async {
        final data = response.data;
        if (data is Map) {
          if (data['success'] == false && 
              data['message'] != null && 
              data['message'].toString().contains('Access Denied')) {
            final path = response.requestOptions.path.toLowerCase();
            if (path.contains('/seller') || (path.contains('/store') && !path.contains('/store/get/'))) {
              await SessionManager.clearSellerSession();
            } else {
              await SessionManager.clearSession();
            }
          }
        }
        return handler.next(response);
      },
      onError: (DioException err, handler) async {
        if (err.response?.statusCode == 401) {
          final path = err.requestOptions.path.toLowerCase();
          if (path.contains('/seller') || (path.contains('/store') && !path.contains('/store/get/')) || path.contains('/dashboard')) {
            await SessionManager.clearSellerSession();
          } else {
            await SessionManager.clearSession();
          }
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
