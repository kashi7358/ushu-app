import 'dart:io';
import 'package:dio/dio.dart';

class CreateStoreRequestModel {
  final String storeName;
  final String storeTagline;
  final String description;
  final String language;
  final String storeContactEmail;
  final String storeWhatsapp;
  final String primaryCity;
  final String warehouseAddress;
  final String socialLinks;
  final String returnPolicy;
  final String warranty;
  final String processingTime;
  final String cancellationPolicy;
  final String shippingMethod;
  final String deliveryZones;
  final String shippingCharges;
  final String? createdBy;
  final String? logoPath;
  final String? storeBannerPath;

  const CreateStoreRequestModel({
    required this.storeName,
    required this.storeTagline,
    required this.description,
    required this.language,
    required this.storeContactEmail,
    required this.storeWhatsapp,
    required this.primaryCity,
    required this.warehouseAddress,
    required this.socialLinks,
    required this.returnPolicy,
    required this.warranty,
    required this.processingTime,
    required this.cancellationPolicy,
    required this.shippingMethod,
    required this.deliveryZones,
    required this.shippingCharges,
    this.createdBy,
    this.logoPath,
    this.storeBannerPath,
  });

  Future<FormData> toFormData() async {
    final Map<String, dynamic> map = {
      'StoreName': storeName,
      'Storetagline': storeTagline,
      'description': description,
      'language': language,
      'StoreContactEmail': storeContactEmail,
      'StoreWhatsapp': storeWhatsapp,
      'PrimaryCity': primaryCity,
      'WarehouseAddress': warehouseAddress,
      'SocialLinks': socialLinks,
      'ReturnPolicy': returnPolicy,
      'Warrenty': warranty,
      'ProcessingTime': processingTime,
      'CancellationPolicy': cancellationPolicy,
      'ShippingMethod': shippingMethod,
      'DeliveryZones': deliveryZones,
      'ShippingCharges': shippingCharges,
    };

    if (createdBy != null && createdBy!.isNotEmpty) {
      map['createdBy'] = createdBy;
    }

    if (logoPath != null && logoPath!.isNotEmpty) {
      final file = File(logoPath!);
      if (await file.exists()) {
        final filename = logoPath!.split(Platform.pathSeparator).last;
        map['logo'] = await MultipartFile.fromFile(
          logoPath!,
          filename: filename,
        );
      }
    }

    if (storeBannerPath != null && storeBannerPath!.isNotEmpty) {
      final file = File(storeBannerPath!);
      if (await file.exists()) {
        final filename = storeBannerPath!.split(Platform.pathSeparator).last;
        map['StoreBanner'] = await MultipartFile.fromFile(
          storeBannerPath!,
          filename: filename,
        );
      }
    }

    return FormData.fromMap(map);
  }
}
