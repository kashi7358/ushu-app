import 'dart:io';
import 'package:dio/dio.dart';

class CreateProductRequestModel {
  final String name;
  final String description;
  final String sku;
  final String price;
  final String priceCurrency;
  final String category;
  final String subCategory;
  final String brand;
  final String condition;
  final String stock;
  final String lowStockThreshold;
  final bool trackInventory;
  final String tags;
  final String weight;
  final String length;
  final String height;
  final String width;
  final List<String> variants;
  final String? variantAttributes1;
  final List<String> imagePaths;
  final String? videoPath;
  final List<String> variantImagePaths;

  const CreateProductRequestModel({
    required this.name,
    required this.description,
    required this.sku,
    required this.price,
    this.priceCurrency = 'PKR',
    required this.category,
    required this.subCategory,
    required this.brand,
    this.condition = 'new',
    required this.stock,
    this.lowStockThreshold = '5',
    this.trackInventory = true,
    required this.tags,
    required this.weight,
    required this.length,
    required this.height,
    required this.width,
    this.variants = const [],
    this.variantAttributes1,
    this.imagePaths = const [],
    this.videoPath,
    this.variantImagePaths = const [],
  });

  Future<FormData> toFormData() async {
    final Map<String, dynamic> map = {
      'name': name,
      'description': description,
      'sku': sku,
      'price': price,
      'priceCurrency': priceCurrency,
      'category': category,
      'SubCategory': subCategory,
      'brand': brand,
      'condition': condition,
      'stock': stock,
      'lowStockThreshold': lowStockThreshold,
      'trackInventory': trackInventory.toString(),
      'tags': tags,
      'weight': weight,
      'dimensions[length]': length,
      'dimensions[height]': height,
      'dimensions[width]': width,
    };

    // Variants (e.g. variants[0]: Black)
    for (int i = 0; i < variants.length; i++) {
      map['variants[$i]'] = variants[i];
    }

    if (variantAttributes1 != null && variantAttributes1!.isNotEmpty) {
      map['variant_attributes_1'] = variantAttributes1;
    }

    // Product Images (multiple)
    final List<MultipartFile> imageFiles = [];
    for (final path in imagePaths) {
      final file = File(path);
      if (await file.exists()) {
        final filename = path.split(Platform.pathSeparator).last;
        imageFiles.add(await MultipartFile.fromFile(path, filename: filename));
      }
    }
    if (imageFiles.isNotEmpty) {
      map['images'] = imageFiles.length == 1 ? imageFiles.first : imageFiles;
    }

    // Product Video
    if (videoPath != null && videoPath!.isNotEmpty) {
      final file = File(videoPath!);
      if (await file.exists()) {
        final filename = videoPath!.split(Platform.pathSeparator).last;
        map['videos'] = await MultipartFile.fromFile(videoPath!, filename: filename);
      }
    }

    // Variant Images
    final List<MultipartFile> variantFiles = [];
    for (final path in variantImagePaths) {
      final file = File(path);
      if (await file.exists()) {
        final filename = path.split(Platform.pathSeparator).last;
        variantFiles.add(await MultipartFile.fromFile(path, filename: filename));
      }
    }
    if (variantFiles.isNotEmpty) {
      map['variantImages_1'] = variantFiles.length == 1 ? variantFiles.first : variantFiles;
    }

    return FormData.fromMap(map);
  }
}
