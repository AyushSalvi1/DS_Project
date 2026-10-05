import '../entities/alternative_entity.dart';
import '../entities/external_listing_entity.dart';
import '../entities/product_entity.dart';

/// عقد إيجاد البدائل — أرخص / أفضل / مشابه / أحدث.
abstract class AlternativesRepository {
  Future<List<AlternativeProduct>> findAlternatives(
    ProductEntity product, {
    required List<ProductEntity> catalog,
    List<ExternalListingEntity> webListings = const [],
    int limit = 8,
  });
}
