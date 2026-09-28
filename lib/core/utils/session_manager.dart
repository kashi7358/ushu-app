import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../network/api_client.dart';
import '../network/api_endpoints.dart';

class SessionManager {
  static const _storage = FlutterSecureStorage();

  // In-memory cache for synchronous access
  static bool _isLoggedIn = false;
  static String? _userId;
  static String? _email;
  static String? _fullName;
  static String? _token;

  static Future<void> init() async {
    final loggedInStr = await _storage.read(key: 'isLoggedIn');
    _isLoggedIn = loggedInStr == 'true';
    _userId = await _storage.read(key: 'userId');
    _email = await _storage.read(key: 'email');
    _fullName = await _storage.read(key: 'fullName');
    _token = await _storage.read(key: 'token');

    // Load saved address from local storage on app startup
    await getSavedAddress();

    if (_isLoggedIn) {
      fetchUserAddressFromBackend();
    }
  }

  static Future<void> saveSession(String userId, String email, String fullName, {String? token}) async {
    _isLoggedIn = true;
    _userId = userId;
    _email = email;
    _fullName = fullName;

    await _storage.write(key: 'isLoggedIn', value: 'true');
    await _storage.write(key: 'userId', value: userId);
    await _storage.write(key: 'email', value: email);
    await _storage.write(key: 'fullName', value: fullName);
    
    if (token != null && token.isNotEmpty) {
      _token = token;
      await _storage.write(key: 'token', value: token);
    }

    // Preserve and re-hydrate saved address
    await getSavedAddress();
  }

  static Future<void> clearSession() async {
    _isLoggedIn = false;
    _userId = null;
    _email = null;
    _fullName = null;
    _token = null;

    await _storage.delete(key: 'isLoggedIn');
    await _storage.delete(key: 'userId');
    await _storage.delete(key: 'email');
    await _storage.delete(key: 'fullName');
    await _storage.delete(key: 'token');
    // Note: Retain saved address in FlutterSecureStorage so user data persists permanently
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
    await _storage.write(key: 'fullName', value: fullName);
    await _storage.write(key: 'phone', value: phone);
    await _storage.write(key: 'addressLine', value: addressLine);
    await _storage.write(key: 'city', value: city);
    await _storage.write(key: 'province', value: province);
    await _storage.write(key: 'country', value: country);
    await _storage.write(key: 'postalCode', value: postalCode);
  }

  static Future<Map<String, String>?> getSavedAddress() async {
    if (_savedAddress != null && 
        ((_savedAddress!['addressLine']?.isNotEmpty ?? false) || (_savedAddress!['phone']?.isNotEmpty ?? false))) {
      return _savedAddress;
    }

    final addressLine = await _storage.read(key: 'addressLine') ?? '';
    final phone = await _storage.read(key: 'phone') ?? '';
    final fullName = await _storage.read(key: 'fullName') ?? _fullName ?? '';
    final city = await _storage.read(key: 'city') ?? '';
    final province = await _storage.read(key: 'province') ?? '';
    final country = await _storage.read(key: 'country') ?? 'Pakistan';
    final postalCode = await _storage.read(key: 'postalCode') ?? '';

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
        final List addresses = data['addresses'] ?? data['data'] ?? (data is List ? data : []);
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
    
    // Always fall back to locally saved device storage if remote backend returned empty or errored
    final localAddrLine = await _storage.read(key: 'addressLine');
    if (localAddrLine != null && localAddrLine.isNotEmpty) {
      _savedAddress = {
        'fullName': await _storage.read(key: 'fullName') ?? _fullName ?? '',
        'phone': await _storage.read(key: 'phone') ?? '',
        'addressLine': localAddrLine,
        'city': await _storage.read(key: 'city') ?? '',
        'province': await _storage.read(key: 'province') ?? '',
        'country': await _storage.read(key: 'country') ?? 'Pakistan',
        'postalCode': await _storage.read(key: 'postalCode') ?? '',
      };
    }
    return _savedAddress;
  }

  static bool get isLoggedIn => _isLoggedIn;
  static String? get userId => _userId;
  static String? get email => _email;
  static String? get fullName => _fullName;
  static String? get token => _token;
}
