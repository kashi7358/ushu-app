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
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    // Parse main image
    String mainImage = json['image'] ?? json['BannerImage'] ?? '';
    
    // Parse detailed images
    List<String> parsedImages = [];
    if (json['images'] != null && json['images'] is List) {
      for (var img in json['images']) {
        if (img is Map && img['photo'] != null) {
          parsedImages.add(img['photo']);
        }
      }
      if (mainImage.isEmpty && parsedImages.isNotEmpty) {
        mainImage = parsedImages.first;
      }
    }

    // Parse store
    String? sName;
    String? sLogo;
    if (json['storeId'] != null && json['storeId'] is Map) {
      sName = json['storeId']['StoreName'];
      sLogo = json['storeId']['logo'];
    }

    return ProductModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      discountPriceOrg: json['discountPriceOrg'] != null ? double.tryParse(json['discountPriceOrg'].toString()) : null,
      priceCurrency: json['priceCurrency'] ?? 'PKR',
      category: json['category'] ?? '',
      brand: json['brand'] ?? '',
      stock: json['stock'] ?? 0,
      image: mainImage,
      rating: (json['rating'] ?? 0).toDouble(),
      totalReviews: json['totalReviews'] ?? 0,
      description: json['description'],
      images: parsedImages,
      storeName: sName,
      storeLogo: sLogo,
    );
  }
}
