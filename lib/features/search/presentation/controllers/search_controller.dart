import 'package:get/get.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/utils/browsing_history.dart';
import '../../../../core/utils/search_history.dart';
import '../../../home/data/models/product_model.dart';

class SearchController extends GetxController {
  final ApiClient _apiClient = ApiClient();
  var isSearching = false.obs;
  var searchResults = <ProductModel>[].obs;
  var recentSearches = <String>[].obs;
  var recentProducts = <ProductModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadSearchHistory();
  }

  Future<void> loadSearchHistory() async {
    final queries = await SearchHistory.getQueries();
    recentSearches.assignAll(queries);

    final products = await BrowsingHistory.getHistory();
    recentProducts.assignAll(products);
  }

  Future<void> searchProducts(String keyword) async {
    final trimmed = keyword.trim();
    if (trimmed.isEmpty) {
      searchResults.clear();
      return;
    }

    // Save search query to text history
    await SearchHistory.addQuery(trimmed);
    await loadSearchHistory();

    isSearching.value = true;
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.searchKeyword(trimmed));
      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map && data['success'] == true && data['products'] != null) {
          final List list = data['products'];
          final parsed = list.map((x) => ProductModel.fromJson(x)).toList();
          searchResults.value = parsed;

          // Auto-add top searched products to history
          for (var p in parsed.take(3)) {
            await BrowsingHistory.addProduct(p);
          }
          await loadSearchHistory();
        } else {
          searchResults.clear();
        }
      }
    } catch (e) {
      searchResults.clear();
    } finally {
      isSearching.value = false;
    }
  }

  Future<void> addProductToHistory(ProductModel product) async {
    await BrowsingHistory.addProduct(product);
    await loadSearchHistory();
  }

  Future<void> removeProductFromHistory(String productId) async {
    await BrowsingHistory.removeProduct(productId);
    await loadSearchHistory();
  }

  Future<void> clearAllProductHistory() async {
    await BrowsingHistory.clearHistory();
    await loadSearchHistory();
  }

  Future<void> removeSearchItem(String keyword) async {
    await SearchHistory.removeQuery(keyword);
    await loadSearchHistory();
  }

  Future<void> clearAllSearchHistory() async {
    await SearchHistory.clearAll();
    await loadSearchHistory();
  }

  void clearSearch() {
    searchResults.clear();
  }
}
