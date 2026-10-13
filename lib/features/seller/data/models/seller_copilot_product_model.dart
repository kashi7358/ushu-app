class SellerCopilotProductModel {
  final String title;
  final String description;
  final String category;
  final String subCategory;
  final String brand;
  final String condition;
  final double price;
  final int stock;
  final List<String> tags;
  final String sku;

  const SellerCopilotProductModel({
    this.title = '',
    this.description = '',
    this.category = '',
    this.subCategory = '',
    this.brand = '',
    this.condition = 'new',
    this.price = 0.0,
    this.stock = 10,
    this.tags = const [],
    this.sku = '',
  });

  factory SellerCopilotProductModel.fromJson(Map<String, dynamic> json) {
    // If response is wrapped in 'data', 'product', or 'result'
    final data = (json['data'] is Map)
        ? json['data'] as Map<String, dynamic>
        : (json['product'] is Map)
            ? json['product'] as Map<String, dynamic>
            : (json['result'] is Map)
                ? json['result'] as Map<String, dynamic>
                : json;

    double parseDouble(dynamic val) {
      if (val == null) return 0.0;
      if (val is double) return val;
      if (val is int) return val.toDouble();
      return double.tryParse(val.toString()) ?? 0.0;
    }

    int parseInt(dynamic val) {
      if (val == null) return 0;
      if (val is int) return val;
      if (val is double) return val.toInt();
      return int.tryParse(val.toString()) ?? 0;
    }

    final rawTags = data['tags'] ?? data['keywords'] ?? [];
    List<String> parsedTags = [];
    if (rawTags is List) {
      parsedTags = rawTags.map((e) => e.toString().trim()).where((e) => e.isNotEmpty).toList();
    } else if (rawTags is String && rawTags.isNotEmpty) {
      parsedTags = rawTags.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    }

    return SellerCopilotProductModel(
      title: (data['title'] ?? data['name'] ?? data['productName'] ?? '').toString(),
      description: (data['description'] ?? data['desc'] ?? data['details'] ?? '').toString(),
      category: (data['category'] ?? data['categoryName'] ?? '').toString(),
      subCategory: (data['subCategory'] ?? data['sub_category'] ?? '').toString(),
      brand: (data['brand'] ?? data['brandName'] ?? '').toString(),
      condition: (data['condition'] ?? 'new').toString(),
      price: parseDouble(data['price'] ?? data['suggestedPrice'] ?? data['targetPrice']),
      stock: parseInt(data['stock'] ?? data['quantity'] ?? data['suggestedStock']) > 0
          ? parseInt(data['stock'] ?? data['quantity'] ?? data['suggestedStock'])
          : 10,
      tags: parsedTags,
      sku: (data['sku'] ?? data['SKU'] ?? '').toString(),
    );
  }
}
