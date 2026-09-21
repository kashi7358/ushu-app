import 'package:get/get.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/usecases/get_product_by_id_usecase.dart';
import '../../../../core/network/api_client.dart';
import '../../data/datasources/home_remote_data_source.dart';
import '../../data/repositories/home_repository_impl.dart';
import '../../../../core/errors/exception_handler.dart';

class ProductDetailController extends GetxController {
  final Rx<ProductEntity?> product = Rx<ProductEntity?>(null);
  final RxBool isLoading = true.obs;
  final RxInt selectedImageIndex = 0.obs;
  final reviews = <dynamic>[].obs; // Using dynamic or importing ReviewModel later

  late final GetProductByIdUseCase _getProductByIdUseCase;
  late final String productId;

  @override
  void onInit() {
    super.onInit();
    productId = Get.arguments as String;
    
    final apiClient = ApiClient();
    final remoteDataSource = HomeRemoteDataSourceImpl(apiClient);
    final repository = HomeRepositoryImpl(remoteDataSource);
    _getProductByIdUseCase = GetProductByIdUseCase(repository);
    
    fetchProductDetails();
    fetchReviews();
  }

  Future<void> fetchProductDetails() async {
    try {
      isLoading.value = true;
      final result = await _getProductByIdUseCase.execute(productId);
      product.value = result;
      selectedImageIndex.value = 0;
    } catch (e) {
      final error = ExceptionHandler.handle(e);
      Get.snackbar('Error', error.message, snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchReviews() async {
    try {
      final apiClient = ApiClient();
      final response = await apiClient.dio.get(
        'https://ecombackend.ushu.pk/api/review/all/$productId',
      );
      final data = response.data;
      if (data != null && data['success'] == true) {
        reviews.assignAll(data['reviews'] ?? []);
      }
    } catch (e) {
      print('Error fetching reviews: $e');
    }
  }
}
