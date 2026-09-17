import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_remote_data_source.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource remoteDataSource;

  HomeRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<ProductEntity>> getAllHomepageProducts() async {
    return await remoteDataSource.getAllHomepageProducts();
  }

  @override
  Future<ProductEntity> getProductById(String id) async {
    return await remoteDataSource.getProductById(id);
  }

  @override
  Future<List<ProductEntity>> getFlashSaleProducts() async {
    return await remoteDataSource.getFlashSaleProducts();
  }

  @override
  Future<List<ProductEntity>> getTrendingProducts() async {
    return await remoteDataSource.getTrendingProducts();
  }

  @override
  Future<List<ProductEntity>> getBannerProducts() async {
    return await remoteDataSource.getBannerProducts();
  }
}
