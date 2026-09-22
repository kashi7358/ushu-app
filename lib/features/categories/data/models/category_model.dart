class CategoryModel {
  final String category;
  final int productCount;
  final List<String> subCategories;
  final String image;

  CategoryModel({
    required this.category,
    required this.productCount,
    required this.subCategories,
    required this.image,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      category: json['category'] ?? '',
      productCount: json['productCount'] ?? 0,
      subCategories: List<String>.from(json['subCategories'] ?? []),
      image: json['image'] ?? '',
    );
  }
}
