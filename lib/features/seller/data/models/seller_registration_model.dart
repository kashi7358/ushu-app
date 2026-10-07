import 'dart:io';
import 'package:dio/dio.dart';

class SellerRegistrationModel {
  final String fullName;
  final String displayName;
  final String email;
  final String phoneNumber;
  final String password;
  final String confirmPassword;
  final String role;
  final String storeName;
  final String businessType;
  final String city;
  final String province;
  final String businessAddress;
  final String monthlySalesEstimate;
  final String cnic;
  final String ibanNumber;
  final String bankName;
  final String accountHolder;
  final String? cnicFrontPhotoPath;
  final String? cnicBackPhotoPath;

  const SellerRegistrationModel({
    required this.fullName,
    required this.displayName,
    required this.email,
    required this.phoneNumber,
    required this.password,
    required this.confirmPassword,
    this.role = 'Seller',
    required this.storeName,
    required this.businessType,
    required this.city,
    required this.province,
    required this.businessAddress,
    required this.monthlySalesEstimate,
    required this.cnic,
    required this.ibanNumber,
    required this.bankName,
    required this.accountHolder,
    this.cnicFrontPhotoPath,
    this.cnicBackPhotoPath,
  });

  Future<FormData> toFormData() async {
    final Map<String, dynamic> map = {
      'fullName': fullName,
      'DisplayName': displayName,
      'Email': email,
      'Phone_Number': phoneNumber,
      'Password': password,
      'Confirm_Password': confirmPassword,
      'Role': role,
      'StoreName': storeName,
      'BusinessType': businessType,
      'City': city,
      'Province': province,
      'Business_Address': businessAddress,
      'Monthly_Sales_Estimate': monthlySalesEstimate,
      'CNIC': cnic,
      'IBAN_Number': ibanNumber,
      'BankName': bankName,
      'AccountHolder': accountHolder,
    };

    if (cnicFrontPhotoPath != null && cnicFrontPhotoPath!.isNotEmpty) {
      final file = File(cnicFrontPhotoPath!);
      if (await file.exists()) {
        final filename = cnicFrontPhotoPath!.split(Platform.pathSeparator).last;
        map['CNIC_frontPhoto'] = await MultipartFile.fromFile(
          cnicFrontPhotoPath!,
          filename: filename,
        );
      }
    }

    if (cnicBackPhotoPath != null && cnicBackPhotoPath!.isNotEmpty) {
      final file = File(cnicBackPhotoPath!);
      if (await file.exists()) {
        final filename = cnicBackPhotoPath!.split(Platform.pathSeparator).last;
        map['CNIC_backphoto'] = await MultipartFile.fromFile(
          cnicBackPhotoPath!,
          filename: filename,
        );
      }
    }

    return FormData.fromMap(map);
  }
}
