import '../../../../core/network/api_endpoints.dart';

class BuyerProfileModel {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String address;
  final String role;
  final String avatar;
  final bool isVerified;
  final String createdAt;

  const BuyerProfileModel({
    this.id = '',
    this.fullName = '',
    this.email = '',
    this.phone = '',
    this.address = '',
    this.role = 'Buyer',
    this.avatar = '',
    this.isVerified = false,
    this.createdAt = '',
  });

  factory BuyerProfileModel.fromJson(dynamic raw) {
    if (raw is! Map) {
      return const BuyerProfileModel();
    }

    final rootMap = Map<String, dynamic>.from(raw);
    final profileMap = _unwrapProfileMap(rootMap);

    final id = _pickString(profileMap, rootMap, ['_id', 'id', 'buyerId', 'userId']);
    final fullName = _pickString(
      profileMap,
      rootMap,
      ['FullName', 'fullName', 'full_name', 'name', 'Name', 'username'],
    );
    final email = _pickString(profileMap, rootMap, ['Email', 'email']);
    final phone = _pickString(
      profileMap,
      rootMap,
      ['Phone', 'phone', 'phoneNumber', 'phone_number', 'mobile', 'Mobile'],
    );
    final roleRaw = _pickString(profileMap, rootMap, ['Role', 'role']);
    final role = roleRaw.isNotEmpty ? roleRaw : 'Buyer';

    String address = _extractAddress(profileMap);
    if (address.isEmpty && !identical(profileMap, rootMap)) {
      address = _extractAddress(rootMap);
    }

    String avatar = _extractAvatar(profileMap);
    if (avatar.isEmpty && !identical(profileMap, rootMap)) {
      avatar = _extractAvatar(rootMap);
    }

    final isVerified = _extractVerified(profileMap, rootMap);
    final createdAt = _pickString(
      profileMap,
      rootMap,
      ['createdAt', 'created_at', 'joinedAt'],
    );

    return BuyerProfileModel(
      id: id,
      fullName: fullName,
      email: email,
      phone: phone,
      address: address,
      role: role,
      avatar: avatar,
      isVerified: isVerified,
      createdAt: createdAt,
    );
  }

  static Map<String, dynamic> _unwrapProfileMap(Map<String, dynamic> root) {
    Map<String, dynamic> current = root;
    const wrapperKeys = ['buyer', 'profile', 'user', 'data'];

    for (int depth = 0; depth < 2; depth++) {
      bool unwrapped = false;
      for (final key in wrapperKeys) {
        final nested = current[key];
        if (nested is Map) {
          current = Map<String, dynamic>.from(nested);
          unwrapped = true;
          break;
        }
      }
      if (!unwrapped) break;
    }

    return current;
  }

  static String _cleanString(dynamic v) {
    if (v == null) return '';
    final s = v.toString().trim();
    if (s.isEmpty || s.toLowerCase() == 'null' || s.toLowerCase() == 'undefined') {
      return '';
    }
    return s;
  }

  static String _pickString(
    Map<String, dynamic> primary,
    Map<String, dynamic> fallback,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = _cleanString(primary[key]);
      if (value.isNotEmpty) return value;
    }
    if (!identical(primary, fallback)) {
      for (final key in keys) {
        final value = _cleanString(fallback[key]);
        if (value.isNotEmpty) return value;
      }
    }
    return '';
  }

  static String _extractAddress(Map<String, dynamic> map) {
    final dynamic rawAddress = map['address'] ?? map['Address'];

    if (rawAddress is String) {
      final cleaned = _cleanString(rawAddress);
      if (cleaned.isNotEmpty) return cleaned;
    } else if (rawAddress is Map) {
      final formatted = _formatAddressMap(Map<String, dynamic>.from(rawAddress));
      if (formatted.isNotEmpty) return formatted;
    }

    final dynamic rawAddresses = map['addresses'];
    if (rawAddresses is List && rawAddresses.isNotEmpty) {
      dynamic selected;
      for (final item in rawAddresses) {
        if (item is Map &&
            (item['isDefault'] == true ||
                item['isDefault']?.toString().toLowerCase() == 'true')) {
          selected = item;
          break;
        }
      }
      selected ??= rawAddresses.first;

      if (selected is Map) {
        final formatted = _formatAddressMap(Map<String, dynamic>.from(selected));
        if (formatted.isNotEmpty) return formatted;
      } else if (selected is String) {
        final cleaned = _cleanString(selected);
        if (cleaned.isNotEmpty) return cleaned;
      }
    }

    final city = _cleanString(map['city'] ?? map['City']);
    final province = _cleanString(map['province'] ?? map['Province']);
    final parts = [city, province].where((p) => p.isNotEmpty).toList();
    return parts.join(', ');
  }

  static String _formatAddressMap(Map<String, dynamic> addr) {
    final line = _pickString(
      addr,
      addr,
      ['addressLine', 'addressline1', 'addressLine1', 'street', 'address'],
    );
    final city = _pickString(addr, addr, ['city', 'City']);
    final region = _pickString(addr, addr, ['province', 'Province', 'state', 'State']);
    final country = _pickString(addr, addr, ['country', 'Country']);

    final parts = <String>[];
    for (final part in [line, city, region, country]) {
      if (part.isNotEmpty && !parts.contains(part)) {
        parts.add(part);
      }
    }
    return parts.join(', ');
  }

  static String _extractAvatar(Map<String, dynamic> map) {
    const avatarKeys = [
      'avatar',
      'Avatar',
      'profileImage',
      'profilePic',
      'profile_image',
      'profilePhoto',
      'image',
      'photo',
      'picture',
    ];

    for (final key in avatarKeys) {
      final val = map[key];
      String url = '';
      if (val is Map) {
        final nested = Map<String, dynamic>.from(val);
        url = _pickString(nested, nested, ['secure_url', 'url', 'path', 'imageUrl']);
      } else {
        url = _cleanString(val);
      }

      if (url.isNotEmpty) {
        if (url.startsWith('/')) {
          return '${ApiEndpoints.domain}$url';
        }
        return url;
      }
    }

    return '';
  }

  static bool _extractVerified(
    Map<String, dynamic> primary,
    Map<String, dynamic> fallback,
  ) {
    const keys = ['isVerified', 'isEmailVerified', 'verified', 'emailVerified'];
    for (final key in keys) {
      if (primary.containsKey(key) && primary[key] != null) {
        final v = primary[key];
        return v == true || v.toString().trim().toLowerCase() == 'true';
      }
    }
    if (!identical(primary, fallback)) {
      for (final key in keys) {
        if (fallback.containsKey(key) && fallback[key] != null) {
          final v = fallback[key];
          return v == true || v.toString().trim().toLowerCase() == 'true';
        }
      }
    }
    return false;
  }

  String get displayName {
    if (fullName.isNotEmpty) return fullName;
    if (email.contains('@')) {
      final prefix = email.split('@').first.trim();
      if (prefix.isNotEmpty) return prefix;
    }
    return 'USHU Member';
  }

  String get firstName {
    final parts = displayName
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    return parts.isNotEmpty ? parts.first : 'Member';
  }

  String get initials {
    final parts = displayName
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    if (parts.length == 1 && parts[0].isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return 'U';
  }

  bool get hasAvatar =>
      avatar.isNotEmpty &&
      (avatar.startsWith('http://') || avatar.startsWith('https://'));

  String get formattedMemberSince {
    if (createdAt.isEmpty) return '';
    final dt = DateTime.tryParse(createdAt)?.toLocal();
    if (dt == null) return '';
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[dt.month - 1]} ${dt.year}';
  }
}
