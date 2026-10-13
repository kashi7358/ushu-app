class SellerDashboardStatsModel {
  final String storeName;
  final String sellerName;
  final String sellerEmail;
  final int totalProducts;
  final int totalSalesProducts;
  final int activeOrders;
  final int deliveredOrders;
  final int cancelledOrders;
  final int returnedOrders;
  final double earningAmount;
  final double paidAmount;
  final double unpaidAmount;

  const SellerDashboardStatsModel({
    this.storeName = '',
    this.sellerName = '',
    this.sellerEmail = '',
    this.totalProducts = 0,
    this.totalSalesProducts = 0,
    this.activeOrders = 0,
    this.deliveredOrders = 0,
    this.cancelledOrders = 0,
    this.returnedOrders = 0,
    this.earningAmount = 0.0,
    this.paidAmount = 0.0,
    this.unpaidAmount = 0.0,
  });

  int get totalOrders => activeOrders + deliveredOrders + cancelledOrders + returnedOrders;

  factory SellerDashboardStatsModel.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic val) {
      if (val == null) return 0;
      if (val is int) return val;
      if (val is double) return val.toInt();
      return int.tryParse(val.toString()) ?? 0;
    }

    double parseDouble(dynamic val) {
      if (val == null) return 0.0;
      if (val is double) return val;
      if (val is int) return val.toDouble();
      return double.tryParse(val.toString()) ?? 0.0;
    }

    // Try extracting from nested 'stats', 'data', or top-level
    final stats = (json['stats'] is Map)
        ? json['stats'] as Map<String, dynamic>
        : (json['data'] is Map)
            ? json['data'] as Map<String, dynamic>
            : json;

    final double totalEarning = parseDouble(stats['earningAmount'] ?? stats['totalEarnings'] ?? stats['earnings'] ?? stats['revenue']);
    final double paid = parseDouble(stats['paidAmount'] ?? stats['paidEarnings'] ?? stats['paid'] ?? stats['payoutPaid'] ?? stats['settledEarnings']);
    final double unpaid = parseDouble(stats['unpaidAmount'] ?? stats['unpaidEarnings'] ?? stats['unpaid'] ?? stats['payoutUnpaid'] ?? stats['pendingEarnings']);

    return SellerDashboardStatsModel(
      storeName: json['storeName']?.toString() ??
          stats['storeName']?.toString() ??
          json['store']?['StoreName']?.toString() ??
          json['store']?['storeName']?.toString() ??
          stats['store']?['StoreName']?.toString() ??
          stats['store']?['storeName']?.toString() ??
          '',
      sellerName: json['sellerName']?.toString() ??
          stats['sellerName']?.toString() ??
          json['seller']?['name']?.toString() ??
          '',
      sellerEmail: json['sellerEmail']?.toString() ??
          stats['sellerEmail']?.toString() ??
          json['seller']?['email']?.toString() ??
          '',
      totalProducts: parseInt(stats['totalProducts'] ?? stats['productsCount'] ?? stats['products']),
      totalSalesProducts: parseInt(stats['totalSalesProducts'] ?? stats['totalSales'] ?? stats['salesProducts']),
      activeOrders: parseInt(stats['activeOrders'] ?? stats['pendingOrders'] ?? stats['processingOrders']),
      deliveredOrders: parseInt(stats['deliveredOrders'] ?? stats['completedOrders']),
      cancelledOrders: parseInt(stats['cancelledOrders'] ?? stats['canceledOrders']),
      returnedOrders: parseInt(stats['returnedOrders'] ?? stats['returnsCount']),
      earningAmount: totalEarning,
      paidAmount: paid,
      unpaidAmount: unpaid > 0 ? unpaid : (totalEarning > paid ? totalEarning - paid : 0.0),
    );
  }
}
