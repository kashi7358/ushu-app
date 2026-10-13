import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../core/errors/exception_handler.dart';
import '../../../../core/network/api_client.dart';
import '../../data/datasources/seller_remote_data_source.dart';
import '../../data/models/seller_promotion_model.dart';
import '../../data/repositories/seller_repository_impl.dart';

class SellerPromotionsController extends GetxController {
  final RxList<SellerPromotionModel> allPromotions = <SellerPromotionModel>[].obs;
  final RxList<SellerPromotionModel> filteredPromotions = <SellerPromotionModel>[].obs;

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString selectedTab = 'All'.obs; // 'All', 'Active', 'Upcoming', 'Expired'
  final RxString searchQuery = ''.obs;
  final TextEditingController searchController = TextEditingController();

  late final SellerRepositoryImpl _repository;

  @override
  void onInit() {
    super.onInit();
    final apiClient = ApiClient();
    final remoteDataSource = SellerRemoteDataSourceImpl(apiClient);
    _repository = SellerRepositoryImpl(remoteDataSource);

    fetchPromotions();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  Future<void> fetchPromotions() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await _repository.getSellerPromotions();
      final List<SellerPromotionModel> loaded = [];

      void parseList(dynamic list) {
        if (list is List) {
          for (final item in list) {
            if (item is Map) {
              loaded.add(SellerPromotionModel.fromJson(Map<String, dynamic>.from(item)));
            }
          }
        }
      }

      if (response is List) {
        parseList(response);
      } else if (response is Map) {
        final data = response['promotions'] ??
            response['campaigns'] ??
            response['flashSales'] ??
            response['vouchers'] ??
            response['coupons'] ??
            response['data'];

        if (data is List) {
          parseList(data);
        } else if (data is Map) {
          parseList(data['promotions']);
          parseList(data['campaigns']);
          parseList(data['flashSales']);
          parseList(data['vouchers']);
          parseList(data['coupons']);
          parseList(data['items']);
          parseList(data['docs']);

          // If data itself is a single promotion object
          if (loaded.isEmpty && (data['title'] != null || data['name'] != null || data['_id'] != null)) {
            loaded.add(SellerPromotionModel.fromJson(Map<String, dynamic>.from(data)));
          }
        }
      }

      allPromotions.assignAll(loaded);
      applyFilter();
    } catch (e) {
      final error = ExceptionHandler.handle(e);
      errorMessage.value = error.message;
    } finally {
      isLoading.value = false;
    }
  }

  void onTabChanged(String tab) {
    selectedTab.value = tab;
    applyFilter();
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
    applyFilter();
  }

  int get allCount => allPromotions.length;
  int get activeCount => allPromotions.where((p) => p.isActive).length;
  int get upcomingCount => allPromotions.where((p) => p.isUpcoming).length;
  int get expiredCount => allPromotions.where((p) => p.isExpired).length;

  void applyFilter() {
    List<SellerPromotionModel> list = allPromotions.toList();

    switch (selectedTab.value) {
      case 'Active':
        list = list.where((p) => p.isActive).toList();
        break;
      case 'Upcoming':
        list = list.where((p) => p.isUpcoming).toList();
        break;
      case 'Expired':
        list = list.where((p) => p.isExpired).toList();
        break;
    }

    if (searchQuery.value.trim().isNotEmpty) {
      final q = searchQuery.value.trim().toLowerCase();
      list = list.where((p) {
        return p.title.toLowerCase().contains(q) ||
            p.description.toLowerCase().contains(q) ||
            p.code.toLowerCase().contains(q) ||
            p.type.toLowerCase().contains(q);
      }).toList();
    }

    filteredPromotions.assignAll(list);
  }

  void navigateToCreateFlashSale() {
    Get.toNamed(AppRoutes.sellerCreateFlashSale)?.then((res) {
      if (res == true) {
        fetchPromotions();
      }
    });
  }

  void navigateToManageFlashSales() {
    Get.toNamed(AppRoutes.sellerManageFlashSales)?.then((_) {
      fetchPromotions();
    });
  }
}
