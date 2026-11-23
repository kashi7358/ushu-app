import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Seller Profile & Update Tests', () {
    test('Constructs patch payload correctly with password', () {
      final String fullName = "Syed Kamran";
      final String phoneNumber = "03185915209";
      final String? currentPassword = "P@kistan123";
      final String? newPassword = "P@kistan1234";
      final String? confirmPassword = "P@kistan1234";

      final Map<String, dynamic> body = {
        'fullName': fullName.trim(),
        'Phone_Number': phoneNumber.trim(),
      };

      if (currentPassword != null && currentPassword.trim().isNotEmpty) {
        body['currentPassword'] = currentPassword.trim();
        body['newPassword'] = (newPassword ?? '').trim();
        body['confirmPassword'] = (confirmPassword ?? '').trim();
      }

      expect(body['fullName'], 'Syed Kamran');
      expect(body['Phone_Number'], '03185915209');
      expect(body['currentPassword'], 'P@kistan123');
      expect(body['newPassword'], 'P@kistan1234');
      expect(body['confirmPassword'], 'P@kistan1234');
    });

    test('Constructs patch payload correctly without password', () {
      final String fullName = "Syed Kamran";
      final String phoneNumber = "03185915209";

      final Map<String, dynamic> body = {
        'fullName': fullName.trim(),
        'Phone_Number': phoneNumber.trim(),
      };

      expect(body['fullName'], 'Syed Kamran');
      expect(body['Phone_Number'], '03185915209');
      expect(body.containsKey('currentPassword'), false);
      expect(body.containsKey('newPassword'), false);
    });
  });
}
