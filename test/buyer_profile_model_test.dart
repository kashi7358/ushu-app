import 'package:flutter_test/flutter_test.dart';
import 'package:uhsu_buy/core/network/api_endpoints.dart';
import 'package:uhsu_buy/features/profile/data/models/buyer_profile_model.dart';

void main() {
  group('BuyerProfileModel Parsing & Helpers', () {
    test('parses nested buyer wrapper with PascalCase and camelCase fields', () {
      final json = {
        'success': true,
        'buyer': {
          '_id': 'b1',
          'FullName': 'Zaheer Iqbal',
          'Email': 'zaheer@ushu.pk',
          'Phone': '03001234567',
          'address': 'Lahore, Punjab',
          'Role': 'Buyer',
          'isVerified': true,
          'createdAt': '2026-11-01T10:00:00.000Z',
        },
      };

      final model = BuyerProfileModel.fromJson(json);

      expect(model.id, 'b1');
      expect(model.fullName, 'Zaheer Iqbal');
      expect(model.email, 'zaheer@ushu.pk');
      expect(model.phone, '03001234567');
      expect(model.address, 'Lahore, Punjab');
      expect(model.role, 'Buyer');
      expect(model.isVerified, true);
      expect(model.createdAt, '2026-11-01T10:00:00.000Z');
      expect(model.formattedMemberSince, 'Nov 2026');
    });

    test('parses double-nested data.profile and single-nested data wrappers', () {
      final doubleNested = {
        'success': true,
        'data': {
          'profile': {
            'id': 'b2',
            'fullName': 'Ayesha Khan',
            'email': 'ayesha@ushu.pk',
            'phoneNumber': '03119876543',
            'role': 'Buyer',
            'isEmailVerified': 'true',
          },
        },
      };

      final model1 = BuyerProfileModel.fromJson(doubleNested);
      expect(model1.id, 'b2');
      expect(model1.fullName, 'Ayesha Khan');
      expect(model1.email, 'ayesha@ushu.pk');
      expect(model1.phone, '03119876543');
      expect(model1.isVerified, true);

      final singleNested = {
        'success': true,
        'data': {
          '_id': 'b3',
          'name': 'Bilal Ahmed',
          'email': 'bilal@ushu.pk',
        },
      };

      final model2 = BuyerProfileModel.fromJson(singleNested);
      expect(model2.id, 'b3');
      expect(model2.fullName, 'Bilal Ahmed');
      expect(model2.email, 'bilal@ushu.pk');
    });

    test('handles untyped Map<dynamic, dynamic> without TypeError', () {
      final Map<dynamic, dynamic> rawDynamic = <dynamic, dynamic>{
        'success': true,
        'buyer': <dynamic, dynamic>{
          '_id': 'b4',
          'FullName': 'Sara Tariq',
          'Email': 'sara@ushu.pk',
          'address': <dynamic, dynamic>{
            'addressLine': 'House 14, Block C',
            'city': 'Karachi',
            'province': 'Sindh',
          },
          'avatar': <dynamic, dynamic>{
            'secure_url': 'https://res.cloudinary.com/demo/sara.jpg',
          },
        },
      };

      final model = BuyerProfileModel.fromJson(rawDynamic);

      expect(model.id, 'b4');
      expect(model.fullName, 'Sara Tariq');
      expect(model.email, 'sara@ushu.pk');
      expect(model.address, 'House 14, Block C, Karachi, Sindh');
      expect(model.avatar, 'https://res.cloudinary.com/demo/sara.jpg');
      expect(model.hasAvatar, true);
    });

    test('extracts avatar from Cloudinary map and prefixes relative paths', () {
      final cloudinaryJson = {
        'buyer': {
          'FullName': 'Ali Raza',
          'avatar': {'secure_url': 'https://res.cloudinary.com/demo/avatar.jpg'},
        },
      };
      final cloudinaryModel = BuyerProfileModel.fromJson(cloudinaryJson);
      expect(cloudinaryModel.avatar, 'https://res.cloudinary.com/demo/avatar.jpg');
      expect(cloudinaryModel.hasAvatar, true);

      final relativeJson = {
        'buyer': {
          'FullName': 'Ali Raza',
          'profileImage': '/uploads/avatar.png',
        },
      };
      final relativeModel = BuyerProfileModel.fromJson(relativeJson);
      expect(relativeModel.avatar, '${ApiEndpoints.domain}/uploads/avatar.png');
      expect(relativeModel.hasAvatar, true);
    });

    test('extracts address from nested Map and addresses List with isDefault', () {
      final nestedAddrMapJson = {
        'buyer': {
          'FullName': 'Usman',
          'address': {
            'street': 'Street 9',
            'city': 'Islamabad',
            'state': 'ICT',
            'country': 'Pakistan',
          },
        },
      };
      expect(
        BuyerProfileModel.fromJson(nestedAddrMapJson).address,
        'Street 9, Islamabad, ICT, Pakistan',
      );

      final addressesListJson = {
        'buyer': {
          'FullName': 'Usman',
          'addresses': [
            {
              'addressLine': 'Old Street 1',
              'city': 'Multan',
              'isDefault': false,
            },
            {
              'addressLine': 'Main Boulevard 22',
              'city': 'Lahore',
              'province': 'Punjab',
              'isDefault': true,
            },
          ],
        },
      };
      expect(
        BuyerProfileModel.fromJson(addressesListJson).address,
        'Main Boulevard 22, Lahore, Punjab',
      );
    });

    test('computes displayName, firstName, initials, and formattedMemberSince edge cases', () {
      final multiWord = const BuyerProfileModel(
        fullName: 'Zaheer Iqbal',
        email: 'zaheer@ushu.pk',
        createdAt: '2026-11-15T12:00:00.000Z',
      );
      expect(multiWord.displayName, 'Zaheer Iqbal');
      expect(multiWord.firstName, 'Zaheer');
      expect(multiWord.initials, 'ZI');
      expect(multiWord.formattedMemberSince, 'Nov 2026');

      final singleWord = const BuyerProfileModel(
        fullName: 'Hamza',
        email: 'hamza@ushu.pk',
      );
      expect(singleWord.displayName, 'Hamza');
      expect(singleWord.firstName, 'Hamza');
      expect(singleWord.initials, 'H');

      final emailOnly = const BuyerProfileModel(
        email: 'kashif.ali@ushu.pk',
      );
      expect(emailOnly.displayName, 'kashif.ali');
      expect(emailOnly.firstName, 'kashif.ali');
      expect(emailOnly.initials, 'K');

      final emptyModel = BuyerProfileModel.fromJson({});
      expect(emptyModel.displayName, 'USHU Member');
      expect(emptyModel.firstName, 'USHU');
      expect(emptyModel.initials, 'UM');
      expect(emptyModel.hasAvatar, false);
      expect(emptyModel.formattedMemberSince, '');
    });
  });
}
