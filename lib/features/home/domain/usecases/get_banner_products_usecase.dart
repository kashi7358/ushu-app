import '../entities/product_entity.dart';
import '../repositories/home_repository.dart';

class GetBannerProductsUseCase {
  final HomeRepository repository;

  GetBannerProductsUseCase(this.repository);

  Future<List<ProductEntity>> execute() async {
    return await repository.getBannerProducts();
  }
}

