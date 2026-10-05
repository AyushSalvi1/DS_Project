import '../entities/compatibility_entity.dart';
import '../entities/product_entity.dart';
import '../repositories/compatibility_repository.dart';
import '../utils/compatibility_engine.dart';

/// تنفيذ توصيات التوافق —
/// "المنتجات اللي بتكمل بعض".
class CompatibilityRepositoryImpl
    implements CompatibilityRepository {
  @override
  Future<List<CompatibilityEntity>> getCompatibleProducts(
    ProductEntity product, {
    required List<ProductEntity> catalog,
    required List<String> purchasedProductIds,
    int limit = 6,
  }) async {
    return CompatibilityEngine.compute(
      product: product,
      catalog: catalog,
      purchasedProductIds: purchasedProductIds,
      limit: limit,
    );
  }
}
