import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/utils/home_cache_manager.dart';
import '../models/product_model.dart';

abstract class HomeRemoteDataSource {
  Future<List<ProductModel>> getAllHomepageProducts();
  Future<ProductModel> getProductById(String id);
  Future<List<ProductModel>> getFlashSaleProducts();
  Future<List<ProductModel>> getTrendingProducts();
  Future<List<ProductModel>> getBannerProducts();
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final ApiClient apiClient;

  HomeRemoteDataSourceImpl(this.apiClient);

  @override
  Future<List<ProductModel>> getAllHomepageProducts() async {
    try {
      final response = await apiClient.dio.get(
        ApiEndpoints.allHomepageProducts,
        options: Options(validateStatus: (status) => status != null && status < 500),
      );
      
      final data = response.data;
      List productsList = [];
      if (data is Map<String, dynamic>) {
        if (data['products'] != null && data['products'] is List) {
          productsList = data['products'];
        } else if (data['data'] != null && data['data'] is List) {
          productsList = data['data'];
        } else if (data['data'] != null && data['data'] is Map && data['data']['products'] != null) {
          productsList = data['data']['products'];
        }
      } else if (data is List) {
        productsList = data;
      }

      final List<ProductModel> result = [];
      for (var p in productsList) {
        if (p is Map<String, dynamic>) {
          try {
            result.add(ProductModel.fromJson(p));
          } catch (e) {
            debugPrint('Error parsing product item: $e');
          }
        }
      }
      if (result.isNotEmpty) {
        HomeCacheManager.saveHomepageProducts(result);
      }
      return result;
    } catch (e) {
      debugPrint('Error loading homepage products: $e');
      return await HomeCacheManager.getHomepageProducts();
    }
  }

  @override
  Future<ProductModel> getProductById(String id) async {
    final response = await apiClient.dio.get('${ApiEndpoints.singleProduct}$id');
    final data = response.data;
    if (data is Map<String, dynamic> && data['data'] != null) {
      return ProductModel.fromJson(data['data']);
    }
    throw Exception('Product data not found');
  }

  @override
  Future<List<ProductModel>> getFlashSaleProducts() async {
    try {
      final response = await apiClient.dio.get(ApiEndpoints.flashSale, options: Options(validateStatus: (status) => status != null && status < 500));
      final data = response.data;
      List productsList = [];
      if (data is Map<String, dynamic> && data['success'] == true && data['data'] != null) {
        var saleData = data['data'];
        if (saleData is Map && saleData['products'] != null) {
          productsList = saleData['products'];
        } else if (saleData is List) {
          productsList = saleData;
        }
      }
      
      final List<ProductModel> result = [];
      for (var p in productsList) {
        if (p is Map<String, dynamic>) {
          try {
            result.add(ProductModel.fromJson(p));
          } catch (e) {
            debugPrint('Error parsing flash sale product: $e');
          }
        }
      }
      return result;
    } catch (e) {
      return []; // Return empty if sale is inactive or expired
    }
  }

  @override
  Future<List<ProductModel>> getTrendingProducts() async {
    try {
      final response = await apiClient.dio.get(ApiEndpoints.trendingProducts, options: Options(validateStatus: (status) => status != null && status < 500));
      final data = response.data;
      List productsList = [];
      if (data is Map<String, dynamic>) {
        if (data['data'] != null) {
          var trendingData = data['data'];
          if (trendingData is Map && trendingData['trendingProducts'] != null) {
            productsList = trendingData['trendingProducts'];
          } else if (trendingData is List) {
            productsList = trendingData;
          } else if (trendingData is Map && trendingData['products'] != null) {
            productsList = trendingData['products'];
          }
        } else if (data['products'] != null && data['products'] is List) {
          productsList = data['products'];
        }
      }

      final List<ProductModel> result = [];
      for (var p in productsList) {
        if (p is Map<String, dynamic>) {
          try {
            result.add(ProductModel.fromJson(p));
          } catch (e) {
            debugPrint('Error parsing trending product: $e');
          }
        }
      }
      return result;
    } catch (e) {
      return []; 
    }
  }

  @override
  Future<List<ProductModel>> getBannerProducts() async {
    try {
      final response = await apiClient.dio.get(ApiEndpoints.homeBanner, options: Options(validateStatus: (status) => status != null && status < 500));
      final data = response.data;
      
      List productsList = [];
      if (data is Map<String, dynamic>) {
        if (data['products'] != null && data['products'] is List) {
          productsList = data['products'];
        } else if (data['data'] != null && data['data'] is List) {
          productsList = data['data'];
        } else if (data['data'] != null && data['data'] is Map && data['data']['products'] != null) {
          productsList = data['data']['products'];
        }
      } else if (data is List) {
        productsList = data;
      }
      
      final List<ProductModel> result = [];
      for (var p in productsList) {
        if (p is Map<String, dynamic>) {
          try {
            result.add(ProductModel.fromJson(p));
          } catch (e) {
            debugPrint('Error parsing banner product: $e');
          }
        }
      }
      return result;
    } catch (e) {
      return [];
    }
  }
}
