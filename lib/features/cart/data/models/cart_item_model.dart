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
    int parsedStock = 10;
    if (json['stock'] != null) {
      parsedStock = int.tryParse(json['stock'].toString()) ?? 10;
    } else if (json['productId'] is Map && json['productId']['stock'] != null) {
      parsedStock = int.tryParse(json['productId']['stock'].toString()) ?? 10;
    } else if (json['product'] is Map && json['product']['stock'] != null) {
      parsedStock = int.tryParse(json['product']['stock'].toString()) ?? 10;
    } else if (json['countInStock'] != null) {
      parsedStock = int.tryParse(json['countInStock'].toString()) ?? 10;
    } else if (json['stockQuantity'] != null) {
      parsedStock = int.tryParse(json['stockQuantity'].toString()) ?? 10;
    }

    String parsedProductId = '';
    if (json['productId'] is Map) {
      parsedProductId = json['productId']['_id']?.toString() ?? '';
    } else {
      parsedProductId = json['productId']?.toString() ?? '';
    }

    String parsedName = json['name']?.toString() ?? '';
    if (parsedName.isEmpty && json['productId'] is Map) {
      parsedName = json['productId']['name']?.toString() ?? '';
    }

    String parsedImage = json['image']?.toString() ?? '';
    if (parsedImage.isEmpty && json['productId'] is Map) {
      final pMap = json['productId'] as Map;
      parsedImage = pMap['image']?.toString() ?? '';
      if (parsedImage.isEmpty && pMap['images'] is List && (pMap['images'] as List).isNotEmpty) {
        final firstImg = (pMap['images'] as List).first;
        if (firstImg is Map) {
          parsedImage = firstImg['photo']?.toString() ?? '';
        } else {
          parsedImage = firstImg.toString();
        }
      }
    }

    num parsedPrice = json['price'] ?? 0;
    if (parsedPrice == 0 && json['productId'] is Map) {
      parsedPrice = json['productId']['price'] ?? 0;
    }

    return CartItemModel(
      id: json['_id']?.toString() ?? '',
      productId: parsedProductId,
      name: parsedName,
      image: parsedImage,
      price: parsedPrice,
      quantity: json['quantity'] != null ? (int.tryParse(json['quantity'].toString()) ?? 1) : 1,
      stock: parsedStock,
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
