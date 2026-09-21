class OrderModel {
  final String id;
  final String status;
  final double totalAmount;
  final String createdAt;
  final List<OrderItemModel> items;

  OrderModel({
    required this.id,
    required this.status,
    required this.totalAmount,
    required this.createdAt,
    required this.items,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    var itemsList = json['items'] as List? ?? [];
    return OrderModel(
      id: json['_id'] ?? json['id'] ?? '',
      status: json['status'] ?? 'Pending',
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      createdAt: json['createdAt'] ?? '',
      items: itemsList.map((e) => OrderItemModel.fromJson(e)).toList(),
    );
  }
}

class OrderItemModel {
  final String productId;
  final String productName;
  final int quantity;
  final double price;
  final String image;

  OrderItemModel({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
    required this.image,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    var productData = json['productId'] ?? {};
    
    // Sometimes backend might just return product ID as string
    if (productData is String) {
      return OrderItemModel(
        productId: productData,
        productName: 'Product',
        quantity: json['quantity'] ?? 1,
        price: (json['price'] ?? 0).toDouble(),
        image: '',
      );
    }
    
    // If it's populated
    return OrderItemModel(
      productId: productData['_id'] ?? '',
      productName: productData['name'] ?? 'Product',
      quantity: json['quantity'] ?? 1,
      price: (json['price'] ?? productData['price'] ?? 0).toDouble(),
      image: (productData['images'] != null && productData['images'].isNotEmpty) 
          ? productData['images'][0]['url'] ?? ''
          : '',
    );
  }
}
