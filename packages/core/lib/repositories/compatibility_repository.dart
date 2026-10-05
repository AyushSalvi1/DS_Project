import '../entities/compatibility_entity.dart';
import '../entities/product_entity.dart';

/// عقد توصيات التوافق — "المنتجات اللي
/// بتكمل بعض" (عناصر متكاملة).
abstract class CompatibilityRepository {
  Future<List<CompatibilityEntity>> getCompatibleProducts(
    ProductEntity product, {
    required List<ProductEntity> catalog,
    required List<String> purchasedProductIds,
    int limit = 6,
  });
}
