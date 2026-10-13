class CreateFlashSaleRequestModel {
  final String title;
  final String storeId;
  final String description;
  final String startTime;
  final String endTime;
  final List<FlashSaleProductItemModel> products;

  const CreateFlashSaleRequestModel({
    required this.title,
    required this.storeId,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.products,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'storeId': storeId,
      'description': description,
      'startTime': startTime,
      'endTime': endTime,
      'products': products.map((p) => p.toJson()).toList(),
    };
  }
}

class FlashSaleProductItemModel {
  final String productId;
  final String discountType; // 'percentage' or 'fixed'
  final num discountValue;
  final int stockLimit;
  final bool isFreeShipping;
  final int maxPerUser;

  const FlashSaleProductItemModel({
    required this.productId,
    this.discountType = 'percentage',
    required this.discountValue,
    required this.stockLimit,
    this.isFreeShipping = false,
    this.maxPerUser = 1,
  });

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'discountType': discountType,
      'discountValue': discountValue,
      'stockLimit': stockLimit,
      'isFreeShipping': isFreeShipping,
      'maxPerUser': maxPerUser,
    };
  }
}
