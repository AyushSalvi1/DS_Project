import '../entities/compatibility_entity.dart';
import '../entities/product_entity.dart';

/// محرك التوافق الحتمي — بيحدد المنتجات
/// اللي "بتكمل بعض" (عناصر متكاملة) بطريقتين:
///
/// 1. قواعد تكامل بين الكلمات (سرير ↔ مرتبة،
///    كنب ↔ طاولة قهوة، مصباح ↔ لمبة...).
/// 2. تحليل الشراء المشترك — المنتجات اللي
///    بيتشترىوا مع بعض أكتر من مرة في الطلبات.
class CompatibilityEngine {
  /// أزواج كلمات متكاملة (كل كلمة مع
  /// شريكتها في الصف التاني).
  static const _pairs = [
    ['bed', 'mattress'],
    ['bed', 'pillow'],
    ['bed', 'bedding'],
    ['sofa', 'coffee table'],
    ['sofa', 'cushion'],
    ['sofa', 'throw blanket'],
    ['table', 'chair'],
    ['desk', 'chair'],
    ['lamp', 'bulb'],
    ['lamp', 'shade'],
    ['shelf', 'book'],
    ['shelf', 'vase'],
    ['rug', 'floor lamp'],
    ['curtain', 'curtain rod'],
    ['mirror', 'frame'],
    ['plant', 'pot'],
    ['plant', 'planter'],
    ['wardrobe', 'hanger'],
    ['tv', 'tv stand'],
    ['dining table', 'dining chair'],
    ['mattress', 'bed frame'],
    ['blanket', 'throw'],
    ['cushion', 'pillow'],
    ['vase', 'flower'],
  ];

  /// مرادفات عربية مبسّطة للأزواج دي.
  static const _arabicPairs = [
    ['سرير', 'مرتبة'],
    ['سرير', 'وسادة'],
    ['كنب', 'طاولة'],
    ['كنب', 'مخدة'],
    ['كرسي', 'طاولة'],
    ['مصباح', 'لمبة'],
    ['رف', 'كتاب'],
    ['سجاد', 'مصباح'],
    ['ستارة', 'rail'],
    ['نبتة', 'صوبة'],
    ['نبات', 'صوبة'],
    ['مرآة', 'إطار'],
    ['مفرش', 'سرير'],
  ];

  /// يحسب التوافق بين منتج وكتالوج كامل.
  static List<CompatibilityEntity> compute({
    required ProductEntity product,
    required List<ProductEntity> catalog,
    required List<String> purchasedProductIds,
    int limit = 6,
  }) {
    final candidates = catalog.where((p) => p.id != product.id).toList();

    // 1) تحليل الشراء المشترك من المنتجات
    // اللي المستخدم اشتراها مع المنتج ده.
    final coPurchased = _coPurchaseScores(
      product,
      purchasedProductIds,
      catalog,
    );

    final scored = <CompatibilityEntity>[];
    for (final candidate in candidates) {
      final ruleScore = _ruleScore(product, candidate);
      final coScore = coPurchased[candidate.id] ?? 0.0;

      // ندمج: القواعد 60% + الشراء المشترك 40%.
      final combined = (ruleScore * 0.6 + coScore * 0.4);
      if (combined <= 0.01) continue;

      scored.add(CompatibilityEntity(
        productId: product.id,
        compatibleProductId: candidate.id,
        score: (combined * 100).roundToDouble(),
        reason: _buildReason(product, candidate, ruleScore, coScore),
      ));
    }

    scored.sort((a, b) => b.score.compareTo(a.score));
    return scored.take(limit).toList();
  }

  /// درجة قواعد التكامل بين منتجين (0-1).
  static double _ruleScore(ProductEntity a, ProductEntity b) {
    final textA = '${a.name} ${a.description}'.toLowerCase();
    final textB = '${b.name} ${b.description}'.toLowerCase();

    var score = 0.0;

    for (final pair in _pairs) {
      final first = pair[0];
      final second = pair[1];
      final aHasFirst = textA.contains(first);
      final aHasSecond = textA.contains(second);
      final bHasFirst = textB.contains(first);
      final bHasSecond = textB.contains(second);

      if ((aHasFirst && bHasSecond) || (aHasSecond && bHasFirst)) {
        score = score > 0.8 ? score : 0.8;
      }
    }

    for (final pair in _arabicPairs) {
      final first = pair[0];
      final second = pair[1];
      final aHasFirst = textA.contains(first);
      final aHasSecond = textA.contains(second);
      final bHasFirst = textB.contains(first);
      final bHasSecond = textB.contains(second);

      if ((aHasFirst && bHasSecond) || (aHasSecond && bHasFirst)) {
        score = score > 0.75 ? score : 0.75;
      }
    }

    // نفس الفئة بتخفض التوافق شوية (ده مش
    // "عنصر متكامل" ده بديل)، إلا لو فيه
    // كلمة تكامل صريحة.
    if (a.categoryId == b.categoryId && score < 0.5) {
      score *= 0.5;
    }

    return score.clamp(0.0, 1.0).toDouble();
  }

  /// درجات الشراء المشترك — بيبسطها
  /// من تاريخ الطلبات: كل منتج شُرى مع
  /// المنتج ده بياخد وزن.
  static Map<String, double> _coPurchaseScores(
    ProductEntity product,
    List<String> purchasedProductIds,
    List<ProductEntity> catalog,
  ) {
    // في التنفيذ الكامل، بنحلل كل الطلبات
    // (OrderRepository) عشان نحسب التكرار
    // الحقيقي. هنا بنستخدم إشارة مبسّطة:
    // المنتجات اللي المستخدم اشتراها في
    // نفس الفتره اللي شاف فيها المنتج ده.
    final result = <String, double>{};

    final productCategory = product.categoryId;
    for (final purchasedId in purchasedProductIds) {
      if (purchasedId == product.id) continue;
      final purchased = catalog.where((p) => p.id == purchasedId).toList();
      if (purchased.isEmpty) continue;

      // نفس الفئة = إشارة شراء مشترك ضعيفة.
      if (purchased.first.categoryId == productCategory) {
        result[purchasedId] = (result[purchasedId] ?? 0.0) + 0.3;
      }
    }

    // تطبيع
    final max = result.values.isEmpty
        ? 1.0
        : result.values.reduce((a, b) => a > b ? a : b);
    for (final key in result.keys) {
      result[key] = (result[key]! / max).clamp(0.0, 1.0).toDouble();
    }

    return result;
  }

  static String _buildReason(
    ProductEntity product,
    ProductEntity candidate,
    double ruleScore,
    double coScore,
  ) {
    if (coScore > ruleScore && coScore > 0.3) {
      return 'Frequently bought together';
    }
    if (ruleScore > 0.3) {
      return 'Complements your ${product.name}';
    }
    return 'Goes well with this item';
  }
}
