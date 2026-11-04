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
    int? parsedStock;
    void extractStockFromMap(Map map) {
      if (parsedStock != null) return;
      dynamic raw = map['stock'] ??
          map['stockQuantity'] ??
          map['Stock'] ??
          map['countInStock'] ??
          map['count_in_stock'] ??
          map['availableStock'] ??
          map['totalStock'] ??
          map['quantity'] ??
          map['qty'];
      if (raw == null && map['inventory'] != null) {
        if (map['inventory'] is Map) {
          raw = map['inventory']['stock'] ??
              map['inventory']['quantity'] ??
              map['inventory']['countInStock'] ??
              map['inventory']['availableStock'];
        } else {
          raw = map['inventory'];
        }
      }
      if (raw != null) {
        parsedStock = int.tryParse(raw.toString());
      }
    }

    if (json['productId'] is Map) extractStockFromMap(json['productId'] as Map);
    if (parsedStock == null && json['product'] is Map) extractStockFromMap(json['product'] as Map);
    if (parsedStock == null) extractStockFromMap(json);
    final int? stockVal = parsedStock;
    final int finalStock = (stockVal != null && stockVal > 0) ? stockVal : 0;

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

    num parsedPrice = 0;
    if (json['price'] != null) {
      parsedPrice = num.tryParse(json['price'].toString()) ?? 0;
    }
    if (parsedPrice == 0 && json['productId'] is Map) {
      parsedPrice = num.tryParse(json['productId']['price']?.toString() ?? '') ?? 0;
    }

    return CartItemModel(
      id: json['_id']?.toString() ?? '',
      productId: parsedProductId,
      name: parsedName,
      image: parsedImage,
      price: parsedPrice,
      quantity: json['quantity'] != null ? (int.tryParse(json['quantity'].toString()) ?? 1) : 1,
      stock: finalStock,
      isSelected: json['isSelected'] == true,
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
