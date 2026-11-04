import 'package:get/get.dart';
import '../../../../core/errors/exception_handler.dart';
import '../../../../core/network/api_client.dart';
import '../../data/datasources/seller_remote_data_source.dart';
import '../../data/models/seller_dashboard_stats_model.dart';
import '../../data/models/seller_order_model.dart';
import '../../data/repositories/seller_repository_impl.dart';

class FinancialReportController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  final RxDouble totalRevenue = 0.0.obs;
  final RxDouble settledPayout = 0.0.obs;
  final RxDouble pendingEscrow = 0.0.obs;
  final RxDouble refundedAmount = 0.0.obs;
  final RxDouble netProfit = 0.0.obs;

  final RxInt totalDeliveredCount = 0.obs;
  final RxInt totalPendingCount = 0.obs;
  final RxInt totalRefundedCount = 0.obs;

  final RxList<SellerOrderModel> allFinancialOrders = <SellerOrderModel>[].obs;
  final RxList<SellerOrderModel> filteredOrders = <SellerOrderModel>[].obs;

  final RxString selectedFilter = 'All'.obs; // 'All', 'Delivered', 'Pending', 'Cancelled'
  final RxString searchQuery = ''.obs;

  late final SellerRepositoryImpl _repository;

  @override
  void onInit() {
    super.onInit();
    final apiClient = ApiClient();
    final remoteDataSource = SellerRemoteDataSourceImpl(apiClient);
    _repository = SellerRepositoryImpl(remoteDataSource);

    fetchFinancialReport();
  }

  Future<void> fetchFinancialReport() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final results = await Future.wait([
        _repository.getSellerDeliveredStats().catchError((_) => null),
        _repository.getDashboardStats().catchError((_) => null),
        _repository.getSellerOrders().catchError((_) => null),
        _repository.getSellerDeliveredOrders().catchError((_) => null),
        _repository.getSellerRefundedOrders().catchError((_) => null),
      ]);

      final deliveredStatsRes = results[0];
      final statsRes = results[1];
      final ordersRes = results[2];
      final deliveredOrdersRes = results[3];
      final refundedOrdersRes = results[4];

      double grossRevenue = 0.0;
      double settled = 0.0;
      double pending = 0.0;
      double refunds = 0.0;



      // 2. Supplement from stats if not set
      if (statsRes is Map<String, dynamic>) {
        final stats = SellerDashboardStatsModel.fromJson(statsRes);
        if (grossRevenue == 0.0) grossRevenue = stats.earningAmount;
        if (settled == 0.0) settled = stats.paidAmount > 0 ? stats.paidAmount : stats.earningAmount;
        if (pending == 0.0) pending = stats.unpaidAmount;
      }

      // 3. Parse Dedicated Delivered Stats & Orders API
      final List<SellerOrderModel> directDelivered = [];

      if (deliveredStatsRes is Map) {
        final rawDeliveredStats = deliveredStatsRes['allDeliveredOrders'] ??
            deliveredStatsRes['deliveredOrders'] ??
            deliveredStatsRes['orders'] ??
            deliveredStatsRes['data'];
        if (rawDeliveredStats is List) {
          for (final o in rawDeliveredStats) {
            if (o is Map<String, dynamic>) {
              directDelivered.add(SellerOrderModel.fromJson(o));
            } else if (o is Map) {
              directDelivered.add(SellerOrderModel.fromJson(Map<String, dynamic>.from(o)));
            }
          }
        }

        if (deliveredStatsRes['paidAmount'] != null) {
          settled = _toDouble(deliveredStatsRes['paidAmount']);
        }
        if (deliveredStatsRes['unpaidAmount'] != null) {
          pending = _toDouble(deliveredStatsRes['unpaidAmount']);
        }
        if (deliveredStatsRes['totalPayout'] != null) {
          grossRevenue = _toDouble(deliveredStatsRes['totalPayout']);
          if (settled == 0.0 && pending == 0.0) {
            pending = grossRevenue;
          }
        } else if (deliveredStatsRes['totalPayment'] != null) {
          grossRevenue = _toDouble(deliveredStatsRes['totalPayment']);
        }
      }

      if (directDelivered.isEmpty && deliveredOrdersRes is Map) {
        final rawDelivered = deliveredOrdersRes['orders'] ??
            deliveredOrdersRes['deliveredOrders'] ??
            deliveredOrdersRes['data'] ??
            deliveredOrdersRes['items'];
        if (rawDelivered is List) {
          for (final o in rawDelivered) {
            if (o is Map<String, dynamic>) {
              directDelivered.add(SellerOrderModel.fromJson(o));
            } else if (o is Map) {
              directDelivered.add(SellerOrderModel.fromJson(Map<String, dynamic>.from(o)));
            }
          }
        }
      } else if (deliveredOrdersRes is List) {
        for (final o in deliveredOrdersRes) {
          if (o is Map<String, dynamic>) {
            directDelivered.add(SellerOrderModel.fromJson(o));
          } else if (o is Map) {
            directDelivered.add(SellerOrderModel.fromJson(Map<String, dynamic>.from(o)));
          }
        }
      }

      // 4. Parse Dedicated Refunded Orders
      final List<SellerOrderModel> directRefunded = [];
      if (refundedOrdersRes is Map) {
        final rawRefunded = refundedOrdersRes['orders'] ??
            refundedOrdersRes['refundedOrders'] ??
            refundedOrdersRes['returns'] ??
            refundedOrdersRes['refunds'] ??
            refundedOrdersRes['data'] ??
            refundedOrdersRes['items'];
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
      } else if (refundedOrdersRes is List) {
        for (final o in refundedOrdersRes) {
          if (o is Map) {
            final map = Map<String, dynamic>.from(o);
            if (map['status'] == null || map['status'].toString().isEmpty) {
              map['status'] = 'Refunded';
            }
            directRefunded.add(SellerOrderModel.fromJson(map));
          }
        }
      }

      // 5. Parse orders for complete itemized breakdown
      final List<SellerOrderModel> parsedOrders = [];
      if (ordersRes is Map<String, dynamic>) {
        final rawOrders = ordersRes['orders'] ?? ordersRes['data'] ?? ordersRes['sellerOrders'] ?? [];
        if (rawOrders is List) {
          for (final o in rawOrders) {
            if (o is Map<String, dynamic>) {
              parsedOrders.add(SellerOrderModel.fromJson(o));
            } else if (o is Map) {
              parsedOrders.add(SellerOrderModel.fromJson(Map<String, dynamic>.from(o)));
            }
          }
        }
      }

      // Only delivered orders (both paid and unpaid) shown in Financial Report
      final List<SellerOrderModel> deliveredOnlyOrders = [];
      if (directDelivered.isNotEmpty) {
        deliveredOnlyOrders.addAll(directDelivered);
      } else {
        deliveredOnlyOrders.addAll(parsedOrders.where((o) => o.isCompleted));
      }

      allFinancialOrders.assignAll(deliveredOnlyOrders);

      // Count of delivered orders separated into settled (paid) vs pending (unpaid)
      final paidDeliveredList = deliveredOnlyOrders.where((o) => o.paymentStatus.toLowerCase() == 'paid' || o.paymentStatus.toLowerCase() == 'settled').toList();
      final unpaidDeliveredList = deliveredOnlyOrders.where((o) => o.paymentStatus.toLowerCase() != 'paid' && o.paymentStatus.toLowerCase() != 'settled').toList();

      totalDeliveredCount.value = deliveredOnlyOrders.length;
      totalPendingCount.value = unpaidDeliveredList.length;
      totalRefundedCount.value = directRefunded.length;

      final double calcPaid = paidDeliveredList.fold(0.0, (sum, o) => sum + o.totalAmount);
      final double calcUnpaid = unpaidDeliveredList.fold(0.0, (sum, o) => sum + o.totalAmount);
      final double calcRefunded = directRefunded.fold(0.0, (sum, o) => sum + o.totalAmount);

      if (deliveredStatsRes == null) {
        if (settled == 0.0 && calcPaid > 0) settled = calcPaid;
        if (pending == 0.0 && calcUnpaid > 0) pending = calcUnpaid;
        if (refunds == 0.0 && calcRefunded > 0) refunds = calcRefunded;
        if (grossRevenue == 0.0) grossRevenue = settled + pending;
      } else {
        if (grossRevenue == 0.0) grossRevenue = settled + pending;
      }

      totalRevenue.value = grossRevenue;
      settledPayout.value = settled;
      pendingEscrow.value = pending;
      refundedAmount.value = refunds;
      netProfit.value = settled;

      applyFilters();
    } catch (e) {
      final err = ExceptionHandler.handle(e);
      errorMessage.value = err.message;
    } finally {
      isLoading.value = false;
    }
  }

  void setFilter(String filter) {
    selectedFilter.value = filter;
    applyFilters();
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
    applyFilters();
  }

  void applyFilters() {
    final query = searchQuery.value.trim().toLowerCase();
    final filter = selectedFilter.value;

    List<SellerOrderModel> list = List.from(allFinancialOrders);

    if (filter == 'Paid' || filter == 'Settled') {
      list = list.where((o) => o.paymentStatus.toLowerCase() == 'paid' || o.paymentStatus.toLowerCase() == 'settled').toList();
    } else if (filter == 'Unpaid' || filter == 'Pending') {
      list = list.where((o) => o.paymentStatus.toLowerCase() != 'paid' && o.paymentStatus.toLowerCase() != 'settled').toList();
    }

    if (query.isNotEmpty) {
      list = list.where((o) {
        final idMatch = o.id.toLowerCase().contains(query);
        final nameMatch = o.buyerName.toLowerCase().contains(query);
        final statusMatch = o.status.toLowerCase().contains(query);
        return idMatch || nameMatch || statusMatch;
      }).toList();
    }

    filteredOrders.assignAll(list);
  }

  double _toDouble(dynamic val) {
    if (val == null) return 0.0;
    if (val is num) return val.toDouble();
    return double.tryParse(val.toString()) ?? 0.0;
  }
}
