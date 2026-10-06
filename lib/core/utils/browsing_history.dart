import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/home/data/models/product_model.dart';

class BrowsingHistory {
  static const String _key = 'browsing_history';
  static const int _maxItems = 20;

  static Future<void> addProduct(ProductModel product) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> historyStrings = prefs.getStringList(_key) ?? [];
      
      // Remove if already exists to move it to the top
      historyStrings.removeWhere((item) {
        final decoded = jsonDecode(item);
        return decoded['_id'] == product.id;
      });

      // Add to beginning
      historyStrings.insert(0, jsonEncode(product.toJson()));

      // Keep only max items
      if (historyStrings.length > _maxItems) {
        historyStrings = historyStrings.sublist(0, _maxItems);
      }

      await prefs.setStringList(_key, historyStrings);
    } catch (_) {}
  }

  static Future<List<ProductModel>> getHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> historyStrings = prefs.getStringList(_key) ?? [];
      final List<ProductModel> products = [];
      for (var item in historyStrings) {
        try {
          final decoded = jsonDecode(item);
          if (decoded is Map<String, dynamic>) {
            products.add(ProductModel.fromJson(decoded));
          } else if (decoded is Map) {
            products.add(ProductModel.fromJson(Map<String, dynamic>.from(decoded)));
          }
        } catch (_) {}
      }
      return products;
    } catch (_) {
      return [];
    }
  }
  
  static Future<void> removeProduct(String productId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> historyStrings = prefs.getStringList(_key) ?? [];
      
      historyStrings.removeWhere((item) {
        try {
          final decoded = jsonDecode(item);
          return decoded['_id'] == productId;
        } catch (_) {
          return false;
        }
      });

      await prefs.setStringList(_key, historyStrings);
    } catch (_) {}
  }

  static Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
