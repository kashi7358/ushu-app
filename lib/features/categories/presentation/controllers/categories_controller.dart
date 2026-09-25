import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../data/models/category_model.dart';
import '../../../home/data/models/product_model.dart';
import '../../../home/presentation/controllers/home_controller.dart';

class CategoriesController extends GetxController {
  final ApiClient _apiClient = ApiClient();
  
  final RxList<CategoryModel> categoriesList = <CategoryModel>[].obs;
  final RxList<ProductModel> allProducts = <ProductModel>[].obs;
  final RxList<ProductModel> categoryProducts = <ProductModel>[].obs;
  final RxString selectedSubCategory = ''.obs;
  
  final RxBool isLoading = false.obs;
  final RxBool isProductsLoading = false.obs;
  final RxInt selectedIndex = 0.obs;
  final RxString categorySearchQuery = ''.obs;

  List<CategoryModel> get filteredCategories {
    if (categorySearchQuery.value.trim().isEmpty) return categoriesList;
    final query = categorySearchQuery.value.trim().toLowerCase();
    return categoriesList.where((c) => c.category.toLowerCase().contains(query)).toList();
  }

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    try {
      isLoading.value = true;
      final response = await _apiClient.dio.get(ApiEndpoints.categoriesWithImages);
      
      if (response.data != null && response.data['success'] == true && response.data['data'] != null) {
        final List<dynamic> catList = response.data['data'];
        categoriesList.value = catList.map((c) => CategoryModel.fromJson(c)).toList();
      }

      // Fetch homepage products to extract category matches
      await fetchAllProducts();

      if (categoriesList.isNotEmpty) {
        selectCategory(0);
      }
    } catch (e) {
      debugPrint('Error fetching categories: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchAllProducts() async {
    if (Get.isRegistered<HomeController>()) {
      final homeCtrl = Get.find<HomeController>();
      if (homeCtrl.products.isNotEmpty) {
        allProducts.value = homeCtrl.products.map((p) => ProductModel(
          id: p.id,
          name: p.name,
          category: p.category,
          price: p.price,
          discountPriceOrg: p.discountPriceOrg,
          priceCurrency: p.priceCurrency,
          stock: p.stock,
          rating: p.rating,
          totalReviews: p.totalReviews,
          image: p.image,
          images: p.images,
          description: p.description,
          brand: p.brand,
        )).toList();
        return;
      }
    }
    try {
      final response = await _apiClient.dio.get(
        ApiEndpoints.allHomepageProducts,
        options: Options(validateStatus: (status) => true),
      );
      final data = response.data;
      if (data != null && data['products'] != null) {
        final List list = data['products'];
        allProducts.value = list.map((p) => ProductModel.fromJson(p)).toList();
      }
    } catch (e) {
      debugPrint('Error fetching all products for categories: $e');
    }
  }

  void selectCategory(int index) async {
    selectedIndex.value = index;
    selectedSubCategory.value = '';
    if (categoriesList.isEmpty || index >= categoriesList.length) return;

    final targetCategory = categoriesList[index].category.trim().toLowerCase();

    // Filter local products
    var matched = allProducts.where((p) {
      final pCat = p.category.trim().toLowerCase();
      return pCat == targetCategory || pCat.contains(targetCategory) || targetCategory.contains(pCat);
    }).toList();

    // If local match is empty, try live search API by category name
    if (matched.isEmpty) {
      try {
        isProductsLoading.value = true;
        final res = await _apiClient.dio.get(
          ApiEndpoints.searchKeyword(categoriesList[index].category),
          options: Options(validateStatus: (status) => true),
        );
        final data = res.data;
        if (data != null && data['success'] == true && data['data'] != null) {
          final List list = data['data'];
          matched = list.map((p) => ProductModel.fromJson(p)).toList();
        }
      } catch (e) {
        debugPrint('Category search error: $e');
      } finally {
        isProductsLoading.value = false;
      }
    }

    categoryProducts.value = matched;
  }

  void filterBySubCategory(String subCat) {
    if (selectedSubCategory.value == subCat) {
      selectedSubCategory.value = '';
      selectCategory(selectedIndex.value);
    } else {
      selectedSubCategory.value = subCat;
      final target = subCat.trim().toLowerCase();
      final filtered = categoryProducts.where((p) {
        final pName = p.name.trim().toLowerCase();
        final pDesc = (p.description ?? '').trim().toLowerCase();
        return pName.contains(target) || pDesc.contains(target);
      }).toList();

      if (filtered.isNotEmpty) {
        categoryProducts.value = filtered;
      }
    }
  }
}
