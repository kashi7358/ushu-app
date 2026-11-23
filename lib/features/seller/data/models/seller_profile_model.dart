class SellerProfileModel {
  final String id;
  final String fullName;
  final String displayName;
  final String email;
  final String phoneNumber;
  final String role;
  final String status;
  final String businessType;
  final String city;
  final String province;
  final String businessAddress;
  final String cnic;
  final String bankName;
  final String accountHolder;
  final String ibanNumber;
  final String storeId;
  final String storeName;
  final String storeLogo;
  final String storeBanner;
  final Map<String, dynamic> rawData;

  const SellerProfileModel({
    this.id = '',
    this.fullName = '',
    this.displayName = '',
    this.email = '',
    this.phoneNumber = '',
    this.role = '',
    this.status = '',
    this.businessType = '',
    this.city = '',
    this.province = '',
    this.businessAddress = '',
    this.cnic = '',
    this.bankName = '',
    this.accountHolder = '',
    this.ibanNumber = '',
    this.storeId = '',
    this.storeName = '',
    this.storeLogo = '',
    this.storeBanner = '',
    this.rawData = const {},
  });

  factory SellerProfileModel.fromJson(dynamic json) {
    if (json == null) return const SellerProfileModel();

    Map<String, dynamic> map;
    if (json is Map<String, dynamic>) {
      map = json;
    } else if (json is Map) {
      map = Map<String, dynamic>.from(json);
    } else {
      return const SellerProfileModel();
    }

    // Unwrap if nested under 'seller', 'data', or 'user'
    Map<String, dynamic> sellerData = map;
    if (map['seller'] is Map) {
      sellerData = Map<String, dynamic>.from(map['seller'] as Map);
    } else if (map['data'] is Map) {
      final inner = Map<String, dynamic>.from(map['data'] as Map);
      if (inner['seller'] is Map) {
        sellerData = Map<String, dynamic>.from(inner['seller'] as Map);
      } else {
        sellerData = inner;
      }
    } else if (map['user'] is Map) {
      sellerData = Map<String, dynamic>.from(map['user'] as Map);
    }

    // Extract store sub-object if present
    String sId = '';
    String sName = '';
    String sLogo = '';
    String sBanner = '';

    final dynamic rawStore = sellerData['store'] ?? sellerData['Store'] ?? map['store'];
    if (rawStore is Map) {
      sId = rawStore['_id']?.toString() ?? rawStore['id']?.toString() ?? '';
      sName = rawStore['StoreName']?.toString() ?? rawStore['storeName']?.toString() ?? rawStore['name']?.toString() ?? '';
      sLogo = rawStore['logo']?.toString() ?? rawStore['logoUrl']?.toString() ?? '';
      sBanner = rawStore['StoreBanner']?.toString() ?? rawStore['storeBanner']?.toString() ?? rawStore['banner']?.toString() ?? '';
    } else if (rawStore is String) {
      sId = rawStore;
    }

    return SellerProfileModel(
      id: sellerData['_id']?.toString() ?? sellerData['id']?.toString() ?? '',
      fullName: sellerData['fullName']?.toString() ??
          sellerData['name']?.toString() ??
          sellerData['displayName']?.toString() ??
          '',
      displayName: sellerData['displayName']?.toString() ??
          sellerData['name']?.toString() ??
          sellerData['fullName']?.toString() ??
          '',
      email: sellerData['email']?.toString() ?? '',
      phoneNumber: sellerData['phoneNumber']?.toString() ??
          sellerData['phone']?.toString() ??
          sellerData['mobile']?.toString() ??
          '',
      role: sellerData['role']?.toString() ?? 'seller',
      status: sellerData['status']?.toString() ?? '',
      businessType: sellerData['businessType']?.toString() ?? '',
      city: sellerData['city']?.toString() ?? '',
      province: sellerData['province']?.toString() ?? '',
      businessAddress: sellerData['businessAddress']?.toString() ?? sellerData['address']?.toString() ?? '',
      cnic: sellerData['cnic']?.toString() ?? '',
      bankName: sellerData['bankName']?.toString() ?? '',
      accountHolder: sellerData['accountHolder']?.toString() ?? '',
      ibanNumber: sellerData['ibanNumber']?.toString() ?? '',
      storeId: sId.isNotEmpty ? sId : (sellerData['storeId']?.toString() ?? ''),
      storeName: sName.isNotEmpty ? sName : (sellerData['storeName']?.toString() ?? ''),
      storeLogo: sLogo.isNotEmpty ? sLogo : (sellerData['storeLogo']?.toString() ?? ''),
      storeBanner: sBanner.isNotEmpty ? sBanner : (sellerData['storeBanner']?.toString() ?? ''),
      rawData: sellerData,
    );
  }

  SellerProfileModel copyWith({
    String? id,
    String? fullName,
    String? displayName,
    String? email,
    String? phoneNumber,
    String? role,
    String? status,
    String? businessType,
    String? city,
    String? province,
    String? businessAddress,
    String? cnic,
    String? bankName,
    String? accountHolder,
    String? ibanNumber,
    String? storeId,
    String? storeName,
    String? storeLogo,
    String? storeBanner,
    Map<String, dynamic>? rawData,
  }) {
    return SellerProfileModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
      status: status ?? this.status,
      businessType: businessType ?? this.businessType,
      city: city ?? this.city,
      province: province ?? this.province,
      businessAddress: businessAddress ?? this.businessAddress,
      cnic: cnic ?? this.cnic,
      bankName: bankName ?? this.bankName,
      accountHolder: accountHolder ?? this.accountHolder,
      ibanNumber: ibanNumber ?? this.ibanNumber,
      storeId: storeId ?? this.storeId,
      storeName: storeName ?? this.storeName,
      storeLogo: storeLogo ?? this.storeLogo,
      storeBanner: storeBanner ?? this.storeBanner,
      rawData: rawData ?? this.rawData,
    );
  }
}
