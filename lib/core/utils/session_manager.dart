import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../network/api_client.dart';
import '../network/api_endpoints.dart';

class SessionManager {
  static const _storage = FlutterSecureStorage();

  // In-memory cache for synchronous access (Buyer)
  static bool _isLoggedIn = false;
  static String? _userId;
  static String? _email;
  static String? _fullName;
  static String? _token;

  // In-memory cache for Seller session (isolated from buyer)
  static bool _isSellerLoggedIn = false;
  static String? _sellerId;
  static String? _sellerToken;
  static String? _sellerEmail;
  static String? _sellerName;
  static String? _sellerStatus;

  static final Set<String> _reviewedKeys = {};
  static final Set<String> _returnedOrders = {};

  static String get _addrPrefix => (_userId != null && _userId!.isNotEmpty) ? '${_userId}_' : '';

  static Future<void> init() async {
    final loggedInStr = await _storage.read(key: 'isLoggedIn');
    _isLoggedIn = loggedInStr == 'true';
    _userId = await _storage.read(key: 'userId');
    _email = await _storage.read(key: 'email');
    _fullName = await _storage.read(key: 'fullName');
    _token = await _storage.read(key: 'token');

    final sellerLoggedInStr = await _storage.read(key: 'isSellerLoggedIn');
    _isSellerLoggedIn = sellerLoggedInStr == 'true';
    _sellerId = await _storage.read(key: 'sellerId');
    _sellerToken = await _storage.read(key: 'sellerToken');
    _sellerEmail = await _storage.read(key: 'sellerEmail');
    _sellerName = await _storage.read(key: 'sellerName');
    _sellerStatus = await _storage.read(key: 'sellerStatus');

    await loadReviewedItems();
    await loadReturnedItems();

    // Load saved address from local storage on app startup
    await getSavedAddress();

    if (_isLoggedIn) {
      fetchUserAddressFromBackend();
    }
  }

  static Future<void> loadReturnedItems() async {
    final prefix = _addrPrefix;
    final str = await _storage.read(key: '${prefix}returned_orders') ?? await _storage.read(key: 'returned_orders') ?? '';
    if (str.isNotEmpty) {
      _returnedOrders.addAll(str.split(',').where((e) => e.trim().isNotEmpty));
    }
  }

  static bool isReturned(String orderId) {
    if (orderId.isEmpty) return false;
    return _returnedOrders.contains(orderId);
  }

  static Future<void> markReturned(String orderId) async {
    if (orderId.isEmpty) return;
    _returnedOrders.add(orderId);
    final prefix = _addrPrefix;
    await _storage.write(key: '${prefix}returned_orders', value: _returnedOrders.join(','));
  }

  static Future<void> loadReviewedItems() async {
    final prefix = _addrPrefix;
    final str = await _storage.read(key: '${prefix}reviewed_items') ?? await _storage.read(key: 'reviewed_items') ?? '';
    if (str.isNotEmpty) {
      _reviewedKeys.addAll(str.split(',').where((e) => e.trim().isNotEmpty));
    }
  }

  static bool isReviewed(String orderId, String productId) {
    if (orderId.isEmpty) return false;
    final key1 = '${orderId}_$productId';
    final key2 = orderId;
    return _reviewedKeys.contains(key1) || _reviewedKeys.contains(key2);
  }

  static Future<void> markReviewed(String orderId, String productId) async {
    if (orderId.isEmpty) return;
    final key1 = '${orderId}_$productId';
    final key2 = orderId;
    _reviewedKeys.add(key1);
    _reviewedKeys.add(key2);
    final prefix = _addrPrefix;
    await _storage.write(key: '${prefix}reviewed_items', value: _reviewedKeys.join(','));
  }

  static Future<void> saveSession(String userId, String email, String fullName, {String? token}) async {
    _isLoggedIn = true;
    _userId = userId;
    _email = email;
    _fullName = fullName;
    _savedAddress = null;
    _reviewedKeys.clear();
    _returnedOrders.clear();

    await _storage.write(key: 'isLoggedIn', value: 'true');
    await _storage.write(key: 'userId', value: userId);
    await _storage.write(key: 'email', value: email);
    await _storage.write(key: 'fullName', value: fullName);
    
    if (token != null && token.isNotEmpty) {
      _token = token;
      await _storage.write(key: 'token', value: token);
    }

    await loadReviewedItems();
    await loadReturnedItems();

    // Re-hydrate saved address for this specific logged-in user
    await getSavedAddress();
  }

  static Future<void> clearSession() async {
    _isLoggedIn = false;
    _userId = null;
    _email = null;
    _fullName = null;
    _token = null;
    _savedAddress = null;
    _reviewedKeys.clear();
    _returnedOrders.clear();

    await _storage.delete(key: 'isLoggedIn');
    await _storage.delete(key: 'userId');
    await _storage.delete(key: 'email');
    await _storage.delete(key: 'fullName');
    await _storage.delete(key: 'token');
  }

  static Map<String, String>? _savedAddress;

  static Future<void> saveAddressData({
    required String fullName,
    required String phone,
    required String addressLine,
    required String city,
    required String province,
    required String country,
    required String postalCode,
  }) async {
    _savedAddress = {
      'fullName': fullName,
      'phone': phone,
      'addressLine': addressLine,
      'city': city,
      'province': province,
      'country': country,
      'postalCode': postalCode,
    };
    final prefix = _addrPrefix;
    await _storage.write(key: '${prefix}fullName', value: fullName);
    await _storage.write(key: '${prefix}phone', value: phone);
    await _storage.write(key: '${prefix}addressLine', value: addressLine);
    await _storage.write(key: '${prefix}city', value: city);
    await _storage.write(key: '${prefix}province', value: province);
    await _storage.write(key: '${prefix}country', value: country);
    await _storage.write(key: '${prefix}postalCode', value: postalCode);
  }

  static Future<Map<String, String>?> getSavedAddress() async {
    if (_savedAddress != null && 
        ((_savedAddress!['addressLine']?.isNotEmpty ?? false) || (_savedAddress!['phone']?.isNotEmpty ?? false))) {
      return _savedAddress;
    }

    final prefix = _addrPrefix;
    final addressLine = await _storage.read(key: '${prefix}addressLine') ?? '';
    final phone = await _storage.read(key: '${prefix}phone') ?? '';
    final fullName = await _storage.read(key: '${prefix}fullName') ?? _fullName ?? '';
    final city = await _storage.read(key: '${prefix}city') ?? '';
    final province = await _storage.read(key: '${prefix}province') ?? '';
    final country = await _storage.read(key: '${prefix}country') ?? 'Pakistan';
    final postalCode = await _storage.read(key: '${prefix}postalCode') ?? '';

    if (addressLine.isNotEmpty || phone.isNotEmpty || city.isNotEmpty) {
      _savedAddress = {
        'fullName': fullName,
        'phone': phone,
        'addressLine': addressLine,
        'city': city,
        'province': province,
        'country': country,
        'postalCode': postalCode,
      };
      return _savedAddress;
    }
    return await fetchUserAddressFromBackend();
  }

  static Future<Map<String, String>?> fetchUserAddressFromBackend() async {
    if (!isLoggedIn) return _savedAddress;
    try {
      final apiClient = ApiClient();
      final response = await apiClient.dio.get(
        ApiEndpoints.getAddresses,
        options: Options(validateStatus: (status) => true),
      );

      final data = response.data;
      if (data != null && (data['success'] == true || response.statusCode == 200)) {
        final List addresses = data['addresses'] ?? data['address'] ?? data['data'] ?? (data is List ? data : []);
        if (addresses.isNotEmpty) {
          final defaultAddr = addresses.firstWhere((a) => a['isDefault'] == true, orElse: () => addresses.first);
          if (defaultAddr is Map) {
            final String name = defaultAddr['fullName']?.toString() ?? defaultAddr['name']?.toString() ?? _fullName ?? '';
            final String phone = defaultAddr['phone']?.toString() ?? defaultAddr['phoneNumber']?.toString() ?? '';
            final String addrLine = defaultAddr['addressLine']?.toString() ??
                defaultAddr['addressline1']?.toString() ??
                defaultAddr['address']?.toString() ??
                defaultAddr['street']?.toString() ??
                '';
            final String city = defaultAddr['city']?.toString() ?? '';
            final String province = defaultAddr['province']?.toString() ?? defaultAddr['state']?.toString() ?? '';
            final String country = defaultAddr['country']?.toString() ?? 'Pakistan';
            final String postalCode = defaultAddr['postalCode']?.toString() ?? defaultAddr['postalcode']?.toString() ?? defaultAddr['zipCode']?.toString() ?? '';

            if (addrLine.isNotEmpty) {
              await saveAddressData(
                fullName: name,
                phone: phone,
                addressLine: addrLine,
                city: city,
                province: province,
                country: country,
                postalCode: postalCode,
              );
              return _savedAddress;
            }
          }
        }
      }
    } catch (e) {
      // Fallback to local device storage
    }
    
    // Always fall back to locally saved device storage for this specific user prefix
    final prefix = _addrPrefix;
    final localAddrLine = await _storage.read(key: '${prefix}addressLine');
    if (localAddrLine != null && localAddrLine.isNotEmpty) {
      _savedAddress = {
        'fullName': await _storage.read(key: '${prefix}fullName') ?? _fullName ?? '',
        'phone': await _storage.read(key: '${prefix}phone') ?? '',
        'addressLine': localAddrLine,
        'city': await _storage.read(key: '${prefix}city') ?? '',
        'province': await _storage.read(key: '${prefix}province') ?? '',
        'country': await _storage.read(key: '${prefix}country') ?? 'Pakistan',
        'postalCode': await _storage.read(key: '${prefix}postalCode') ?? '',
      };
    } else {
      _savedAddress = null;
    }
    return _savedAddress;
  }

  static bool get isLoggedIn => _isLoggedIn;
  static String? get userId => _userId;
  static String? get email => _email;
  static String? get fullName => _fullName;
  static String? get token => _token;

  // Seller session methods & getters
  static bool get isSellerLoggedIn => _isSellerLoggedIn;
  static String? get sellerId => _sellerId;
  static String? get sellerToken => _sellerToken;
  static String? get sellerEmail => _sellerEmail;
  static String? get sellerName => _sellerName;
  static String? get sellerStatus => _sellerStatus;

  static Future<void> saveSellerSession({
    required String sellerId,
    String? token,
    String? email,
    String? name,
    String? status,
  }) async {
    _isSellerLoggedIn = true;
    _sellerId = sellerId;
    _sellerToken = token;
    _sellerEmail = email;
    _sellerName = name;
    _sellerStatus = status;

    await _storage.write(key: 'isSellerLoggedIn', value: 'true');
    await _storage.write(key: 'sellerId', value: sellerId);
    if (token != null) await _storage.write(key: 'sellerToken', value: token);
    if (email != null) await _storage.write(key: 'sellerEmail', value: email);
    if (name != null) await _storage.write(key: 'sellerName', value: name);
    if (status != null) await _storage.write(key: 'sellerStatus', value: status);
  }

  static Future<void> clearSellerSession() async {
    _isSellerLoggedIn = false;
    _sellerId = null;
    _sellerToken = null;
    _sellerEmail = null;
    _sellerName = null;
    _sellerStatus = null;

    await _storage.delete(key: 'isSellerLoggedIn');
    await _storage.delete(key: 'sellerId');
    await _storage.delete(key: 'sellerToken');
    await _storage.delete(key: 'sellerEmail');
    await _storage.delete(key: 'sellerName');
    await _storage.delete(key: 'sellerStatus');
  }
}
