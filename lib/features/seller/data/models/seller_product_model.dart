class SellerProductModel {
  final String id;
  final String name;
  final String description;
  final String sku;
  final double price;
  final String priceCurrency;
  final String category;
  final String subCategory;
  final String brand;
  final int stock;
  final int lowStockThreshold;
  final String condition;
  final String status; // 'active', 'inactive', 'draft'
  final List<String> images;
  final String primaryImage;
  final bool trackInventory;

  const SellerProductModel({
    required this.id,
    required this.name,
    this.description = '',
    this.sku = '',
    this.price = 0.0,
    this.priceCurrency = 'PKR',
    this.category = '',
    this.subCategory = '',
    this.brand = '',
    this.stock = 0,
    this.lowStockThreshold = 0,
    this.condition = 'new',
    this.status = 'active',
    this.images = const [],
    this.primaryImage = '',
    this.trackInventory = true,
  });

  bool get isActive => status.toLowerCase() == 'active' || (status.isEmpty && stock > 0);
  bool get isInactive => status.toLowerCase() == 'inactive' || (status.toLowerCase() != 'draft' && stock <= 0);
  bool get isDraft => status.toLowerCase() == 'draft';

  factory SellerProductModel.fromJson(Map<String, dynamic> json) {
    num parseNum(dynamic val) {
      if (val == null) return 0;
      if (val is num) return val;
      return num.tryParse(val.toString()) ?? 0;
    }

    // Parse images list
    List<String> parsedImages = [];
    if (json['images'] != null && json['images'] is List) {
      for (var item in json['images']) {
        if (item is String && item.isNotEmpty) {
          parsedImages.add(item);
        } else if (item is Map && item['photo'] != null) {
          parsedImages.add(item['photo'].toString());
        } else if (item is Map && item['url'] != null) {
          parsedImages.add(item['url'].toString());
        }
      }
    }

    String primaryImg = json['image']?.toString() ??
        json['BannerImage']?.toString() ??
        json['photo']?.toString() ??
        (parsedImages.isNotEmpty ? parsedImages.first : '');

    // Status parsing
    String rawStatus = json['status']?.toString().toLowerCase().trim() ?? '';
    if (rawStatus.isEmpty) {
      if (json['isActive'] == false || json['active'] == false) {
        rawStatus = 'inactive';
      } else if (json['isDraft'] == true || json['draft'] == true) {
        rawStatus = 'draft';
      } else {
        rawStatus = 'active';
      }
    }

    return SellerProductModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? json['title']?.toString() ?? 'Unnamed Product',
      description: json['description']?.toString() ?? '',
      sku: json['sku']?.toString() ?? '',
      price: parseNum(json['price']).toDouble(),
      priceCurrency: json['priceCurrency']?.toString() ?? 'PKR',
      category: json['category'] is Map ? (json['category']['name']?.toString() ?? '') : (json['category']?.toString() ?? ''),
      subCategory: json['SubCategory']?.toString() ?? json['subCategory']?.toString() ?? '',
      brand: json['brand']?.toString() ?? '',
      stock: parseNum(json['stock']).toInt(),
      lowStockThreshold: parseNum(json['lowStockThreshold']).toInt(),
      condition: json['condition']?.toString() ?? 'new',
      status: rawStatus,
      images: parsedImages,
      primaryImage: primaryImg,
      trackInventory: json['trackInventory'] == true || json['trackInventory'] == 'true',
    );
  }
}
