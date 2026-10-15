class SellerBannerModel {
  final String id;
  final String storeId;
  final String sellerId;
  final String name;
  final String email;
  final String phone;
  final String title;
  final String bannerImage;
  final String description;
  final String status; // 'pending', 'active', 'rejected', 'expired'
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const SellerBannerModel({
    required this.id,
    this.storeId = '',
    this.sellerId = '',
    this.name = '',
    this.email = '',
    this.phone = '',
    required this.title,
    this.bannerImage = '',
    this.description = '',
    this.status = 'pending',
    this.startDate,
    this.endDate,
    this.createdAt,
    this.updatedAt,
  });

  bool get isPending {
    final s = status.toLowerCase().trim();
    return s == 'pending' || s == 'under_review';
  }

  bool get isActive {
    final s = status.toLowerCase().trim();
    if (s == 'active' || s == 'approved') {
      if (endDate != null && DateTime.now().isAfter(endDate!)) {
        return false;
      }
      return true;
    }
    return false;
  }

  bool get isRejected {
    final s = status.toLowerCase().trim();
    return s == 'rejected' || s == 'declined';
  }

  bool get isExpired {
    final s = status.toLowerCase().trim();
    if (s == 'expired' || s == 'ended' || s == 'inactive') return true;
    if (endDate != null && DateTime.now().isAfter(endDate!)) return true;
    return false;
  }

  String get dateRangeFormatted {
    if (startDate == null && endDate == null) return 'N/A';
    String format(DateTime? dt) {
      if (dt == null) return '';
      final m = dt.month.toString().padLeft(2, '0');
      final d = dt.day.toString().padLeft(2, '0');
      final y = dt.year.toString();
      return '$m/$d/$y';
    }

    if (startDate != null && endDate != null) {
      return '${format(startDate)} — ${format(endDate)}';
    } else if (startDate != null) {
      return 'From ${format(startDate)}';
    }
    return 'Until ${format(endDate)}';
  }

  factory SellerBannerModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic val) {
      if (val == null) return null;
      return DateTime.tryParse(val.toString())?.toLocal();
    }

    final rawImage = json['Bannerimage'] ??
        json['BannerImage'] ??
        json['bannerImage'] ??
        json['bannerimage'] ??
        json['banner'] ??
        json['image'] ??
        json['imageUrl'] ??
        '';

    return SellerBannerModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      storeId: (json['storeId'] ?? '').toString(),
      sellerId: (json['sellerId'] ?? '').toString(),
      name: (json['Name'] ?? json['name'] ?? '').toString(),
      email: (json['Email'] ?? json['email'] ?? '').toString(),
      phone: (json['phone'] ?? json['Phone'] ?? '').toString(),
      title: (json['title'] ?? json['Title'] ?? 'Promotional Banner').toString(),
      bannerImage: rawImage.toString(),
      description: (json['description'] ?? json['Description'] ?? '').toString(),
      status: (json['status'] ?? json['Status'] ?? 'pending').toString(),
      startDate: parseDate(json['startDate'] ?? json['StartDate']),
      endDate: parseDate(json['endDate'] ?? json['EndDate']),
      createdAt: parseDate(json['createdAt']),
      updatedAt: parseDate(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'storeId': storeId,
    'sellerId': sellerId,
    'Name': name,
    'Email': email,
    'phone': phone,
    'title': title,
    'Bannerimage': bannerImage,
    'description': description,
    'status': status,
    'startDate': startDate?.toIso8601String(),
    'endDate': endDate?.toIso8601String(),
    'createdAt': createdAt?.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
  };
}
