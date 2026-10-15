class SellerPromotionModel {
  final String id;
  final String title;
  final String description;
  final String code;
  final String type; // e.g. 'percentage', 'fixed', 'flash_sale', 'voucher', 'campaign'
  final num discountValue;
  final num minOrderAmount;
  final int usageLimit;
  final int usedCount;
  final String bannerImage;
  final String status;
  final DateTime? startTime;
  final DateTime? endTime;
  final int productsCount;
  final List<String> productNames;

  final num price;

  const SellerPromotionModel({
    required this.id,
    required this.title,
    this.description = '',
    this.code = '',
    this.type = 'percentage',
    this.discountValue = 0,
    this.minOrderAmount = 0,
    this.usageLimit = 0,
    this.usedCount = 0,
    this.bannerImage = '',
    this.status = 'active',
    this.startTime,
    this.endTime,
    this.productsCount = 0,
    this.productNames = const [],
    this.price = 0,
  });

  bool get isPending {
    final s = status.toLowerCase().trim();
    return s == 'pending' || s == 'under_review';
  }

  bool get isUpcoming {
    if (isPending) return false;
    if (startTime == null) return false;
    return DateTime.now().isBefore(startTime!);
  }

  bool get isExpired {
    final s = status.toLowerCase().trim();
    if (s == 'expired' || s == 'ended' || s == 'inactive' || s == 'cancelled' || s == 'rejected') {
      return true;
    }
    if (endTime == null) return false;
    return DateTime.now().isAfter(endTime!);
  }

  bool get isActive => !isPending && !isUpcoming && !isExpired;

  String get badgeLabel {
    if (isPending) return 'PENDING';
    if (discountValue > 0) {
      if (type.toLowerCase().contains('percent')) {
        return '${discountValue.toInt()}% OFF';
      }
      return 'Rs. ${discountValue.toInt()} OFF';
    }
    if (code.isNotEmpty) return code.toUpperCase();
    return type.toUpperCase();
  }

  factory SellerPromotionModel.fromJson(Map<String, dynamic> json) {
    num parseNum(dynamic val) {
      if (val == null) return 0;
      if (val is num) return val;
      return num.tryParse(val.toString()) ?? 0;
    }

    int parseInt(dynamic val) {
      if (val == null) return 0;
      if (val is int) return val;
      if (val is num) return val.toInt();
      return int.tryParse(val.toString()) ?? 0;
    }

    DateTime? parseDate(dynamic val) {
      if (val == null) return null;
      return DateTime.tryParse(val.toString())?.toLocal();
    }

    final rawProds = json['products'] ?? json['items'] ?? json['applicableProducts'] ?? [];
    int pCount = 0;
    final List<String> pNames = [];
    num firstProdDiscount = 0;
    String firstProdDiscType = '';

    if (rawProds is List) {
      pCount = rawProds.length;
      for (final item in rawProds) {
        if (item is Map) {
          if (firstProdDiscount == 0 && item['discountValue'] != null) {
            firstProdDiscount = parseNum(item['discountValue']);
            firstProdDiscType = (item['discountType'] ?? '').toString();
          }
          final pObj = item['productId'] ?? item['product'] ?? item;
          if (pObj is Map) {
            final n = (pObj['name'] ?? pObj['title'] ?? pObj['productName'] ?? '').toString();
            if (n.isNotEmpty) pNames.add(n);
          } else if (item['name'] != null || item['productName'] != null) {
            pNames.add((item['name'] ?? item['productName']).toString());
          }
        }
      }
    }

    final discVal = parseNum(
      json['discountValue'] ??
          json['discount'] ??
          json['percentage'] ??
          json['discountPercentage'] ??
          json['amount'] ??
          json['value'] ??
          firstProdDiscount,
    );

    final discType = (json['discountType'] ??
            json['promotionType'] ??
            json['type'] ??
            (firstProdDiscType.isNotEmpty ? firstProdDiscType : 'percentage'))
        .toString();

    final rawStatus = (json['status'] ??
            json['state'] ??
            (json['isActive'] == false ? 'inactive' : 'active'))
        .toString();

    return SellerPromotionModel(
      id: (json['_id'] ?? json['id'] ?? json['promotionId'] ?? '').toString(),
      title: (json['title'] ??
              json['Title'] ??
              json['name'] ??
              json['Name'] ??
              json['type'] ??
              json['Type'] ??
              json['promotionType'] ??
              json['PromotionType'] ??
              json['promotionName'] ??
              json['PromotionName'] ??
              json['category'] ??
              json['campaignName'] ??
              json['code'] ??
              'banner')
          .toString(),
      description: (json['description'] ?? json['Description'] ?? json['details'] ?? json['subtitle'] ?? '').toString(),
      code: (json['code'] ?? json['promoCode'] ?? json['couponCode'] ?? json['voucherCode'] ?? '').toString(),
      type: discType,
      discountValue: discVal,
      minOrderAmount: parseNum(
        json['minOrderAmount'] ?? json['minSpend'] ?? json['minimumPurchase'] ?? 0,
      ),
      usageLimit: parseInt(
        json['usageLimit'] ?? json['maxUses'] ?? json['stockLimit'] ?? json['limit'] ?? 0,
      ),
      usedCount: parseInt(
        json['usedCount'] ?? json['uses'] ?? json['redeemedCount'] ?? 0,
      ),
      bannerImage: (json['Bannerimage'] ??
              json['BannerImage'] ??
              json['bannerImage'] ??
              json['bannerimage'] ??
              json['banner'] ??
              json['image'] ??
              json['imageUrl'] ??
              '')
          .toString(),
      status: rawStatus,
      startTime: parseDate(json['startTime'] ?? json['startDate'] ?? json['validFrom'] ?? json['createdAt']),
      endTime: parseDate(json['endTime'] ?? json['endDate'] ?? json['validUntil'] ?? json['expiryDate']),
      productsCount: pCount,
      productNames: pNames,
      price: parseNum(json['price'] ?? json['Price'] ?? 0),
    );
  }
}
