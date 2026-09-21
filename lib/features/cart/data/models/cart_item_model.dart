class CartItemModel {
  final String id;
  final String productId;
  final String name;
  final String image;
  final num price;
  final int quantity;
  final int stock;
  final bool isSelected;

  CartItemModel({
    required this.id,
    required this.productId,
    required this.name,
    required this.image,
    required this.price,
    required this.quantity,
    this.stock = 10,
    this.isSelected = false,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['_id'] ?? '',
      productId: json['productId'] ?? '',
      name: json['name'] ?? '',
      image: json['image'] ?? '',
      price: json['price'] ?? 0,
      quantity: json['quantity'] ?? 1,
      stock: json['stock'] ?? 10, // Try to parse stock if provided by backend, else default 10
      isSelected: json['isSelected'] ?? false,
    );
  }

  CartItemModel copyWith({
    String? id,
    String? productId,
    String? name,
    String? image,
    num? price,
    int? quantity,
    int? stock,
    bool? isSelected,
  }) {
    return CartItemModel(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      name: name ?? this.name,
      image: image ?? this.image,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      stock: stock ?? this.stock,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}
