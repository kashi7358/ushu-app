import 'package:dio/dio.dart';

class CreateBannerRequestModel {
  final String name;
  final String email;
  final String phone;
  final String title;
  final String bannerImagePath;
  final String description;
  final String startDate;
  final String endDate;

  const CreateBannerRequestModel({
    required this.name,
    required this.email,
    required this.phone,
    required this.title,
    required this.bannerImagePath,
    required this.description,
    required this.startDate,
    required this.endDate,
  });

  Future<FormData> toFormData() async {
    final fileName = bannerImagePath.split(RegExp(r'[/\\]')).last;

    return FormData.fromMap({
      'Name': name,
      'Email': email,
      'phone': phone,
      'title': title,
      'Bannerimage': await MultipartFile.fromFile(
        bannerImagePath,
        filename: fileName.isNotEmpty ? fileName : 'banner_image.jpg',
      ),
      'description': description,
      'startDate': startDate,
      'endDate': endDate,
    });
  }
}
