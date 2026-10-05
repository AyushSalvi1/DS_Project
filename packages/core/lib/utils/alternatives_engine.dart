import '../entities/alternative_entity.dart';
import '../entities/external_listing_entity.dart';
import '../entities/product_entity.dart';

/// محرك البدائل الحتمي — أرخص / أفضل /
/// مشابه / أحدث. يشتغل أوفلاين من غير
/// أي نداء شبكة.
class AlternativesEngine {
  /// بياخد منتج ويرجّع بدائل مرتبة بالملاءمة.
  static List<AlternativeProduct> find({
    required ProductEntity product,
    required List<ProductEntity> catalog,
    List<ExternalListingEntity> webListings = const [],
    int limit = 8,
  }) {
    final cheaper = _cheaper(product, catalog, webListings);
    final better = _better(product, catalog);
    final similar = _similar(product, catalog);
    final newer = _newer(product, catalog);

    final all = <AlternativeProduct>[...cheaper, ...better, ...similar, ...newer];

    // نزيل التكرار (نفس المنتج ممكن يظهر في
    // أكتر من نوع) وبعدين نرتب بالدرجة
    // وناخد الأعلى — عشان الترشيح
    // ميتقصّش قبل الفرز.
    final seen = <String>{};
    final result = <AlternativeProduct>[];
    for (final alt in all) {
      if (seen.contains(alt.product.id)) continue;
      seen.add(alt.product.id);
      result.add(alt);
    }

    result.sort((a, b) => b.score.compareTo(a.score));
    return result.take(limit).toList();
  }

  /// أرخص: نفس الفئة، سعر أقل بشكل ملموس.
  static List<AlternativeProduct> _cheaper(
    ProductEntity product,
    List<ProductEntity> catalog,
    List<ExternalListingEntity> webListings,
  ) {
    if (product.price <= 0) return const [];
    final candidates = catalog.where((p) {
      if (p.id == product.id) return false;
      if (p.categoryId != product.categoryId) return false;
      return p.price < product.price * 0.95;
    }).toList();

    // ندمج أرخص عرض خارجي لو أنسب.
    for (final listing in webListings) {
      if (listing.productId == product.id) continue;
      if (listing.effectivePrice >= product.price * 0.95) continue;
      candidates.add(_listingToProduct(listing));
    }

    candidates.sort((a, b) => a.price.compareTo(b.price));

    return candidates.take(3).map((p) {
      final savings = product.price - p.price;
      final percent = ((savings / product.price) * 100).round();
      return AlternativeProduct(
        product: p,
        type: AlternativeType.cheaper,
        reason: savings > 0
            ? 'Same category, $percent% cheaper'
            : 'Lower total price (with shipping)',
        savings: savings,
        score: 70.0 + (savings / product.price * 30).clamp(0.0, 25.0).toDouble(),
      );
    }).toList();
  }

  /// أفضل: نفس الفئة، تقييم أعلى أو مراجعات أكثر
  /// بكثير، بسعر معقول (ضمن 30% زيادة).
  static List<AlternativeProduct> _better(
    ProductEntity product,
    List<ProductEntity> catalog,
  ) {
    final candidates = catalog.where((p) {
      if (p.id == product.id) return false;
      if (p.categoryId != product.categoryId) return false;
      if (p.price > product.price * 1.3) return false;
      final betterRating = p.rating > product.rating;
      final muchMoreReviewed =
          p.reviewCount > product.reviewCount * 1.5 && p.rating >= product.rating;
      return betterRating || muchMoreReviewed;
    }).toList();

    candidates.sort((a, b) {
      final ratingCompare = b.rating.compareTo(a.rating);
      if (ratingCompare != 0) return ratingCompare;
      return b.reviewCount.compareTo(a.reviewCount);
    });

    return candidates.take(3).map((p) {
      final ratingDelta = (p.rating - product.rating).toStringAsFixed(1);
      return AlternativeProduct(
        product: p,
        type: AlternativeType.better,
        reason: p.rating > product.rating
            ? 'Higher rated (${p.rating.toStringAsFixed(1)}★ vs ${product.rating.toStringAsFixed(1)}★, +$ratingDelta)'
            : 'Far more reviews (${p.reviewCount}) with equal rating',
        score: 75.0 + (p.rating - product.rating) * 10,
      );
    }).toList();
  }

  /// مشابه: نفس الفئة/الفئة الفرعية أو كلمات
  /// مشتركة في الاسم/الوصف.
  static List<AlternativeProduct> _similar(
    ProductEntity product,
    List<ProductEntity> catalog,
  ) {
    final productTokens = _tokens('${product.name} ${product.description}');

    final candidates = catalog.where((p) {
      if (p.id == product.id) return false;
      if (p.categoryId == product.categoryId) return true;
      if (product.subcategoryId != null &&
          p.subcategoryId == product.subcategoryId) {
        return true;
      }
      final pTokens = _tokens('${p.name} ${p.description}');
      final shared = productTokens.intersection(pTokens).length;
      return shared >= 2;
    }).toList();

    // نرتب حسب قوة التشابه.
    candidates.sort((a, b) {
      final scoreA = _similarityScore(product, a);
      final scoreB = _similarityScore(product, b);
      return scoreB.compareTo(scoreA);
    });

    return candidates.take(4).map((p) {
      final sim = _similarityScore(product, p);
      return AlternativeProduct(
        product: p,
        type: AlternativeType.similar,
        reason: 'Similar style and features${product.color != null && p.color == product.color ? ' • same color' : ''}',
        score: 55.0 + sim * 40,
      );
    }).toList();
  }

  /// أحدث: نفس الفئة واتضاف بعد المنتج الحالي.
  static List<AlternativeProduct> _newer(
    ProductEntity product,
    List<ProductEntity> catalog,
  ) {
    final candidates = catalog.where((p) {
      if (p.id == product.id) return false;
      if (p.categoryId != product.categoryId) return false;
      return p.createdAt.isAfter(product.createdAt);
    }).toList();

    candidates.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return candidates.take(3).map((p) {
      final days = p.createdAt.difference(product.createdAt).inDays;
      return AlternativeProduct(
        product: p,
        type: AlternativeType.newer,
        reason: days > 30
            ? 'Newer arrival (${(days / 30).round()} months newer)'
            : 'Newer arrival (added $days days later)',
        score: 60.0 + (days / 365 * 35).clamp(0.0, 35.0).toDouble(),
      );
    }).toList();
  }

  /// يحول عرض خارجي لكائن منتج محلي
  /// عشان يقدر يظهر في نفس قايمة البدائل.
  static ProductEntity _listingToProduct(ExternalListingEntity listing) {
    return ProductEntity(
      id: 'ext-${listing.id}',
      name: listing.title,
      description: listing.description,
      price: listing.effectivePrice,
      images: [if (listing.imageUrl != null) listing.imageUrl!],
      categoryId: '',
      rating: listing.rating,
      reviewCount: listing.reviewCount,
      stock: listing.isInStock ? 1 : 0,
      createdAt: listing.lastSeenAt,
    );
  }

  static Set<String> _tokens(String text) {
    return text
        .toLowerCase()
        .split(RegExp(r'[^a-z0-9\u0600-\u06FF]+'))
        .where((t) => t.length > 2)
        .toSet();
  }

  static double _similarityScore(ProductEntity a, ProductEntity b) {
    final tokensA = _tokens('${a.name} ${a.description}');
    final tokensB = _tokens('${b.name} ${b.description}');
    if (tokensA.isEmpty || tokensB.isEmpty) return 0;
    final intersection = tokensA.intersection(tokensB).length;
    final union = tokensA.union(tokensB).length;
    return intersection / union;
  }
}
