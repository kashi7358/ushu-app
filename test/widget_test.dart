import 'package:flutter_test/flutter_test.dart';
import 'package:uhsu_buy/core/utils/validators.dart';
import 'package:uhsu_buy/features/cart/data/models/cart_item_model.dart';
import 'package:uhsu_buy/features/order/data/models/order_model.dart';

void main() {
  group('Validators Quality Tests', () {
    test('Password complexity enforces at least 8 characters, letters and digits', () {
      expect(Validators.validatePassword(null), 'Password is required');
      expect(Validators.validatePassword(''), 'Password is required');
      expect(Validators.validatePassword('12345'), 'Password must be at least 8 characters long');
      expect(Validators.validatePassword('12345678'), isNotNull); // no letter
      expect(Validators.validatePassword('abcdefgh'), isNotNull); // no digit
      expect(Validators.validatePassword('password123'), isNotNull); // weak password
      expect(Validators.validatePassword('ValidPass123'), isNull); // passes
    });

    test('Email validation catches invalid and accepts valid emails', () {
      expect(Validators.validateEmail('invalid-email'), isNotNull);
      expect(Validators.validateEmail('user@domain.com'), isNull);
    });

    test('Phone validation checks emptiness', () {
      expect(Validators.validatePhone(''), 'Phone number is required');
      expect(Validators.validatePhone('03001234567'), isNull);
    });
  });

  group('CartItemModel Robust Parsing Tests', () {
    test('Correctly extracts stock from nested product objects without 10-fallback', () {
      final json = {
        '_id': 'item1',
        'product': {
          '_id': 'p1',
          'name': 'Test Item',
          'price': 1500,
          'stock': 12,
        },
        'quantity': 2,
        'price': 1500,
      };

      final cartItem = CartItemModel.fromJson(json);
      expect(cartItem.stock, 12);
      expect(cartItem.quantity, 2);
      expect(cartItem.price, 1500.0);
    });

    test('Safely handles out-of-stock items (stock 0)', () {
      final json = {
        '_id': 'item2',
        'product': {
          '_id': 'p2',
          'name': 'Zero Stock Item',
          'price': 500,
          'stock': 0,
        },
        'quantity': 1,
      };

      final cartItem = CartItemModel.fromJson(json);
      expect(cartItem.stock, 0);
    });
  });

  group('OrderModel Return Policy Tests', () {
    test('Non-delivered order cannot be returned', () {
      final order = OrderModel(
        id: 'o1',
        status: 'shipped',
        totalAmount: 1000,
        createdAt: DateTime.now().toIso8601String(),
        items: [],
      );
      expect(order.canReturn, false);
    });

    test('Delivered order within return period can be returned', () {
      final order = OrderModel(
        id: 'o2',
        status: 'delivered',
        totalAmount: 1000,
        createdAt: DateTime.now().subtract(const Duration(days: 20)).toIso8601String(),
        deliveredAt: DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
        returnDays: 7,
        items: [],
      );
      expect(order.canReturn, true);
    });

    test('Delivered order past return period cannot be returned', () {
      final order = OrderModel(
        id: 'o3',
        status: 'delivered',
        totalAmount: 1000,
        createdAt: DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
        deliveredAt: DateTime.now().subtract(const Duration(days: 10)).toIso8601String(),
        returnDays: 7,
        items: [],
      );
      expect(order.canReturn, false);
    });
  });
}
