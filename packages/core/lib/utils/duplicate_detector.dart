import '../entities/external_listing_entity.dart';
import '../entities/product_entity.dart';

/// كاشف التكرار الحتمي — يقارن أسماء ووصف
/// المنتجات (تشابه التوكنات + التطبيع)
/// عشان يلاقي نفس المنتج في أكتر من موقع
/// أو مكرر في الكتالوج المحلي.
class DuplicateDetector {
  /// درجة التشابه بين منتجين محليين (0-1).
  double similarity(ProductEntity a, ProductEntity b) {
    if (a.id == b.id) return 1;

    final nameScore = _nameSimilarity(a.name, b.name);

    // نفس الفئة بترفع الثقة، واختلاف الفئة بيخفضها.
    final categoryBoost =
        a.categoryId == b.categoryId && a.categoryId.isNotEmpty ? 0.08 : 0.0;

    // لون مختلف بيخفض الثقة (مش نفس المنتج بالضرورة).
    final colorPenalty = (a.color != null &&
            b.color != null &&
            a.color != b.color)
        ? 0.15
        : 0.0;

    // فرق سعر أكتر من 50% بيخفض الثقة جدًا.
    final priceRatio = a.price > 0 && b.price > 0
        ? (a.price > b.price ? a.price / b.price : b.price / a.price)
        : 1.0;
    final pricePenalty = priceRatio > 1.5 ? 0.3 : 0.0;

    return (nameScore + categoryBoost - colorPenalty - pricePenalty)
        .clamp(0.0, 1.0)
        .toDouble();
  }

  /// درجة التشابه بين منتج محلي وعرض خارجي.
  double similarityWithListing(
    ProductEntity a,
    ExternalListingEntity b,
  ) {
    final nameScore = _nameSimilarity(a.name, b.title);

    final priceRatio = a.price > 0 && b.price > 0
        ? (a.price > b.price ? a.price / b.price : b.price / a.price)
        : 1.0;
    final pricePenalty = priceRatio > 1.6 ? 0.35 : 0.0;

    return (nameScore - pricePenalty).clamp(0.0, 1.0).toDouble();
  }

  /// تشابه الأسماء: Jaccard على التوكنات +
  /// مكافأة التطابق التام (بعد التطبيع).
  double _nameSimilarity(String a, String b) {
    final normalizedA = _normalize(a);
    final normalizedB = _normalize(b);

    if (normalizedA.isEmpty || normalizedB.isEmpty) return 0;
    if (normalizedA == normalizedB) return 1.0;

    // تطابق جزئي قوي (واحد فيه التاني) —
    // مثال: "Wooden Chair" vs "Chair Wooden Classic".
    if (normalizedA.contains(normalizedB) ||
        normalizedB.contains(normalizedA)) {
      return 0.85;
    }

    final tokensA = normalizedA.split(' ').toSet();
    final tokensB = normalizedB.split(' ').toSet();
    final intersection = tokensA.intersection(tokensB).length;
    final union = tokensA.union(tokensB).length;

    if (union == 0) return 0;
    return intersection / union;
  }

  /// تطبيع: حروف صغيرة، شيل الحروف
  /// المشتركة في الأسماء (the, and...)،
  /// وحول الشرطات لمسافات.
  String _normalize(String input) {
    const stopWords = {
      'the', 'a', 'an', 'and', 'or', 'of', 'for', 'with', 'in', 'on',
      'el', 'wa', 'من', 'مع', 'لـ', 'في', 'على', 'ال', 'و',
    };

    return input
        .toLowerCase()
        .replaceAll(RegExp(r'[-_/]'), ' ')
        .split(RegExp(r'[^a-z0-9\u0600-\u06FF]+'))
        .where((token) => token.length > 2 && !stopWords.contains(token))
        .toSet()
        .join(' ');
  }
}
