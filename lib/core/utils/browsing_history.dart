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
    } catch (e) {
      print('Error saving browsing history: $e');
    }
  }

  static Future<List<ProductModel>> getHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> historyStrings = prefs.getStringList(_key) ?? [];
      
      return historyStrings.map((item) {
        final decoded = jsonDecode(item);
        return ProductModel.fromJson(decoded);
      }).toList();
    } catch (e) {
      print('Error getting browsing history: $e');
      return [];
    }
  }
  
  static Future<void> removeProduct(String productId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> historyStrings = prefs.getStringList(_key) ?? [];
      
      historyStrings.removeWhere((item) {
        final decoded = jsonDecode(item);
        return decoded['_id'] == productId;
      });

      await prefs.setStringList(_key, historyStrings);
    } catch (e) {
      print('Error removing item from history: $e');
    }
  }

  static Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
