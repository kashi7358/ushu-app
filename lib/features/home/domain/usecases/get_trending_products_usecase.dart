import '../entities/product_entity.dart';
import '../repositories/home_repository.dart';

class GetTrendingProductsUseCase {
  final HomeRepository repository;

  GetTrendingProductsUseCase(this.repository);

  Future<List<ProductEntity>> execute() async {
    return await repository.getTrendingProducts();
  }
}
