class ProductEntity {
  final String id;
  final String name;
  final double price;
  final double? discountPriceOrg;
  final String priceCurrency;
  final String category;
  final String brand;
  final int stock;
  final String image;
  final double rating;
  final int totalReviews;
  
  // Detailed fields
  final String? description;
  final List<String>? images;
  final String? storeName;
  final String? storeLogo;

  ProductEntity({
    required this.id,
    required this.name,
    required this.price,
    this.discountPriceOrg,
    required this.priceCurrency,
    required this.category,
    required this.brand,
    required this.stock,
    required this.image,
    required this.rating,
    required this.totalReviews,
    this.description,
    this.images,
    this.storeName,
    this.storeLogo,
  });
}
