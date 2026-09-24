import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/home/data/models/product_model.dart';

class HomeCacheManager {
  static const _keyHomepageProducts = 'cache_homepage_products';
  static const _keyTrendingProducts = 'cache_trending_products';

  static Future<void> saveHomepageProducts(List<ProductModel> products) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = products.map((p) => p.toJson()).toList();
      await prefs.setString(_keyHomepageProducts, jsonEncode(jsonList));
    } catch (e) {
      // Ignore cache write error
    }
  }

  static Future<List<ProductModel>> getHomepageProducts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_keyHomepageProducts);
      if (raw != null && raw.isNotEmpty) {
        final List decoded = jsonDecode(raw);
        return decoded.map((item) => ProductModel.fromJson(item as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      // Return empty if cache parse fails
    }
    return [];
  }

  static Future<void> saveTrendingProducts(List<ProductModel> products) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = products.map((p) => p.toJson()).toList();
      await prefs.setString(_keyTrendingProducts, jsonEncode(jsonList));
    } catch (e) {
      // Ignore cache write error
    }
  }

  static Future<List<ProductModel>> getTrendingProducts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_keyTrendingProducts);
      if (raw != null && raw.isNotEmpty) {
        final List decoded = jsonDecode(raw);
        return decoded.map((item) => ProductModel.fromJson(item as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      // Return empty if cache parse fails
    }
    return [];
  }
}
