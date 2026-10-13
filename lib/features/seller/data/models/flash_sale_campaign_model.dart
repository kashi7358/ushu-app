class FlashSaleCampaignModel {
  final String id;
  final String title;
  final String storeId;
  final String description;
  final DateTime? startTime;
  final DateTime? endTime;
  final String status;
  final List<FlashSaleProductDetail> products;

  const FlashSaleCampaignModel({
    required this.id,
    required this.title,
    required this.storeId,
    this.description = '',
    this.startTime,
    this.endTime,
    this.status = 'active',
    this.products = const [],
  });

  bool get isOngoing {
    final now = DateTime.now();
    if (startTime != null && endTime != null) {
      return now.isAfter(startTime!) && now.isBefore(endTime!);
    }
    return status.toLowerCase() == 'active';
  }

  bool get isUpcoming {
    final now = DateTime.now();
    if (startTime != null) {
      return now.isBefore(startTime!);
    }
    return false;
  }

  bool get isExpired {
    final now = DateTime.now();
    if (endTime != null) {
      return now.isAfter(endTime!);
    }
    return status.toLowerCase() == 'expired' || status.toLowerCase() == 'ended';
  }

  factory FlashSaleCampaignModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic val) {
      if (val == null) return null;
      return DateTime.tryParse(val.toString())?.toLocal();
    }

    String extractedStoreId = '';
    if (json['storeId'] is Map) {
      extractedStoreId = json['storeId']['_id']?.toString() ?? json['storeId']['id']?.toString() ?? '';
    } else if (json['store'] is Map) {
      extractedStoreId = json['store']['_id']?.toString() ?? json['store']['id']?.toString() ?? '';
    } else {
      extractedStoreId = json['storeId']?.toString() ?? json['store']?.toString() ?? '';
    }

    final List<FlashSaleProductDetail> parsedProducts = [];
    final rawProducts = json['products'];
    if (rawProducts is List) {
      for (var item in rawProducts) {
        if (item is Map<String, dynamic>) {
          parsedProducts.add(FlashSaleProductDetail.fromJson(item));
        } else if (item is Map) {
          parsedProducts.add(FlashSaleProductDetail.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }

    return FlashSaleCampaignModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Flash Sale Campaign',
      storeId: extractedStoreId,
      description: json['description']?.toString() ?? '',
      startTime: parseDate(json['startTime'] ?? json['startDate']),
      endTime: parseDate(json['endTime'] ?? json['endDate']),
      status: json['status']?.toString() ?? 'active',
      products: parsedProducts,
    );
  }
}

class FlashSaleProductDetail {
  final String productId;
  final String productName;
  final String productImage;
  final double originalPrice;
  final String discountType;
  final num discountValue;
  final int stockLimit;
  final bool isFreeShipping;
  final int maxPerUser;

  const FlashSaleProductDetail({
    required this.productId,
    this.productName = '',
    this.productImage = '',
    this.originalPrice = 0.0,
    this.discountType = 'percentage',
    this.discountValue = 0,
    this.stockLimit = 0,
    this.isFreeShipping = false,
    this.maxPerUser = 1,
  });

  double get discountedPrice {
    if (originalPrice <= 0) return 0;
    if (discountType.toLowerCase() == 'percentage') {
      final cut = originalPrice * (discountValue / 100);
      return (originalPrice - cut).clamp(0, double.infinity);
    } else {
      return (originalPrice - discountValue).clamp(0, double.infinity);
    }
  }

  factory FlashSaleProductDetail.fromJson(Map<String, dynamic> json) {
    num parseNum(dynamic val) {
      if (val == null) return 0;
      if (val is num) return val;
      return num.tryParse(val.toString()) ?? 0;
    }

    String pId = '';
    String pName = '';
    String pImg = '';
    double origPrice = 0.0;

    final prodField = json['productId'] ?? json['product'];
    if (prodField is Map) {
      pId = prodField['_id']?.toString() ?? prodField['id']?.toString() ?? '';
      pName = prodField['name']?.toString() ?? prodField['title']?.toString() ?? '';
      origPrice = parseNum(prodField['price']).toDouble();

      if (prodField['image'] != null) {
        pImg = prodField['image'].toString();
      } else if (prodField['BannerImage'] != null) {
        pImg = prodField['BannerImage'].toString();
      } else if (prodField['images'] is List && (prodField['images'] as List).isNotEmpty) {
        final firstImg = (prodField['images'] as List).first;
        if (firstImg is String) {
          pImg = firstImg;
        } else if (firstImg is Map) {
          pImg = firstImg['photo']?.toString() ?? firstImg['url']?.toString() ?? '';
        }
      }
    } else if (prodField != null) {
      pId = prodField.toString();
    }

    if (pName.isEmpty) pName = json['productName']?.toString() ?? json['name']?.toString() ?? '';
    if (pImg.isEmpty) pImg = json['productImage']?.toString() ?? json['image']?.toString() ?? '';
    if (origPrice <= 0) origPrice = parseNum(json['price'] ?? json['originalPrice']).toDouble();

    return FlashSaleProductDetail(
      productId: pId,
      productName: pName,
      productImage: pImg,
      originalPrice: origPrice,
      discountType: json['discountType']?.toString() ?? 'percentage',
      discountValue: parseNum(json['discountValue']),
      stockLimit: parseNum(json['stockLimit']).toInt(),
      isFreeShipping: json['isFreeShipping'] == true || json['isFreeShipping'] == 'true',
      maxPerUser: parseNum(json['maxPerUser'] ?? 1).toInt(),
    );
  }
}
