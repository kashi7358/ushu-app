import 'package:get/get.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/usecases/get_home_products_usecase.dart';
import '../../domain/usecases/get_flash_sale_usecase.dart';
import '../../domain/usecases/get_trending_products_usecase.dart';
import '../../domain/usecases/get_banner_products_usecase.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/home_cache_manager.dart';
import '../../data/datasources/home_remote_data_source.dart';
import '../../data/repositories/home_repository_impl.dart';

class HomeController extends GetxController {
  final RxList<ProductEntity> products = <ProductEntity>[].obs;
  final RxList<ProductEntity> flashSaleProducts = <ProductEntity>[].obs;
  final RxList<ProductEntity> trendingProducts = <ProductEntity>[].obs;
  final RxList<ProductEntity> bannerProducts = <ProductEntity>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool isBannerLoading = true.obs;
  final RxBool isFlashSaleLoading = true.obs;
  final RxBool isTrendingLoading = true.obs;
  final RxBool isNoInternet = false.obs;

  late final GetHomeProductsUseCase _getHomeProductsUseCase;
  late final GetFlashSaleUseCase _getFlashSaleUseCase;
  late final GetTrendingProductsUseCase _getTrendingProductsUseCase;
  late final GetBannerProductsUseCase _getBannerProductsUseCase;

  @override
  void onInit() {
    super.onInit();
    final apiClient = ApiClient();
    final remoteDataSource = HomeRemoteDataSourceImpl(apiClient);
    final repository = HomeRepositoryImpl(remoteDataSource);
    _getHomeProductsUseCase = GetHomeProductsUseCase(repository);
    _getFlashSaleUseCase = GetFlashSaleUseCase(repository);
    _getTrendingProductsUseCase = GetTrendingProductsUseCase(repository);
    _getBannerProductsUseCase = GetBannerProductsUseCase(repository);
    
    _loadInitialCache();
    refreshHomeData();
  }

  Future<void> _loadInitialCache() async {
    final cached = await HomeCacheManager.getHomepageProducts();
    if (cached.isNotEmpty) {
      products.assignAll(cached);
      isLoading.value = false;
    }
  }

  Future<void> refreshHomeData() async {
    isNoInternet.value = false;
    await Future.wait([
      fetchBannerProducts(),
      fetchProducts(),
      fetchFlashSale(),
      fetchTrendingProducts(),
    ]);
  }

  Future<void> fetchBannerProducts() async {
    try {
      isBannerLoading.value = true;
      final result = await _getBannerProductsUseCase.execute();
      bannerProducts.assignAll(result);
    } catch (e) {
      // Handle silently
    } finally {
      isBannerLoading.value = false;
    }
  }

  Future<void> fetchProducts() async {
    try {
      isLoading.value = true;
      final result = await _getHomeProductsUseCase.execute();
      products.assignAll(result);
      isNoInternet.value = false;
    } catch (e) {
      if (products.isEmpty) {
        isNoInternet.value = true;
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchFlashSale() async {
    try {
      isFlashSaleLoading.value = true;
      final result = await _getFlashSaleUseCase.execute();
      flashSaleProducts.assignAll(result);
    } catch (e) {
      // Silently handle if flash sale fails
    } finally {
      isFlashSaleLoading.value = false;
    }
  }

  Future<void> fetchTrendingProducts() async {
    try {
      isTrendingLoading.value = true;
      final result = await _getTrendingProductsUseCase.execute();
      trendingProducts.assignAll(result);
    } catch (e) {
      // Handle silently
    } finally {
      isTrendingLoading.value = false;
    }
  }
}
