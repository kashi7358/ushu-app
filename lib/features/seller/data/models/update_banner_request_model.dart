import 'package:dio/dio.dart';

class UpdateBannerRequestModel {
  final String? name;
  final String? email;
  final String? phone;
  final String? title;
  final String? bannerImagePath;
  final String? description;
  final String? startDate;
  final String? endDate;

  const UpdateBannerRequestModel({
    this.name,
    this.email,
    this.phone,
    this.title,
    this.bannerImagePath,
    this.description,
    this.startDate,
    this.endDate,
  });

  Future<FormData> toFormData() async {
    final Map<String, dynamic> map = {};

    if (name != null && name!.trim().isNotEmpty) {
      map['Name'] = name!.trim();
    }
    if (email != null && email!.trim().isNotEmpty) {
      map['Email'] = email!.trim();
    }
    if (phone != null && phone!.trim().isNotEmpty) {
      map['phone'] = phone!.trim();
    }
    if (title != null && title!.trim().isNotEmpty) {
      map['title'] = title!.trim();
    }
    if (description != null && description!.trim().isNotEmpty) {
      map['description'] = description!.trim();
    }
    if (startDate != null && startDate!.trim().isNotEmpty) {
      map['startDate'] = startDate!.trim();
    }
    if (endDate != null && endDate!.trim().isNotEmpty) {
      map['endDate'] = endDate!.trim();
    }

    if (bannerImagePath != null && bannerImagePath!.trim().isNotEmpty) {
      final fileName = bannerImagePath!.split(RegExp(r'[/\\]')).last;
      map['Bannerimage'] = await MultipartFile.fromFile(
        bannerImagePath!,
        filename: fileName.isNotEmpty ? fileName : 'updated_banner.jpg',
      );
    }

    return FormData.fromMap(map);
  }
}
