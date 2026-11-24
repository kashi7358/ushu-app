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
    final formData = FormData();

    // Text Fields
    formData.fields.addAll([
      MapEntry('fullName', fullName),
      MapEntry('DisplayName', displayName),
      MapEntry('Email', email),
      MapEntry('Phone_Number', phoneNumber),
      MapEntry('Password', password),
      MapEntry('Confirm_Password', confirmPassword),
      MapEntry('Role', role),
      MapEntry('StoreName', storeName),
      MapEntry('BusinessType', businessType),
      MapEntry('City', city),
      MapEntry('Province', province),
      MapEntry('Business_Address', businessAddress),
      MapEntry('Monthly_Sales_Estimate', monthlySalesEstimate),
      MapEntry('CNIC', cnic),
      MapEntry('IBAN_Number', ibanNumber),
      MapEntry('BankName', bankName),
      MapEntry('AccountHolder', accountHolder),
      const MapEntry('agreementAccepted', 'true'),
      const MapEntry('agreementVersion', '1.1'),
      const MapEntry('sellerAgreement', 'true'),
      const MapEntry('SellerAgreement', 'true'),
    ]);

    if (cnicFrontPhotoPath != null && cnicFrontPhotoPath!.isNotEmpty) {
      final file = File(cnicFrontPhotoPath!);
      if (await file.exists()) {
        final filename = cnicFrontPhotoPath!.split(Platform.pathSeparator).last;
        formData.files.add(MapEntry(
          'CNIC_frontPhoto',
          await MultipartFile.fromFile(
            cnicFrontPhotoPath!,
            filename: filename,
          ),
        ));
      }
    }

    if (cnicBackPhotoPath != null && cnicBackPhotoPath!.isNotEmpty) {
      final file = File(cnicBackPhotoPath!);
      if (await file.exists()) {
        final filename = cnicBackPhotoPath!.split(Platform.pathSeparator).last;
        formData.files.add(MapEntry(
          'CNIC_backphoto',
          await MultipartFile.fromFile(
            cnicBackPhotoPath!,
            filename: filename,
          ),
        ));
      }
    }

    return formData;
  }
}
