import '../entities/product_entity.dart';

abstract class HomeRepository {
  Future<List<ProductEntity>> getAllHomepageProducts();
  Future<ProductEntity> getProductById(String id);
  Future<List<ProductEntity>> getFlashSaleProducts();
  Future<List<ProductEntity>> getTrendingProducts();
  Future<List<ProductEntity>> getBannerProducts();
}
