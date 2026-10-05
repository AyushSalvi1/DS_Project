import '../entities/duplicate_group_entity.dart';
import '../entities/external_listing_entity.dart';
import '../entities/product_entity.dart';

/// عقد كشف التكرار الذكي عبر المواقع —
/// نفس المنتج في أكتر من تاجر أو مكرر
/// في الكتالوج المحلي.
abstract class DuplicateDetectionRepository {
  /// يقارن المنتجات المحلية بالعروض الخارجية
  /// ويرجّع مجموعات التكرار (أعلى من حد التشابه).
  Future<List<DuplicateGroup>> findDuplicates({
    required List<ProductEntity> localProducts,
    required List<ExternalListingEntity> webListings,
    double threshold = 0.72,
  });

  /// يقارن منتجين محليين ويرجّع درجة التشابه (0-1).
  double similarity(ProductEntity a, ProductEntity b);

  /// يقارن منتج محلي بعرض خارجي ويرجّع درجة التشابه.
  double similarityWithListing(ProductEntity a, ExternalListingEntity b);
}
