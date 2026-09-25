class OrderModel {
  final String id;
  final String orderGroupId;
  final String status;
  final String paymentStatus;
  final double totalAmount;
  final double subtotal;
  final double shippingFee;
  final double discount;
  final String createdAt;
  final List<OrderItemModel> items;
  final String paymentMethod;
  final String shippingAddress;
  final String buyerName;
  final String buyerPhone;

  OrderModel({
    required this.id,
    this.orderGroupId = '',
    required this.status,
    this.paymentStatus = 'unpaid',
    required this.totalAmount,
    this.subtotal = 0.0,
    this.shippingFee = 0.0,
    this.discount = 0.0,
    required this.createdAt,
    required this.items,
    this.paymentMethod = 'COD',
    this.shippingAddress = '',
    this.buyerName = '',
    this.buyerPhone = '',
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    var rawItems = json['items'] ?? json['orderItems'] ?? json['products'] ?? [];
    var itemsList = rawItems is List ? rawItems : [];

    // Check summary object
    Map<String, dynamic> summary = json['summary'] is Map ? Map<String, dynamic>.from(json['summary']) : {};

    num rawTotal = summary['total'] ??
        json['grandTotal'] ??
        json['totalAmount'] ??
        json['total'] ??
        json['amount'] ??
        json['orderAmount'] ??
        json['subtotal'] ??
        0;

    num rawSubtotal = summary['subtotal'] ?? json['subtotal'] ?? 0;
    num rawShipping = summary['shipping'] ?? json['shipping'] ?? json['shippingFee'] ?? 0;
    num rawDiscount = summary['discount'] ?? json['discount'] ?? 0;

    String addrStr = '';
    String phone = '';
    String name = '';

    var addrObj = json['address'] ?? json['shippingAddress'];
    if (addrObj != null) {
      if (addrObj is Map) {
        final a = Map<String, dynamic>.from(addrObj);
        name = a['fullName']?.toString() ?? a['name']?.toString() ?? '';
        phone = a['phone']?.toString() ?? a['phoneNumber']?.toString() ?? '';

        final parts = [
          a['addressLine1'] ?? a['addressline1'],
          a['addressLine2'] ?? a['addressline2'],
          a['city'],
          a['province'],
          a['country'],
          a['postalCode'] ?? a['postalcode']
        ].where((e) => e != null && e.toString().trim().isNotEmpty).join(', ');

        addrStr = parts;
      } else if (addrObj is String) {
        addrStr = addrObj.toString();
      }
    }

    String payMethod = json['paymentMethod']?.toString() ??
        json['payment_method']?.toString() ??
        json['paymentMode']?.toString() ??
        'COD';

    return OrderModel(
      id: json['_id']?.toString() ??
          json['id']?.toString() ??
          json['orderId']?.toString() ??
          json['orderGroupId']?.toString() ??
          json['number']?.toString() ??
          '',
      orderGroupId: json['orderGroupId']?.toString() ?? '',
      status: json['status']?.toString() ?? json['orderStatus']?.toString() ?? 'pending',
      paymentStatus: json['paymentStatus']?.toString() ?? 'unpaid',
      totalAmount: rawTotal.toDouble(),
      subtotal: rawSubtotal.toDouble(),
      shippingFee: rawShipping.toDouble(),
      discount: rawDiscount.toDouble(),
      createdAt: json['createdAt']?.toString() ?? json['date']?.toString() ?? json['created_at']?.toString() ?? '',
      paymentMethod: payMethod,
      shippingAddress: addrStr,
      buyerName: name,
      buyerPhone: phone,
      items: itemsList.map((e) {
        if (e is Map<String, dynamic>) {
          return OrderItemModel.fromJson(e);
        } else if (e is Map) {
          return OrderItemModel.fromJson(Map<String, dynamic>.from(e));
        }
        return OrderItemModel(
          id: '',
          productId: e.toString(),
          productName: 'Product',
          quantity: 1,
          price: 0.0,
          image: '',
        );
      }).toList(),
    );
  }
}

class OrderItemModel {
  final String id;
  final String productId;
  final String productName;
  final int quantity;
  final double price;
  final double total;
  final String image;

  OrderItemModel({
    required this.id,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
    this.total = 0.0,
    required this.image,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    var productData = json['productId'] ?? json['product'] ?? {};

    if (productData is String) {
      num itemPrice = json['price'] ?? json['unitPrice'] ?? 0;
      num itemTotal = json['total'] ?? (itemPrice * (json['quantity'] ?? 1));
      return OrderItemModel(
        id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
        productId: productData,
        productName: json['name']?.toString() ?? json['productName']?.toString() ?? json['title']?.toString() ?? 'Product',
        quantity: (json['quantity'] ?? json['qty'] ?? 1) is int
            ? (json['quantity'] ?? json['qty'] ?? 1)
            : int.tryParse((json['quantity'] ?? json['qty'] ?? 1).toString()) ?? 1,
        price: itemPrice.toDouble(),
        total: itemTotal.toDouble(),
        image: json['image']?.toString() ?? json['imageUrl']?.toString() ?? '',
      );
    }

    Map<String, dynamic> prodMap = productData is Map ? Map<String, dynamic>.from(productData) : {};

    String imageUrl = json['image']?.toString() ??
        json['imageUrl']?.toString() ??
        prodMap['image']?.toString() ??
        prodMap['imageUrl']?.toString() ??
        '';

    if (imageUrl.isEmpty && prodMap['images'] is List && (prodMap['images'] as List).isNotEmpty) {
      final imgItem = prodMap['images'][0];
      if (imgItem is String) {
        imageUrl = imgItem;
      } else if (imgItem is Map) {
        imageUrl = imgItem['url']?.toString() ?? imgItem['src']?.toString() ?? '';
      }
    }

    num itemPrice = json['price'] ?? prodMap['price'] ?? 0;
    num itemTotal = json['total'] ?? (itemPrice * (json['quantity'] ?? json['qty'] ?? 1));

    return OrderItemModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      productId: prodMap['_id']?.toString() ?? prodMap['id']?.toString() ?? '',
      productName: json['name']?.toString() ??
          json['productName']?.toString() ??
          prodMap['name']?.toString() ??
          prodMap['title']?.toString() ??
          'Product',
      quantity: (json['quantity'] ?? json['qty'] ?? 1) is int
          ? (json['quantity'] ?? json['qty'] ?? 1)
          : int.tryParse((json['quantity'] ?? json['qty'] ?? 1).toString()) ?? 1,
      price: itemPrice.toDouble(),
      total: itemTotal.toDouble(),
      image: imageUrl,
    );
  }
}
