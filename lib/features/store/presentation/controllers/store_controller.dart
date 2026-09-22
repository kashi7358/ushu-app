import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/utils/custom_popup.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StoreController extends GetxController {
  final ApiClient _apiClient = ApiClient();
  
  final RxBool isLoading = true.obs;
  final RxBool isFollowing = false.obs;
  final RxMap<String, dynamic> storeData = <String, dynamic>{}.obs;
  final RxList<dynamic> productsData = <dynamic>[].obs;
  
  late String storeId;

  @override
  void onInit() {
    super.onInit();
    storeId = Get.arguments as String? ?? '';
    if (storeId.isNotEmpty) {
      fetchStoreData();
    } else {
      isLoading.value = false;
      CustomPopup.showError('Error', 'Invalid Store ID');
    }
  }

  Future<void> fetchStoreData() async {
    try {
      isLoading.value = true;
      final response = await _apiClient.dio.get(
        ApiEndpoints.getStore(storeId),
        options: Options(validateStatus: (status) => true),
      );

      final data = response.data;
      if (data != null && data['success'] == true) {
        storeData.value = data['store'] ?? {};
        productsData.value = data['products'] ?? [];
        _checkIfFollowing();
      } else {
        CustomPopup.showError('Failed', data?['message'] ?? 'Store not found');
      }
    } catch (e) {
      CustomPopup.showError('Error', 'Failed to load store details');
    } finally {
      isLoading.value = false;
    }
  }

  void _checkIfFollowing() async {
    final prefs = await SharedPreferences.getInstance();
    final followedStores = prefs.getStringList('followed_stores') ?? [];
    isFollowing.value = followedStores.contains(storeId);
  }

  Future<void> toggleFollow() async {
    final prefs = await SharedPreferences.getInstance();
    final followedStores = prefs.getStringList('followed_stores') ?? [];
    
    if (isFollowing.value) {
      followedStores.remove(storeId);
      isFollowing.value = false;
    } else {
      followedStores.add(storeId);
      isFollowing.value = true;
      CustomPopup.showToast('Success', 'Store followed successfully');
    }
    
    await prefs.setStringList('followed_stores', followedStores);
  }
}
