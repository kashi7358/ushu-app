import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../core/errors/exception_handler.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/session_manager.dart';
import '../../data/datasources/seller_remote_data_source.dart';
import '../../data/models/seller_banner_model.dart';
import '../../data/models/seller_promotion_model.dart';
import '../../data/repositories/seller_repository_impl.dart';

class SellerPromotionsController extends GetxController {
  final RxList<SellerPromotionModel> allPromotions = <SellerPromotionModel>[].obs;
  final RxList<SellerPromotionModel> filteredPromotions = <SellerPromotionModel>[].obs;

  final RxList<SellerBannerModel> myBanners = <SellerBannerModel>[].obs;
  final RxList<SellerBannerModel> filteredBanners = <SellerBannerModel>[].obs;

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString selectedTab = 'All'.obs; // 'All', 'Promotions', 'My Banners'
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

      final results = await Future.wait([
        _repository.getSellerPromotions().catchError((_) => null),
        _repository.getAllBanners().catchError((_) => null),
      ]);

      final promoResponse = results[0];
      final bannerResponse = results[1];

      // 1. Parse Available Promotions (Platform campaigns to apply for)
      final List<SellerPromotionModel> loadedPromotions = [];
      void parsePromoList(dynamic list) {
        if (list is List) {
          for (final item in list) {
            if (item is Map) {
              loadedPromotions.add(SellerPromotionModel.fromJson(Map<String, dynamic>.from(item)));
            }
          }
        }
      }

      if (promoResponse is List) {
        parsePromoList(promoResponse);
      } else if (promoResponse is Map) {
        final data = promoResponse['promotions'] ??
            promoResponse['campaigns'] ??
            promoResponse['flashSales'] ??
            promoResponse['vouchers'] ??
            promoResponse['coupons'] ??
            promoResponse['data'];

        if (data is List) {
          parsePromoList(data);
        } else if (data is Map) {
          parsePromoList(data['promotions']);
          parsePromoList(data['campaigns']);
          parsePromoList(data['flashSales']);
          parsePromoList(data['vouchers']);
          parsePromoList(data['coupons']);
          parsePromoList(data['items']);
          parsePromoList(data['docs']);

          if (loadedPromotions.isEmpty && (data['title'] != null || data['name'] != null || data['_id'] != null)) {
            loadedPromotions.add(SellerPromotionModel.fromJson(Map<String, dynamic>.from(data)));
          }
        }
      }

      // 2. Parse Seller Banners from GET /api/banner/all
      final List<SellerBannerModel> loadedBanners = [];
      dynamic rawBanners;
      if (bannerResponse is Map) {
        rawBanners = bannerResponse['data'] ?? bannerResponse['banners'] ?? bannerResponse['allBanners'];
      } else if (bannerResponse is List) {
        rawBanners = bannerResponse;
      }

      if (rawBanners is List) {
        final currentStoreId = SessionManager.sellerStoreId ?? '';
        final currentSellerId = SessionManager.sellerId ?? '';
        final currentSellerEmail = (SessionManager.sellerEmail ?? '').toLowerCase().trim();

        for (final item in rawBanners) {
          if (item is Map) {
            final model = SellerBannerModel.fromJson(Map<String, dynamic>.from(item));
            // Filter by seller's store or id if available, else include
            final matchesStore = currentStoreId.isNotEmpty && model.storeId == currentStoreId;
            final matchesSeller = currentSellerId.isNotEmpty && model.sellerId == currentSellerId;
            final matchesEmail = currentSellerEmail.isNotEmpty && model.email.toLowerCase().trim() == currentSellerEmail;

            if (matchesStore || matchesSeller || matchesEmail || (currentStoreId.isEmpty && currentSellerId.isEmpty)) {
              loadedBanners.add(model);
            }
          }
        }
      }

      // Sort banners newest first
      loadedBanners.sort((a, b) {
        final dtA = a.createdAt ?? a.startDate;
        final dtB = b.createdAt ?? b.startDate;
        if (dtA != null && dtB != null) return dtB.compareTo(dtA);
        return 0;
      });

      allPromotions.assignAll(loadedPromotions);
      myBanners.assignAll(loadedBanners);
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

  int get allCount => allPromotions.length + myBanners.length;
  int get promotionsCount => allPromotions.length;
  int get bannersCount => myBanners.length;

  void applyFilter() {
    final q = searchQuery.value.trim().toLowerCase();

    // Filter Promotions
    List<SellerPromotionModel> pList = allPromotions.toList();
    if (selectedTab.value == 'My Banners') {
      pList = [];
    }

    if (q.isNotEmpty) {
      pList = pList.where((p) {
        return p.title.toLowerCase().contains(q) ||
            p.description.toLowerCase().contains(q) ||
            p.code.toLowerCase().contains(q);
      }).toList();
    }
    filteredPromotions.assignAll(pList);

    // Filter Banners
    List<SellerBannerModel> bList = myBanners.toList();
    if (selectedTab.value == 'Promotions') {
      bList = [];
    }

    if (q.isNotEmpty) {
      bList = bList.where((b) {
        return b.title.toLowerCase().contains(q) ||
            b.description.toLowerCase().contains(q) ||
            b.name.toLowerCase().contains(q);
      }).toList();
    }
    filteredBanners.assignAll(bList);
  }

  void applyForPromotion(SellerPromotionModel promo) {
    Get.toNamed(
      '/seller/create-banner',
      arguments: {
        'isEdit': false,
        'promotionTitle': promo.title,
        'promotionDescription': promo.description,
      },
    )?.then((res) {
      if (res == true) {
        fetchPromotions();
      }
    });
  }

  void editBanner(SellerBannerModel banner) {
    Get.toNamed(
      '/seller/create-banner',
      arguments: {
        'isEdit': true,
        'bannerId': banner.id,
        'title': banner.title,
        'description': banner.description,
        'name': banner.name,
        'email': banner.email,
        'phone': banner.phone,
        'image': banner.bannerImage,
        'startDate': banner.startDate,
        'endDate': banner.endDate,
      },
    )?.then((res) {
      if (res == true) {
        fetchPromotions();
      }
    });
  }

  void navigateToCreateBanner() {
    Get.toNamed('/seller/create-banner')?.then((res) {
      if (res == true) {
        fetchPromotions();
      }
    });
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
