import '../entities/duplicate_group_entity.dart';
import '../entities/external_listing_entity.dart';
import '../entities/product_entity.dart';
import '../repositories/duplicate_detection_repository.dart';
import '../utils/duplicate_detector.dart';

/// تنفيذ كشف التكرار الذكي عبر
/// المواقع — نفس المنتج في أكتر
/// من تاجر أو مكرر في الكتالوج.
class DuplicateDetectionRepositoryImpl
    implements DuplicateDetectionRepository {
  final DuplicateDetector _detector;

  DuplicateDetectionRepositoryImpl({DuplicateDetector? detector})
      : _detector = detector ?? DuplicateDetector();

  @override
  Future<List<DuplicateGroup>> findDuplicates({
    required List<ProductEntity> localProducts,
    required List<ExternalListingEntity> webListings,
    double threshold = 0.72,
  }) async {
    final groups = <DuplicateGroup>[];
    final matchedListings = <String>{};

    for (final product in localProducts) {
      final matchingListings = <String>[];
      final matchingProducts = <String>[];
      var bestSimilarity = 0.0;

      // نقارن مع كل العروض الخارجية.
      for (final listing in webListings) {
        if (matchedListings.contains(listing.id)) continue;
        final similarity =
            _detector.similarityWithListing(product, listing);
        if (similarity >= threshold) {
          matchingListings.add(listing.id);
          matchedListings.add(listing.id);
          if (similarity > bestSimilarity) {
            bestSimilarity = similarity;
          }
        }
      }

      // نقارن مع بقية المنتجات المحلية
      // (كشف التكرار الداخلي).
      for (final other in localProducts) {
        if (other.id == product.id) continue;
        final similarity = _detector.similarity(product, other);
        if (similarity >= threshold) {
          matchingProducts.add(other.id);
          if (similarity > bestSimilarity) {
            bestSimilarity = similarity;
          }
        }
      }

      if (matchingListings.isEmpty && matchingProducts.isEmpty) {
        continue;
      }

      groups.add(DuplicateGroup(
        canonicalProductId: product.id,
        listingIds: matchingListings,
        productIds: matchingProducts,
        similarity: bestSimilarity,
      ));
    }

    // نرتب الأقوى تشابهًا أولًا.
    groups.sort((a, b) => b.similarity.compareTo(a.similarity));
    return groups;
  }

  @override
  double similarity(ProductEntity a, ProductEntity b) {
    return _detector.similarity(a, b);
  }

  @override
  double similarityWithListing(
    ProductEntity a,
    ExternalListingEntity b,
  ) {
    return _detector.similarityWithListing(a, b);
  }
}
