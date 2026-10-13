import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../core/errors/exception_handler.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/custom_popup.dart';
import '../../../../core/utils/session_manager.dart';
import '../../data/datasources/seller_remote_data_source.dart';
import '../../data/models/seller_product_model.dart';
import '../../data/repositories/seller_repository_impl.dart';
import '../../domain/repositories/seller_repository.dart';

class ManageProductsController extends GetxController {
  final RxList<SellerProductModel> products = <SellerProductModel>[].obs;
  final RxList<SellerProductModel> filteredProducts = <SellerProductModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isDeleting = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString searchQuery = ''.obs;
  final TextEditingController searchController = TextEditingController();

  late final SellerRepository _repository;
  String currentStoreId = '';

  @override
  void onInit() {
    super.onInit();
    final apiClient = ApiClient();
    final remoteDataSource = SellerRemoteDataSourceImpl(apiClient);
    _repository = SellerRepositoryImpl(remoteDataSource);

    // Get storeId from arguments or SessionManager
    final args = Get.arguments;
    if (args is Map && args['storeId'] != null && args['storeId'].toString().isNotEmpty) {
      currentStoreId = args['storeId'].toString();
    } else {
      currentStoreId = SessionManager.sellerStoreId ?? '';
    }

    fetchProducts();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  Future<void> fetchProducts() async {
    if (currentStoreId.isEmpty) {
      currentStoreId = SessionManager.sellerStoreId ?? '';
    }

    if (currentStoreId.isEmpty) {
      try {
        final statsResponse = await _repository.getDashboardStats();
        if (statsResponse is Map) {
          final dynamic storeObj = statsResponse['store'];
          final foundId = statsResponse['storeId'] ??
              (storeObj is Map ? (storeObj['_id'] ?? storeObj['id']) : null) ??
              statsResponse['data']?['storeId'] ??
              statsResponse['stats']?['storeId'];
          if (foundId != null && foundId.toString().isNotEmpty) {
            currentStoreId = foundId.toString();
            await SessionManager.saveSellerStoreId(currentStoreId);
          }
        }
      } catch (_) {
        // Fall through to error check if rehydration fails
      }
    }

    if (currentStoreId.isEmpty) {
      errorMessage.value = 'Store reference not found. Please setup your store first.';
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await _repository.getProductsByStore(currentStoreId);

      final List<SellerProductModel> loaded = [];

      dynamic rawList;
      if (response is Map) {
        rawList = response['products'] ??
            response['data'] ??
            response['allProducts'] ??
            response['items'];
      } else if (response is List) {
        rawList = response;
      }

      if (rawList is List) {
        for (var item in rawList) {
          if (item is Map<String, dynamic>) {
            loaded.add(SellerProductModel.fromJson(item));
          } else if (item is Map) {
            loaded.add(SellerProductModel.fromJson(Map<String, dynamic>.from(item)));
          }
        }
      }

      products.assignAll(loaded);
      applyFilter(searchQuery.value);
    } catch (e) {
      final error = ExceptionHandler.handle(e);
      errorMessage.value = error.message;
    } finally {
      isLoading.value = false;
    }
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
    applyFilter(query);
  }

  final RxString selectedTab = 'All'.obs; // 'All', 'Active', 'Inactive', 'Draft'

  void onTabChanged(String tab) {
    selectedTab.value = tab;
    applyFilter(searchQuery.value);
  }

  int get allCount => products.length;
  int get activeCount => products.where((p) => p.isActive).length;
  int get inactiveCount => products.where((p) => p.isInactive).length;
  int get draftCount => products.where((p) => p.isDraft).length;

  void applyFilter(String query) {
    List<SellerProductModel> list = products;

    // Filter by tab
    if (selectedTab.value == 'Active') {
      list = list.where((p) => p.isActive).toList();
    } else if (selectedTab.value == 'Inactive') {
      list = list.where((p) => p.isInactive).toList();
    } else if (selectedTab.value == 'Draft') {
      list = list.where((p) => p.isDraft).toList();
    }

    // Filter by search query
    if (query.trim().isNotEmpty) {
      final q = query.trim().toLowerCase();
      list = list.where((p) {
        return p.name.toLowerCase().contains(q) ||
            p.sku.toLowerCase().contains(q) ||
            p.category.toLowerCase().contains(q) ||
            p.brand.toLowerCase().contains(q);
      }).toList();
    }

    filteredProducts.assignAll(list);
  }

  Future<void> confirmDeleteProduct(SellerProductModel product) async {
    final bool? confirm = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.delete_forever_rounded, color: Colors.red, size: 26),
            SizedBox(width: 8),
            Text('Delete Product', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          'Are you sure you want to delete "${product.name}"? This action cannot be undone.',
          style: const TextStyle(fontSize: 14, color: Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await deleteProduct(product.id, product.name);
    }
  }

  Future<void> deleteProduct(String productId, String productName) async {
    try {
      isDeleting.value = true;
      CustomPopup.showLoading('Deleting product...');

      final response = await _repository.deleteProduct(productId);
      CustomPopup.hideLoading();

      products.removeWhere((p) => p.id == productId);
      filteredProducts.removeWhere((p) => p.id == productId);

      final msg = (response is Map && response['message'] != null)
          ? response['message'].toString()
          : '$productName deleted successfully';

      CustomPopup.showToast('Success', msg);
    } catch (e) {
      CustomPopup.hideLoading();
      final error = ExceptionHandler.handle(e);
      CustomPopup.showToast('Delete Failed', error.message, isError: true);
    } finally {
      isDeleting.value = false;
    }
  }

  void navigateToAddProduct() {
    Get.toNamed(
      AppRoutes.sellerCreateProduct,
      arguments: {
        'storeId': currentStoreId,
      },
    )?.then((value) {
      // Refresh list when returning from Add Product screen
      fetchProducts();
    });
  }

  void navigateToEditProduct(SellerProductModel product) {
    Get.toNamed(
      AppRoutes.sellerCreateProduct,
      arguments: {
        'storeId': currentStoreId,
        'product': product,
        'isEdit': true,
      },
    )?.then((value) {
      // Refresh list when returning from Edit Product screen
      if (value == true || value == null) {
        fetchProducts();
      }
    });
  }
}
