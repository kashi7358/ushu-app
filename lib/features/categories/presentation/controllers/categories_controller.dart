import 'package:get/get.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import 'package:flutter/material.dart';
import '../../data/models/category_model.dart';

class CategoriesController extends GetxController {
  final ApiClient _apiClient = ApiClient();
  
  final RxList<CategoryModel> categoriesList = <CategoryModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxInt selectedIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    try {
      isLoading.value = true;
      final response = await _apiClient.dio.get(ApiEndpoints.categoriesWithImages);
      
      if (response.data['success'] == true && response.data['data'] != null) {
        final List<dynamic> catList = response.data['data'];
        categoriesList.value = catList.map((c) => CategoryModel.fromJson(c)).toList();
      }
    } catch (e) {
      debugPrint('Error fetching categories: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
