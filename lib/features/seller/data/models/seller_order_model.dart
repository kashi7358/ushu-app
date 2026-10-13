class SellerOrderModel {
  final String id;
  final String orderGroupId;
  final String status;
  final String paymentStatus;
  final String paymentMethod;
  final double totalAmount;
  final double subtotal;
  final double shippingFee;
  final double discount;
  final String createdAt;
  final String buyerName;
  final String buyerEmail;
  final String buyerPhone;
  final String shippingAddress;
  final String city;
  final List<SellerOrderItemModel> items;

  const SellerOrderModel({
    required this.id,
    this.orderGroupId = '',
    required this.status,
    this.paymentStatus = 'unpaid',
    this.paymentMethod = 'COD',
    required this.totalAmount,
    this.subtotal = 0.0,
    this.shippingFee = 0.0,
    this.discount = 0.0,
    required this.createdAt,
    this.buyerName = '',
    this.buyerEmail = '',
    this.buyerPhone = '',
    this.shippingAddress = '',
    this.city = '',
    required this.items,
  });

  String get normalizedStatus =>
      status.toLowerCase().replaceAll('_', ' ').replaceAll('-', ' ').trim();

  bool get isPending =>
      normalizedStatus == 'pending' ||
      normalizedStatus == 'placed' ||
      normalizedStatus == 'new' ||
      normalizedStatus == 'unconfirmed';

  bool get isProcessing =>
      normalizedStatus == 'processing' ||
      normalizedStatus == 'confirmed' ||
      normalizedStatus == 'picked' ||
      normalizedStatus == 'picking' ||
      normalizedStatus == 'packed' ||
      normalizedStatus == 'shipping' ||
      normalizedStatus == 'shipped' ||
      normalizedStatus == 'in transit' ||
      normalizedStatus == 'out for delivery' ||
      normalizedStatus == 'active';

  bool get isCompleted =>
      normalizedStatus == 'delivered' || normalizedStatus == 'completed';

  bool get isCancelled =>
      normalizedStatus == 'cancelled' ||
      normalizedStatus == 'canceled' ||
      normalizedStatus == 'returned' ||
      normalizedStatus == 'refunded';

  String get displayOrderId {
    final raw = orderGroupId.isNotEmpty ? orderGroupId : id;
    if (raw.isEmpty) return '#ORD-N/A';
    if (raw.startsWith('#')) return raw;
    if (raw.length > 8) {
      return '#${raw.substring(raw.length - 8).toUpperCase()}';
    }
    return '#${raw.toUpperCase()}';
  }

  factory SellerOrderModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] ??
        json['orderItems'] ??
        json['products'] ??
        json['sellerItems'] ??
        [];
    final itemsList = rawItems is List ? rawItems : [];

    final List<SellerOrderItemModel> parsedItems = itemsList.map((e) {
      if (e is Map<String, dynamic>) {
        return SellerOrderItemModel.fromJson(e);
      } else if (e is Map) {
        return SellerOrderItemModel.fromJson(Map<String, dynamic>.from(e));
      }
      return SellerOrderItemModel(
        id: '',
        productId: e.toString(),
        productName: 'Product',
        quantity: 1,
        price: 0,
        total: 0,
        image: '',
      );
    }).toList();

    final summary = json['summary'] is Map
        ? Map<String, dynamic>.from(json['summary'])
        : <String, dynamic>{};

    double parseDouble(dynamic val) {
      if (val == null) return 0.0;
      if (val is num) return val.toDouble();
      return double.tryParse(val.toString()) ?? 0.0;
    }

    double calcItemsSum = 0.0;
    for (final it in parsedItems) {
      calcItemsSum += it.total > 0 ? it.total : (it.price * it.quantity);
    }

    final double rawSub = parseDouble(
      summary['subtotal'] ?? json['subtotal'] ?? json['subTotal'] ?? calcItemsSum,
    );
    final double rawShip = parseDouble(
      summary['shipping'] ?? json['shipping'] ?? json['shippingFee'] ?? json['deliveryCharges'] ?? 0,
    );
    final double rawDisc = parseDouble(
      summary['discount'] ?? json['discount'] ?? 0,
    );
    double rawTot = parseDouble(
      summary['total'] ??
          json['grandTotal'] ??
          json['totalAmount'] ??
          json['sellerTotal'] ??
          json['subOrderTotal'] ??
          json['total'] ??
          json['amount'] ??
          json['orderAmount'],
    );
    if (rawTot <= 0 && calcItemsSum > 0) {
      rawTot = calcItemsSum + rawShip - rawDisc;
    }

    // Buyer & Shipping extraction
    String bName = '';
    String bEmail = '';
    String bPhone = '';
    String addrStr = '';
    String cityStr = '';

    final buyerObj = json['buyer'] ?? json['user'] ?? json['customer'] ?? json['buyerId'];
    if (buyerObj is Map) {
      final b = Map<String, dynamic>.from(buyerObj);
      bName = b['fullName']?.toString() ??
          b['name']?.toString() ??
          b['userName']?.toString() ??
          b['firstName']?.toString() ??
          '';
      bEmail = b['email']?.toString() ?? b['Email']?.toString() ?? '';
      bPhone = b['phone']?.toString() ??
          b['phoneNumber']?.toString() ??
          b['mobile']?.toString() ??
          '';
    }

    final addrObj = json['address'] ?? json['shippingAddress'] ?? json['deliveryAddress'];
    if (addrObj is Map) {
      final a = Map<String, dynamic>.from(addrObj);
      if (bName.isEmpty) {
        bName = a['fullName']?.toString() ?? a['name']?.toString() ?? a['recipientName']?.toString() ?? '';
      }
      if (bPhone.isEmpty) {
        bPhone = a['phone']?.toString() ?? a['phoneNumber']?.toString() ?? '';
      }
      cityStr = a['city']?.toString() ?? '';

      final parts = [
        a['addressLine1'] ?? a['addressline1'] ?? a['street'] ?? a['address'],
        a['addressLine2'] ?? a['addressline2'] ?? a['area'],
        a['city'],
        a['province'] ?? a['state'],
        a['postalCode'] ?? a['postalcode'],
      ].where((e) => e != null && e.toString().trim().isNotEmpty).join(', ');

      addrStr = parts;
    } else if (addrObj is String) {
      addrStr = addrObj.trim();
    }

    if (bName.isEmpty) {
      bName = json['buyerName']?.toString() ?? json['customerName']?.toString() ?? 'Customer';
    }
    if (bPhone.isEmpty) {
      bPhone = json['buyerPhone']?.toString() ?? json['phone']?.toString() ?? '';
    }

    final ordStatus = (json['status'] ??
            json['orderStatus'] ??
            json['subOrderStatus'] ??
            json['deliveryStatus'] ??
            json['fulfillmentStatus'] ??
            'Pending')
        .toString()
        .trim();

    final ordId = (json['_id'] ??
            json['id'] ??
            json['subOrderId'] ??
            json['orderId'] ??
            json['orderGroupId'] ??
            '')
        .toString();

    return SellerOrderModel(
      id: ordId,
      orderGroupId: (json['orderGroupId'] ?? json['orderNumber'] ?? '').toString(),
      status: ordStatus.isEmpty ? 'Pending' : ordStatus,
      paymentStatus: (json['paymentStatus'] ?? json['payment_status'] ?? 'unpaid').toString(),
      paymentMethod: (json['paymentMethod'] ?? json['payment_method'] ?? json['paymentMode'] ?? 'COD').toString(),
      totalAmount: rawTot,
      subtotal: rawSub,
      shippingFee: rawShip,
      discount: rawDisc,
      createdAt: (json['createdAt'] ?? json['date'] ?? json['created_at'] ?? '').toString(),
      buyerName: bName,
      buyerEmail: bEmail,
      buyerPhone: bPhone,
      shippingAddress: addrStr,
      city: cityStr,
      items: parsedItems,
    );
  }
}

class SellerOrderItemModel {
  final String id;
  final String productId;
  final String productName;
  final String sku;
  final String variantLabel;
  final int quantity;
  final double price;
  final double total;
  final String image;

  const SellerOrderItemModel({
    required this.id,
    required this.productId,
    required this.productName,
    this.sku = '',
    this.variantLabel = '',
    required this.quantity,
    required this.price,
    required this.total,
    required this.image,
  });

  factory SellerOrderItemModel.fromJson(Map<String, dynamic> json) {
    final prodData = json['productId'] ?? json['product'] ?? {};

    double parseDouble(dynamic val) {
      if (val == null) return 0.0;
      if (val is num) return val.toDouble();
      return double.tryParse(val.toString()) ?? 0.0;
    }

    int parseInt(dynamic val, [int fallback = 1]) {
      if (val == null) return fallback;
      if (val is int) return val;
      if (val is num) return val.toInt();
      return int.tryParse(val.toString()) ?? fallback;
    }

    // Extract variant (color/size) if present
    String variantStr = '';
    final vObj = json['variant'] ?? json['selectedVariant'];
    if (vObj is Map) {
      final c = vObj['color']?.toString() ?? '';
      final s = vObj['size']?.toString() ?? '';
      variantStr = [c, s].where((e) => e.trim().isNotEmpty).join(' / ');
    } else {
      final c = json['color']?.toString() ?? '';
      final s = json['size']?.toString() ?? '';
      variantStr = [c, s].where((e) => e.trim().isNotEmpty).join(' / ');
    }

    if (prodData is Map) {
      final prodMap = Map<String, dynamic>.from(prodData);

      String imgUrl = (json['image'] ??
              json['imageUrl'] ??
              prodMap['image'] ??
              prodMap['imageUrl'] ??
              prodMap['thumbnail'] ??
              '')
          .toString();

      if (imgUrl.isEmpty && prodMap['images'] is List && (prodMap['images'] as List).isNotEmpty) {
        final firstImg = (prodMap['images'] as List).first;
        if (firstImg is String) {
          imgUrl = firstImg;
        } else if (firstImg is Map) {
          imgUrl = (firstImg['url'] ?? firstImg['src'] ?? '').toString();
        }
      }

      final qty = parseInt(json['quantity'] ?? json['qty'], 1);
      final unitPrice = parseDouble(
        json['price'] ?? json['unitPrice'] ?? json['salePrice'] ?? prodMap['price'],
      );
      final lineTotal = parseDouble(json['total'] ?? json['subtotal']) > 0
          ? parseDouble(json['total'] ?? json['subtotal'])
          : unitPrice * qty;

      return SellerOrderItemModel(
        id: (json['_id'] ?? json['id'] ?? '').toString(),
        productId: (prodMap['_id'] ?? prodMap['id'] ?? '').toString(),
        productName: (json['name'] ??
                json['productName'] ??
                prodMap['name'] ??
                prodMap['title'] ??
                'Product')
            .toString(),
        sku: (json['sku'] ?? prodMap['sku'] ?? '').toString(),
        variantLabel: variantStr,
        quantity: qty,
        price: unitPrice,
        total: lineTotal,
        image: imgUrl,
      );
    }

    final qty = parseInt(json['quantity'] ?? json['qty'], 1);
    final unitPrice = parseDouble(json['price'] ?? json['unitPrice'] ?? json['salePrice']);
    final lineTotal = parseDouble(json['total'] ?? json['subtotal']) > 0
        ? parseDouble(json['total'] ?? json['subtotal'])
        : unitPrice * qty;

    return SellerOrderItemModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      productId: prodData.toString(),
      productName: (json['name'] ?? json['productName'] ?? json['title'] ?? 'Product').toString(),
      sku: (json['sku'] ?? '').toString(),
      variantLabel: variantStr,
      quantity: qty,
      price: unitPrice,
      total: lineTotal,
      image: (json['image'] ?? json['imageUrl'] ?? '').toString(),
    );
  }
}
