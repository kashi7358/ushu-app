import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../core/errors/exception_handler.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/custom_popup.dart';
import '../../../../core/utils/session_manager.dart';
import '../../data/datasources/seller_remote_data_source.dart';
import '../../data/models/flash_sale_campaign_model.dart';
import '../../data/models/seller_product_model.dart';
import '../../data/repositories/seller_repository_impl.dart';

class ManageFlashSalesController extends GetxController {
  final RxList<FlashSaleCampaignModel> allCampaigns = <FlashSaleCampaignModel>[].obs;
  final RxList<FlashSaleCampaignModel> filteredCampaigns = <FlashSaleCampaignModel>[].obs;
  final RxMap<String, SellerProductModel> storeProductsMap = <String, SellerProductModel>{}.obs;

  final RxBool isLoading = false.obs;
  final RxBool isDeleting = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString selectedTab = 'All'.obs; // 'All', 'Ongoing', 'Upcoming', 'Expired'
  final RxString searchQuery = ''.obs;
  final TextEditingController searchController = TextEditingController();

  late final SellerRepositoryImpl _repository;
  String currentStoreId = '';

  @override
  void onInit() {
    super.onInit();
    final apiClient = ApiClient();
    final remoteDataSource = SellerRemoteDataSourceImpl(apiClient);
    _repository = SellerRepositoryImpl(remoteDataSource);

    currentStoreId = SessionManager.sellerStoreId ?? '';
    fetchFlashSales();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  Future<void> fetchFlashSales() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      if (currentStoreId.isEmpty) {
        currentStoreId = SessionManager.sellerStoreId ?? '';
      }

      // Load store products in background without blocking getAllFlashSales
      if (currentStoreId.isNotEmpty && storeProductsMap.isEmpty) {
        _loadStoreProductsInBackground();
      }

      final response = await _repository.getAllFlashSales();
      final List<FlashSaleCampaignModel> loaded = [];

      dynamic rawList;
      if (response is Map) {
        rawList = response['flashSales'] ??
            response['data'] ??
            response['sales'] ??
            response['allFlashSales'] ??
            response['campaigns'];
      } else if (response is List) {
        rawList = response;
      }

      if (rawList is List) {
        for (var item in rawList) {
          if (item is Map) {
            final campaign = FlashSaleCampaignModel.fromJson(Map<String, dynamic>.from(item));
            if (currentStoreId.isEmpty ||
                campaign.storeId.isEmpty ||
                campaign.storeId == currentStoreId) {
              loaded.add(campaign);
            }
          }
        }

        if (loaded.isEmpty && rawList.isNotEmpty) {
          for (var item in rawList) {
            if (item is Map) {
              loaded.add(FlashSaleCampaignModel.fromJson(Map<String, dynamic>.from(item)));
            }
          }
        }
      }

      allCampaigns.assignAll(loaded);
      applyFilter();
    } catch (e) {
      final error = ExceptionHandler.handle(e);
      errorMessage.value = error.message;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadStoreProductsInBackground() async {
    try {
      final prodRes = await _repository.getProductsByStore(currentStoreId);
      dynamic rawProdList;
      if (prodRes is Map) {
        rawProdList = prodRes['products'] ?? prodRes['data'] ?? prodRes['allProducts'];
      } else if (prodRes is List) {
        rawProdList = prodRes;
      }
      if (rawProdList is List) {
        final Map<String, SellerProductModel> map = {};
        for (var item in rawProdList) {
          if (item is Map) {
            final model = SellerProductModel.fromJson(Map<String, dynamic>.from(item));
            map[model.id] = model;
          }
        }
        storeProductsMap.assignAll(map);
      }
    } catch (_) {}
  }

  void onTabChanged(String tab) {
    selectedTab.value = tab;
    applyFilter();
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
    applyFilter();
  }

  int get allCount => allCampaigns.length;
  int get ongoingCount => allCampaigns.where((c) => c.isOngoing).length;
  int get upcomingCount => allCampaigns.where((c) => c.isUpcoming).length;
  int get expiredCount => allCampaigns.where((c) => c.isExpired).length;

  void applyFilter() {
    List<FlashSaleCampaignModel> list = allCampaigns.toList();

    if (selectedTab.value == 'Ongoing') {
      list = list.where((c) => c.isOngoing).toList();
    } else if (selectedTab.value == 'Upcoming') {
      list = list.where((c) => c.isUpcoming).toList();
    } else if (selectedTab.value == 'Expired') {
      list = list.where((c) => c.isExpired).toList();
    }

    if (searchQuery.value.trim().isNotEmpty) {
      final q = searchQuery.value.trim().toLowerCase();
      list = list.where((c) {
        return c.title.toLowerCase().contains(q) ||
            c.description.toLowerCase().contains(q);
      }).toList();
    }

    filteredCampaigns.assignAll(list);
  }

  Future<void> confirmDeleteFlashSale(FlashSaleCampaignModel campaign) async {
    if (campaign.id.isEmpty) {
      CustomPopup.showToast('Invalid ID', 'Flash sale ID is missing', isError: true);
      return;
    }

    final bool? confirm = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.delete_forever_rounded, color: Colors.red, size: 22),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Delete Flash Sale',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to delete "${campaign.title}"? This action cannot be undone.',
          style: const TextStyle(fontSize: 13.5, color: Color(0xFF475569)),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Delete Sale', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await deleteFlashSale(campaign.id, campaign.title);
    }
  }

  Future<void> deleteFlashSale(String id, String title) async {
    try {
      isDeleting.value = true;
      CustomPopup.showLoading('Deleting flash sale...');

      final response = await _repository.deleteFlashSale(id);
      CustomPopup.hideLoading();

      allCampaigns.removeWhere((c) => c.id == id);
      filteredCampaigns.removeWhere((c) => c.id == id);

      final msg = (response is Map && response['message'] != null)
          ? response['message'].toString()
          : '"$title" deleted successfully';

      CustomPopup.showToast('Deleted', msg);
    } catch (e) {
      CustomPopup.hideLoading();
      final error = ExceptionHandler.handle(e);
      CustomPopup.showToast('Delete Failed', error.message, isError: true);
    } finally {
      isDeleting.value = false;
    }
  }

  void navigateToCreateFlashSale() {
    Get.toNamed(AppRoutes.sellerCreateFlashSale)?.then((result) {
      if (result == true) {
        fetchFlashSales();
      }
    });
  }

  void navigateToEditFlashSale(FlashSaleCampaignModel campaign) {
    Get.toNamed(
      AppRoutes.sellerCreateFlashSale,
      arguments: {
        'campaign': campaign,
        'isEdit': true,
      },
    )?.then((result) {
      if (result == true) {
        fetchFlashSales();
      }
    });
  }
}
