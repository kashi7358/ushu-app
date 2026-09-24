import 'package:shared_preferences/shared_preferences.dart';

class SearchHistory {
  static const String _key = 'recent_search_queries';
  static const int _maxItems = 20;

  /// Add a search query to history.
  /// Moves existing item to the top if already present.
  static Future<void> addQuery(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> history = prefs.getStringList(_key) ?? [];

      // Remove existing occurrence case-insensitively
      history.removeWhere((item) => item.toLowerCase() == trimmed.toLowerCase());

      // Insert at the top
      history.insert(0, trimmed);

      // Keep only max items
      if (history.length > _maxItems) {
        history = history.sublist(0, _maxItems);
      }

      await prefs.setStringList(_key, history);
    } catch (e) {
      // Ignore errors silently
    }
  }

  /// Get all saved search history queries.
  static Future<List<String>> getQueries() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getStringList(_key) ?? [];
    } catch (e) {
      return [];
    }
  }

  /// Remove a specific search query from history.
  static Future<void> removeQuery(String query) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> history = prefs.getStringList(_key) ?? [];
      history.removeWhere((item) => item.toLowerCase() == query.trim().toLowerCase());
      await prefs.setStringList(_key, history);
    } catch (e) {
      // Ignore errors silently
    }
  }

  /// Clear all search history.
  static Future<void> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_key);
    } catch (e) {
      // Ignore errors silently
    }
  }
}
