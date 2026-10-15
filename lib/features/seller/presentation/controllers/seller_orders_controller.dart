import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/errors/exception_handler.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/session_manager.dart';
import '../../data/datasources/seller_remote_data_source.dart';
import '../../data/models/seller_order_model.dart';
import '../../data/models/seller_product_model.dart';
import '../../data/repositories/seller_repository_impl.dart';

class SellerOrdersController extends GetxController {
  final RxList<SellerOrderModel> allOrders = <SellerOrderModel>[].obs;
  final RxList<SellerOrderModel> filteredOrders = <SellerOrderModel>[].obs;
  final RxMap<String, SellerProductModel> storeProductsMap = <String, SellerProductModel>{}.obs;

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString selectedTab = 'All'.obs; // 'All', 'Pending', 'Processing', 'Completed', 'Cancelled'
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

    final args = Get.arguments;
    if (args is Map && args['tab'] != null) {
      selectedTab.value = args['tab'].toString();
    }

    fetchSellerOrders();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  Future<void> fetchSellerOrders() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      if (currentStoreId.isEmpty) {
        currentStoreId = SessionManager.sellerStoreId ?? '';
      }

      if (currentStoreId.isNotEmpty && storeProductsMap.isEmpty) {
        _loadStoreProductsInBackground();
      }

      final results = await Future.wait([
        _repository.getSellerOrders(),
        _repository.getSellerDeliveredOrders().catchError((_) => null),
        _repository.getSellerRefundedOrders().catchError((_) => null),
      ]);
      final response = results[0];
      final deliveredResponse = results[1];
      final refundedResponse = results[2];

      final List<SellerOrderModel> loaded = [];

      dynamic rawList;
      if (response is Map) {
        rawList = response['orders'] ??
            response['sellerOrders'] ??
            response['subOrders'] ??
            response['data'] ??
            response['allOrders'];
        if (rawList is Map) {
          rawList = rawList['orders'] ?? rawList['docs'] ?? rawList['data'] ?? rawList['items'];
        }
      } else if (response is List) {
        rawList = response;
      }

      if (rawList is List) {
        for (var item in rawList) {
          if (item is Map) {
            final mapData = Map<String, dynamic>.from(item);
            if (mapData['subOrders'] is List && (mapData['subOrders'] as List).isNotEmpty) {
              for (var sub in (mapData['subOrders'] as List)) {
                if (sub is Map) {
                  final subMap = Map<String, dynamic>.from(sub);
                  subMap['status'] ??= mapData['status'] ?? mapData['orderStatus'];
                  subMap['createdAt'] ??= mapData['createdAt'];
                  subMap['orderGroupId'] ??= mapData['orderGroupId'];
                  subMap['buyer'] ??= mapData['buyer'] ?? mapData['user'];
                  subMap['address'] ??= mapData['address'] ?? mapData['shippingAddress'];
                  subMap['paymentMethod'] ??= mapData['paymentMethod'];
                  subMap['paymentStatus'] ??= mapData['paymentStatus'];
                  loaded.add(SellerOrderModel.fromJson(subMap));
                }
              }
            } else {
              loaded.add(SellerOrderModel.fromJson(mapData));
            }
          }
        }
      }

      // Merge from dedicated Delivered Orders endpoint
      if (deliveredResponse != null) {
        dynamic delList;
        if (deliveredResponse is Map) {
          delList = deliveredResponse['orders'] ??
              deliveredResponse['deliveredOrders'] ??
              deliveredResponse['data'] ??
              deliveredResponse['items'];
        } else if (deliveredResponse is List) {
          delList = deliveredResponse;
        }
        if (delList is List) {
          final existingIds = loaded.map((o) => o.id).toSet();
          for (var item in delList) {
            if (item is Map) {
              final model = SellerOrderModel.fromJson(Map<String, dynamic>.from(item));
              if (!existingIds.contains(model.id)) {
                loaded.add(model);
                existingIds.add(model.id);
              }
            }
          }
        }
      }

      // Merge from dedicated Refunded Orders endpoint
      if (refundedResponse != null) {
        dynamic refList;
        if (refundedResponse is Map) {
          refList = refundedResponse['orders'] ??
              refundedResponse['refundedOrders'] ??
              refundedResponse['returns'] ??
              refundedResponse['refunds'] ??
              refundedResponse['data'] ??
              refundedResponse['items'];
        } else if (refundedResponse is List) {
          refList = refundedResponse;
        }
        if (refList is List) {
          final existingIds = loaded.map((o) => o.id).toSet();
          for (var item in refList) {
            if (item is Map) {
              final map = Map<String, dynamic>.from(item);
              if (map['status'] == null || map['status'].toString().isEmpty) {
                map['status'] = 'Refunded';
              }
              final model = SellerOrderModel.fromJson(map);
              if (!existingIds.contains(model.id)) {
                loaded.add(model);
                existingIds.add(model.id);
              }
            }
          }
        }
      }

      // Sort newest first
      loaded.sort((a, b) {
        final dtA = DateTime.tryParse(a.createdAt);
        final dtB = DateTime.tryParse(b.createdAt);
        if (dtA != null && dtB != null) {
          return dtB.compareTo(dtA);
        }
        return 0;
      });

      allOrders.assignAll(loaded);
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

  int get allCount => allOrders.length;
  int get pendingCount => allOrders.where((o) => o.isPending).length;
  int get processingCount => allOrders.where((o) => o.isProcessing).length;
  int get completedCount => allOrders.where((o) => o.isCompleted).length;
  int get cancelledCount => allOrders.where((o) => o.isCancelled).length;

  void applyFilter() {
    List<SellerOrderModel> list = allOrders.toList();

    switch (selectedTab.value) {
      case 'Pending':
        list = list.where((o) => o.isPending).toList();
        break;
      case 'Processing':
        list = list.where((o) => o.isProcessing).toList();
        break;
      case 'Completed':
        list = list.where((o) => o.isCompleted).toList();
        break;
      case 'Cancelled':
        list = list.where((o) => o.isCancelled).toList();
        break;
    }

    if (searchQuery.value.trim().isNotEmpty) {
      final q = searchQuery.value.trim().toLowerCase();
      list = list.where((o) {
        final matchesOrder = o.id.toLowerCase().contains(q) ||
            o.orderGroupId.toLowerCase().contains(q) ||
            o.displayOrderId.toLowerCase().contains(q) ||
            o.buyerName.toLowerCase().contains(q) ||
            o.buyerPhone.toLowerCase().contains(q) ||
            o.shippingAddress.toLowerCase().contains(q);
        final matchesProduct = o.items.any((it) => it.productName.toLowerCase().contains(q));
        return matchesOrder || matchesProduct;
      }).toList();
    }

    filteredOrders.assignAll(list);
  }
}
