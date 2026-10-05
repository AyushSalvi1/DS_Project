import '../entities/alternative_entity.dart';
import '../entities/external_listing_entity.dart';
import '../entities/product_entity.dart';
import '../repositories/alternatives_repository.dart';
import '../utils/alternatives_engine.dart';

/// تنفيذ إيجاد البدائل — أرخص /
/// أفضل / مشابه / أحدث.
///
/// المحرك حتمي (يشتغل أوفلاين) —
/// ونرسل النتايج للذكاء الاصطناعي
/// بعدين لو حبينا نولّد أسباب
/// بلغة طبيعية أكتر.
class AlternativesRepositoryImpl implements AlternativesRepository {
  @override
  Future<List<AlternativeProduct>> findAlternatives(
    ProductEntity product, {
    required List<ProductEntity> catalog,
    List<ExternalListingEntity> webListings = const [],
    int limit = 8,
  }) async {
    return AlternativesEngine.find(
      product: product,
      catalog: catalog,
      webListings: webListings,
      limit: limit,
    );
  }
}
