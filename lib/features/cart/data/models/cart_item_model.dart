class CartItemModel {
  final String id;
  final String productId;
  final String name;
  final String image;
  final num price;
  final int quantity;
  final bool isSelected;

  CartItemModel({
    required this.id,
    required this.productId,
    required this.name,
    required this.image,
    required this.price,
    required this.quantity,
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
      isSelected: json['isSelected'] ?? false,
    );
  }
}
