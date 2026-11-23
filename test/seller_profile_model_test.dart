import 'package:flutter_test/flutter_test.dart';
import 'package:uhsu_buy/features/seller/data/models/seller_profile_model.dart';

void main() {
  group('SellerProfileModel Tests', () {
    test('parses from direct map structure', () {
      final json = {
        '_id': 'sel_123',
        'fullName': 'John Doe',
        'displayName': 'John Seller',
        'email': 'seller@example.com',
        'phoneNumber': '+923001234567',
        'role': 'seller',
        'status': 'Approved',
        'businessType': 'Individual',
        'city': 'Lahore',
        'cnic': '35201-1234567-1',
        'bankName': 'Meezan Bank',
        'accountHolder': 'John Doe',
        'ibanNumber': 'PK36MEZN0000001234567890',
        'store': {
          '_id': 'str_999',
          'StoreName': 'John Super Store',
          'logo': 'https://example.com/logo.png',
        },
      };

      final profile = SellerProfileModel.fromJson(json);

      expect(profile.id, 'sel_123');
      expect(profile.fullName, 'John Doe');
      expect(profile.email, 'seller@example.com');
      expect(profile.phoneNumber, '+923001234567');
      expect(profile.status, 'Approved');
      expect(profile.businessType, 'Individual');
      expect(profile.cnic, '35201-1234567-1');
      expect(profile.bankName, 'Meezan Bank');
      expect(profile.storeId, 'str_999');
      expect(profile.storeName, 'John Super Store');
      expect(profile.storeLogo, 'https://example.com/logo.png');
    });

    test('parses from nested {seller: {...}} structure', () {
      final json = {
        'success': true,
        'seller': {
          '_id': 'sel_456',
          'fullName': 'Jane Smith',
          'email': 'jane@example.com',
          'status': 'Approved',
        },
      };

      final profile = SellerProfileModel.fromJson(json);

      expect(profile.id, 'sel_456');
      expect(profile.fullName, 'Jane Smith');
      expect(profile.email, 'jane@example.com');
      expect(profile.status, 'Approved');
    });

    test('parses from nested {data: {seller: {...}}} structure', () {
      final json = {
        'data': {
          'seller': {
            'id': 'sel_789',
            'name': 'Ali Khan',
            'email': 'ali@example.com',
          },
        },
      };

      final profile = SellerProfileModel.fromJson(json);

      expect(profile.id, 'sel_789');
      expect(profile.fullName, 'Ali Khan');
      expect(profile.email, 'ali@example.com');
    });

    test('handles null and invalid structures safely', () {
      final p1 = SellerProfileModel.fromJson(null);
      expect(p1.id, '');
      expect(p1.fullName, '');

      final p2 = SellerProfileModel.fromJson('invalid_string');
      expect(p2.id, '');
      expect(p2.email, '');
    });
  });
}
