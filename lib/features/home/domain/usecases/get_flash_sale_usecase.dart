import '../entities/product_entity.dart';
import '../repositories/home_repository.dart';

class GetFlashSaleUseCase {
  final HomeRepository repository;

  GetFlashSaleUseCase(this.repository);

  Future<List<ProductEntity>> execute() async {
    return await repository.getFlashSaleProducts();
  }
}
