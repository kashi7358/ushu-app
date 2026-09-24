import '../../domain/entities/product_entity.dart';

class ProductModel extends ProductEntity {
  ProductModel({
    required super.id,
    required super.name,
    required super.price,
    super.discountPriceOrg,
    required super.priceCurrency,
    required super.category,
    required super.brand,
    required super.stock,
    required super.image,
    required super.rating,
    required super.totalReviews,
    super.description,
    super.images,
    super.storeName,
    super.storeLogo,
    super.storeId,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    num parseNum(dynamic val) {
      if (val == null) return 0;
      if (val is num) return val;
      return num.tryParse(val.toString()) ?? 0;
    }

    // Parse main image
    String mainImage = json['image']?.toString() ?? json['BannerImage']?.toString() ?? json['photo']?.toString() ?? '';
    
    // Parse detailed images
    List<String> parsedImages = [];
    if (json['images'] != null && json['images'] is List) {
      for (var img in json['images']) {
        if (img is Map && img['photo'] != null) {
          parsedImages.add(img['photo'].toString());
        } else if (img is String && img.isNotEmpty) {
          parsedImages.add(img);
        }
      }
      if (mainImage.isEmpty && parsedImages.isNotEmpty) {
        mainImage = parsedImages.first;
      }
    }

    // Parse store
    String? sName;
    String? sLogo;
    String? sId;

    if (json['storeId'] != null) {
      if (json['storeId'] is Map) {
        sName = json['storeId']['StoreName']?.toString() ?? json['storeId']['storeName']?.toString();
        sLogo = json['storeId']['logo']?.toString();
        sId = json['storeId']['createdBy']?.toString() ?? json['storeId']['_id']?.toString();
      } else {
        sId = json['storeId'].toString();
      }
    }
    
    if (json['createdBy'] != null) {
      sId = json['createdBy'] is Map ? json['createdBy']['_id']?.toString() : json['createdBy']?.toString();
    }

    return ProductModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? json['title']?.toString() ?? '',
      price: parseNum(json['price']).toDouble(),
      discountPriceOrg: json['discountPriceOrg'] != null && json['discountPriceOrg'].toString().isNotEmpty
          ? parseNum(json['discountPriceOrg']).toDouble()
          : null,
      priceCurrency: json['priceCurrency']?.toString() ?? 'PKR',
      category: json['category']?.toString() ?? '',
      brand: json['brand']?.toString() ?? '',
      stock: parseNum(json['stock']).toInt(),
      image: mainImage,
      rating: parseNum(json['rating']).toDouble(),
      totalReviews: parseNum(json['totalReviews']).toInt(),
      description: json['description']?.toString(),
      images: parsedImages,
      storeName: sName,
      storeLogo: sLogo,
      storeId: sId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'price': price,
      'discountPriceOrg': discountPriceOrg,
      'priceCurrency': priceCurrency,
      'category': category,
      'brand': brand,
      'stock': stock,
      'image': image,
      'rating': rating,
      'totalReviews': totalReviews,
      'description': description,
      'images': images,
      'store': {
        '_id': storeId,
        'StoreName': storeName,
        'logo': storeLogo,
      },
    };
  }
}
