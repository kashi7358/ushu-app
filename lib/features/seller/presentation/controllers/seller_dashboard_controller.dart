import 'package:get/get.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../core/errors/exception_handler.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/session_manager.dart';
import '../../../../core/utils/custom_popup.dart';
import '../../data/datasources/seller_remote_data_source.dart';
import '../../data/models/seller_dashboard_stats_model.dart';
import '../../data/models/seller_order_model.dart';
import '../../data/repositories/seller_repository_impl.dart';

class SellerDashboardController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  final Rx<SellerDashboardStatsModel> stats = const SellerDashboardStatsModel().obs;
  final RxString storeName = ''.obs;
  final RxString storeLogo = ''.obs;
  final RxString storeBanner = ''.obs;
  final RxString sellerName = ''.obs;
  final RxString sellerEmail = ''.obs;

  final RxList<SellerOrderModel> deliveredOrders = <SellerOrderModel>[].obs;
  final RxList<SellerOrderModel> refundedOrders = <SellerOrderModel>[].obs;
  final RxDouble paidAmount = 0.0.obs;
  final RxDouble unpaidAmount = 0.0.obs;

  late final SellerRepositoryImpl _repository;

  @override
  void onInit() {
    super.onInit();
    final apiClient = ApiClient();
    final remoteDataSource = SellerRemoteDataSourceImpl(apiClient);
    _repository = SellerRepositoryImpl(remoteDataSource);

    // Initial load from session
    sellerName.value = SessionManager.sellerName ?? 'Seller Account';
    sellerEmail.value = SessionManager.sellerEmail ?? '';
    storeName.value = SessionManager.sellerStoreName ?? 'My Store';
    storeLogo.value = SessionManager.sellerStoreLogo ?? '';
    final details = SessionManager.getSellerStoreDetailsMap();
    if (details != null) {
      storeBanner.value = details['StoreBanner']?.toString() ??
          details['storeBanner']?.toString() ??
          details['banner']?.toString() ??
          details['cover']?.toString() ??
          '';
    }

    fetchDashboardStats();
  }

  Future<void> fetchDashboardStats() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Trigger store hydration in parallel without blocking dashboard stats display
      _hydrateStoreDetails();

      // Parallelize fetching stats, recent orders, delivered orders, and dedicated refunded orders
      final results = await Future.wait([
        _repository.getDashboardStats(),
        _repository.getSellerOrders().catchError((_) => null),
        _repository.getSellerDeliveredOrders().catchError((_) => null),
        _repository.getSellerRefundedOrders().catchError((_) => null),
      ]);

      final response = results[0];
      final ordersResponse = results[1];
      final deliveredOrdersResponse = results[2];
      final refundedOrdersResponse = results[3];

      if (response is Map<String, dynamic>) {
        final parsed = SellerDashboardStatsModel.fromJson(response);
        stats.value = parsed;

        if (parsed.storeName.isNotEmpty && parsed.storeName != 'My Store') {
          storeName.value = parsed.storeName;
          SessionManager.saveSellerStoreDetails(storeName: parsed.storeName);
        } else if (SessionManager.sellerStoreName != null && SessionManager.sellerStoreName!.isNotEmpty) {
          storeName.value = SessionManager.sellerStoreName!;
        }

        if (parsed.sellerName.isNotEmpty) {
          sellerName.value = parsed.sellerName;
        }
        if (parsed.sellerEmail.isNotEmpty) {
          sellerEmail.value = parsed.sellerEmail;
        }

        paidAmount.value = parsed.paidAmount;
        unpaidAmount.value = parsed.unpaidAmount;
      }

      // 1. Parse Dedicated Delivered Orders API
      final List<SellerOrderModel> directDelivered = [];
      if (deliveredOrdersResponse is Map) {
        final rawDelivered = deliveredOrdersResponse['orders'] ??
            deliveredOrdersResponse['deliveredOrders'] ??
            deliveredOrdersResponse['data'] ??
            deliveredOrdersResponse['items'];
        if (rawDelivered is List) {
          for (final o in rawDelivered) {
            if (o is Map<String, dynamic>) {
              directDelivered.add(SellerOrderModel.fromJson(o));
            } else if (o is Map) {
              directDelivered.add(SellerOrderModel.fromJson(Map<String, dynamic>.from(o)));
            }
          }
        }
      } else if (deliveredOrdersResponse is List) {
        for (final o in deliveredOrdersResponse) {
          if (o is Map<String, dynamic>) {
            directDelivered.add(SellerOrderModel.fromJson(o));
          } else if (o is Map) {
            directDelivered.add(SellerOrderModel.fromJson(Map<String, dynamic>.from(o)));
          }
        }
      }

      // 2. Parse Dedicated Refunded Orders API
      final List<SellerOrderModel> directRefunded = [];
      if (refundedOrdersResponse is Map) {
        final rawRefunded = refundedOrdersResponse['orders'] ??
            refundedOrdersResponse['refundedOrders'] ??
            refundedOrdersResponse['returns'] ??
            refundedOrdersResponse['refunds'] ??
            refundedOrdersResponse['data'] ??
            refundedOrdersResponse['items'];
        if (rawRefunded is List) {
          for (final o in rawRefunded) {
            if (o is Map) {
              final map = Map<String, dynamic>.from(o);
              if (map['status'] == null || map['status'].toString().isEmpty) {
                map['status'] = 'Refunded';
              }
              directRefunded.add(SellerOrderModel.fromJson(map));
            }
          }
        }
      } else if (refundedOrdersResponse is List) {
        for (final o in refundedOrdersResponse) {
          if (o is Map) {
            final map = Map<String, dynamic>.from(o);
            if (map['status'] == null || map['status'].toString().isEmpty) {
              map['status'] = 'Refunded';
            }
            directRefunded.add(SellerOrderModel.fromJson(map));
          }
        }
      }

      // 3. Parse Seller Orders for general active lists and fallback
      if (ordersResponse is Map<String, dynamic>) {
        final rawOrders = ordersResponse['orders'] ??
            ordersResponse['data'] ??
            ordersResponse['sellerOrders'] ??
            [];
        if (rawOrders is List) {
          final List<SellerOrderModel> parsedOrders = [];
          for (final o in rawOrders) {
            if (o is Map<String, dynamic>) {
              parsedOrders.add(SellerOrderModel.fromJson(o));
            } else if (o is Map) {
              parsedOrders.add(SellerOrderModel.fromJson(Map<String, dynamic>.from(o)));
            }
          }

          final delivered = directDelivered.isNotEmpty
              ? directDelivered
              : parsedOrders.where((o) => o.isCompleted).toList();
          final refunded = directRefunded.isNotEmpty
              ? directRefunded
              : parsedOrders.where((o) => o.isCancelled).toList();

          deliveredOrders.assignAll(delivered);
          refundedOrders.assignAll(refunded);

          // If paid / unpaid weren't explicitly provided by stats endpoint, compute intelligently from orders
          if (paidAmount.value == 0.0 && stats.value.earningAmount > 0) {
            paidAmount.value = stats.value.earningAmount;
            unpaidAmount.value = 0.0;
          } else if (paidAmount.value == 0.0 && delivered.isNotEmpty) {
            final double deliveredSum = delivered.fold(0.0, (sum, o) => sum + o.totalAmount);
            final double activeSum = parsedOrders.where((o) => o.isProcessing || o.isPending).fold(0.0, (sum, o) => sum + o.totalAmount);
            paidAmount.value = deliveredSum;
            unpaidAmount.value = activeSum;
          }
        }
      } else {
        if (directDelivered.isNotEmpty) {
          deliveredOrders.assignAll(directDelivered);
        }
        if (directRefunded.isNotEmpty) {
          refundedOrders.assignAll(directRefunded);
        }
      }
    } catch (e) {
      final error = ExceptionHandler.handle(e);
      errorMessage.value = error.message;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _hydrateStoreDetails() async {
    try {
      final storeRes = await _repository.getMyStore();
      if (storeRes is Map && storeRes['success'] == true) {
        final sData = storeRes['data'];
        if (sData is Map) {
          final sName = sData['StoreName']?.toString() ?? sData['storeName']?.toString();
          final sLogo = sData['logo']?.toString();
          final sBanner = sData['StoreBanner']?.toString() ??
              sData['storeBanner']?.toString() ??
              sData['banner']?.toString() ??
              sData['cover']?.toString();
          final sId = sData['_id']?.toString() ?? sData['id']?.toString();
          if (sName != null && sName.isNotEmpty) {
            storeName.value = sName;
          }
          if (sLogo != null && sLogo.isNotEmpty) {
            storeLogo.value = sLogo;
          }
          if (sBanner != null && sBanner.isNotEmpty) {
            storeBanner.value = sBanner;
          }
          if (sId != null && sId.isNotEmpty) {
            await SessionManager.saveSellerStoreId(sId);
          }
          await SessionManager.saveSellerStoreDetails(
            storeName: storeName.value,
            logoPath: storeLogo.value,
            fullDetails: Map<String, dynamic>.from(sData),
          );
        }
      }
    } catch (_) {}
  }

  void navigateToAddProduct() {
    Get.toNamed(
      AppRoutes.sellerCreateProduct,
      arguments: {
        'storeId': SessionManager.sellerStoreId ?? '',
      },
    );
  }

  Future<void> logout() async {
    final bool? confirm = await CustomPopup.showLogoutConfirmation();
    if (confirm ?? false) {
      await SessionManager.clearSellerSession();
      await SessionManager.setLastScreen(null);
      Get.offAllNamed(AppRoutes.sellerLogin);
    }
  }
}
