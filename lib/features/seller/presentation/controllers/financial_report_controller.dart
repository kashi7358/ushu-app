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
        _repository.getFinancialReport().catchError((_) => null),
        _repository.getDashboardStats().catchError((_) => null),
        _repository.getSellerOrders().catchError((_) => null),
      ]);

      final financialRes = results[0];
      final statsRes = results[1];
      final ordersRes = results[2];

      double grossRevenue = 0.0;
      double settled = 0.0;
      double pending = 0.0;
      double refunds = 0.0;

      // 1. Try parsing direct financial report response if JSON
      if (financialRes is Map<String, dynamic>) {
        final data = financialRes['data'] ?? financialRes;
        if (data is Map) {
          grossRevenue = _toDouble(data['totalRevenue'] ?? data['grossRevenue'] ?? data['totalEarnings']);
          settled = _toDouble(data['settledPayout'] ?? data['paidAmount'] ?? data['settled']);
          pending = _toDouble(data['pendingEscrow'] ?? data['unpaidAmount'] ?? data['pendingBalance']);
          refunds = _toDouble(data['refundedAmount'] ?? data['refunds']);
        }
      }

      // 2. Supplement from stats if not set
      if (statsRes is Map<String, dynamic>) {
        final stats = SellerDashboardStatsModel.fromJson(statsRes);
        if (grossRevenue == 0.0) grossRevenue = stats.earningAmount;
        if (settled == 0.0) settled = stats.paidAmount > 0 ? stats.paidAmount : stats.earningAmount;
        if (pending == 0.0) pending = stats.unpaidAmount;
      }

      // 3. Parse orders for complete itemized breakdown
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

      allFinancialOrders.assignAll(parsedOrders);

      // Calculate order totals if needed
      final deliveredList = parsedOrders.where((o) => o.isCompleted).toList();
      final pendingList = parsedOrders.where((o) => o.isPending || o.isProcessing).toList();
      final cancelledList = parsedOrders.where((o) => o.isCancelled).toList();

      totalDeliveredCount.value = deliveredList.length;
      totalPendingCount.value = pendingList.length;
      totalRefundedCount.value = cancelledList.length;

      final double calcDelivered = deliveredList.fold(0.0, (sum, o) => sum + o.totalAmount);
      final double calcPending = pendingList.fold(0.0, (sum, o) => sum + o.totalAmount);
      final double calcRefunded = cancelledList.fold(0.0, (sum, o) => sum + o.totalAmount);

      if (settled == 0.0 && calcDelivered > 0) settled = calcDelivered;
      if (pending == 0.0 && calcPending > 0) pending = calcPending;
      if (refunds == 0.0 && calcRefunded > 0) refunds = calcRefunded;
      if (grossRevenue == 0.0) grossRevenue = settled + pending;

      totalRevenue.value = grossRevenue;
      settledPayout.value = settled;
      pendingEscrow.value = pending;
      refundedAmount.value = refunds;
      // Net Profit estimated after platform commission (~5%)
      netProfit.value = (settled * 0.95);

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

    if (filter == 'Delivered') {
      list = list.where((o) => o.isCompleted).toList();
    } else if (filter == 'Pending') {
      list = list.where((o) => o.isPending || o.isProcessing).toList();
    } else if (filter == 'Cancelled') {
      list = list.where((o) => o.isCancelled).toList();
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
