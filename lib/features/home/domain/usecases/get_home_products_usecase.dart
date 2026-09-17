import '../entities/product_entity.dart';
import '../repositories/home_repository.dart';

class GetHomeProductsUseCase {
  final HomeRepository repository;

  GetHomeProductsUseCase(this.repository);

  Future<List<ProductEntity>> execute() async {
    return await repository.getAllHomepageProducts();
  }
}
