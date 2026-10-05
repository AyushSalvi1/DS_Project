import '../entities/privacy_settings_entity.dart';
import '../entities/product_entity.dart';
import '../entities/scored_product_entity.dart';
import '../entities/shopping_preferences_entity.dart';

/// محرك التسجيل التفسيري (Explainable AI Scoring) —
/// يرشح المنتجات ويعطي كل منتج درجة (0-100)
/// مع تفصيل العوامل وأسباب مقروضة.
///
/// محرك حتمي 100% (من غير أي نداء شبكة) عشان
/// يفضل فوري ويشتغل أوفلاين، ونفس العوامل
/// دي اللي بنرسلها للذكاء الاصطناعي لما
/// بنحب نولّد أسباب بلغة طبيعية.
///
/// العوامل:
/// 1. اهتمام الفئة (من المشتريات/المفضلة/المشاهدة)
/// 2. مطابقة التفضيلات (فئات/ألوان/أسلوب/ميزانية)
/// 3. ملاءمة السعر (نطاق الميزانية + تفضيل value/premium)
/// 4. الجودة (التقييم + عدد المراجعات)
/// 5. الشعبية (المبيعات الفعلية)
/// 6. التقييمات الصريحة (إعجاب/عدم إعجاب سابق)
class ExplainableScoringEngine {
  /// أوزان العوامل — مجموعهم 1.
  static const _wCategory = 0.28;
  static const _wPreference = 0.20;
  static const _wPrice = 0.18;
  static const _wQuality = 0.16;
  static const _wPopularity = 0.10;
  static const _wFeedback = 0.08;

  /// يرشح ويسجل المنتجات.
  ///
  /// [signals] إشارات المستخدم: مشتريات، مفضلة، مشاهدة.
  /// [feedback] تقييمات صريحة: productId -> liked.
  static List<ScoredProduct> score({
    required List<ProductEntity> catalog,
    required List<String> purchasedIds,
    required List<String> favoriteIds,
    required List<String> viewedIds,
    Map<String, bool> feedback = const {},
    ShoppingPreferencesEntity? preferences,
    PrivacySettingsEntity? privacy,
    Set<String> excludeIds = const {},
    int limit = 10,
  }) {
    // لو التخصيص مقفول من إعدادات الخصوصية:
    /// نتجاهل كل الإشارات الشخصية ونرجع
    /// الأعلى تقييمًا في الكتالوج (نظام عام).
    final personalized =
        privacy?.personalizationEnabled ?? true;

    final productsById = {for (final p in catalog) p.id: p};

    // أوزان اهتمام الفئة من الإشارات التاريخية.
    final categoryInterest = <String, double>{};
    if (personalized) {
      void addWeight(Iterable<String> ids, double weight) {
        for (final id in ids) {
          final categoryId = productsById[id]?.categoryId;
          if (categoryId == null) continue;
          categoryInterest[categoryId] =
              (categoryInterest[categoryId] ?? 0.0) + weight;
        }
      }

      addWeight(purchasedIds, 3.0);
      addWeight(favoriteIds, 2.0);
      addWeight(viewedIds, 1.0);
    }

    final maxInterest = categoryInterest.values.isEmpty
        ? 1.0
        : categoryInterest.values.reduce(
            (a, b) => a > b ? a : b,
          );

    final prefCats = (preferences?.preferredCategoryIds ?? const []).toSet();
    final prefColors = (preferences?.preferredColors ?? const []).toSet();
    final prefStyles = (preferences?.styleKeywords ?? const [])
        .map((s) => s.toLowerCase())
        .toSet();
    final budgetMin = preferences?.budgetMin;
    final budgetMax = preferences?.budgetMax;
    final priceWeight = preferences?.priceWeight ?? 0.25;
    final qualityWeight = preferences?.qualityWeight ?? 0.75;

    final candidates = catalog
        .where((p) => !excludeIds.contains(p.id))
        .toList();

    final scored = <ScoredProduct>[];
    final medianPrice = _medianPrice(catalog);
    for (final product in candidates) {
      final factors = <ScoreFactor>[];

      // 1) اهتمام الفئة
      final interest = personalized
          ? (categoryInterest[product.categoryId] ?? 0.0) / maxInterest
          : 0.0;
      factors.add(ScoreFactor(
        key: 'category_interest',
        label: 'Category interest',
        weight: _wCategory,
        value: interest,
        reason: interest > 0.05
            ? 'Matches your interest in this category'
            : 'New category for you to explore',
      ));

      // 2) مطابقة التفضيلات
      var prefScore = 0.0;
      final reasons = <String>[];
      if (prefCats.isNotEmpty && prefCats.contains(product.categoryId)) {
        prefScore += 0.5;
        reasons.add('In your preferred categories');
      }
      if (prefColors.isNotEmpty &&
          product.color != null &&
          prefColors.contains(product.color)) {
        prefScore += 0.25;
        reasons.add('Available in your preferred color');
      }
      if (prefStyles.isNotEmpty) {
        final haystack =
            '${product.name} ${product.description}'.toLowerCase();
        final matched = prefStyles
            .where((style) => haystack.contains(style))
            .toList();
        if (matched.isNotEmpty) {
          prefScore += 0.25;
          reasons.add('Fits your "${matched.first}" style');
        }
      }
      prefScore = prefScore.clamp(0.0, 1.0).toDouble();
      factors.add(ScoreFactor(
        key: 'preference_match',
        label: 'Preference match',
        weight: _wPreference,
        value: personalized ? prefScore : 0.0,
        reason: reasons.isEmpty
            ? 'General catalog match'
            : reasons.join(' • '),
      ));

      // 3) ملاءمة السعر
      var priceScore = 0.5;
      String priceReason = 'Priced in the mid range';
      if (budgetMax != null && product.price > budgetMax) {
        priceScore = 0.15;
        priceReason = 'Above your budget';
      } else if (budgetMin != null && product.price < budgetMin) {
        priceScore = 0.35;
        priceReason = 'Below your usual range';
      } else if (budgetMax != null && budgetMin != null) {
        final range = budgetMax - budgetMin;
        if (range > 0) {
          final position =
              (product.price - budgetMin) / range;
          // value = بيحب الأدنى، premium = بيحب الأعلى.
          priceScore = priceWeight > 0.25
              ? 1.0 - (position * 0.6)
              : 0.4 + (position * 0.6);
          priceScore = priceScore.clamp(0.1, 1.0).toDouble();
        }
        priceReason = 'Within your budget range';
      } else if (product.price < medianPrice * 0.7) {
        priceScore = 0.85;
        priceReason = 'Great value for the price';
      }
      factors.add(ScoreFactor(
        key: 'price_fit',
        label: 'Price fit',
        weight: _wPrice,
        value: priceScore,
        reason: priceReason,
      ));

      // 4) الجودة (تقييم + عدد المراجعات)
      final ratingScore =
          (product.rating / 5).clamp(0.0, 1.0).toDouble();
      final reviewScore =
          (product.reviewCount / 100).clamp(0.0, 1.0).toDouble();
      final qualityScore = (ratingScore * qualityWeight +
              reviewScore * (1 - qualityWeight))
          .clamp(0.0, 1.0)
          .toDouble();
      factors.add(ScoreFactor(
        key: 'quality',
        label: 'Quality signals',
        weight: _wQuality,
        value: qualityScore,
        reason: product.reviewCount > 0
            ? 'Rated ${product.rating.toStringAsFixed(1)}★ by ${product.reviewCount} buyers'
            : 'No reviews yet — new arrival',
      ));

      // 5) الشعبية
      final popularityScore =
          (product.salesCount / 50).clamp(0.0, 1.0).toDouble();
      factors.add(ScoreFactor(
        key: 'popularity',
        label: 'Popularity',
        weight: _wPopularity,
        value: popularityScore,
        reason: product.salesCount > 10
            ? 'Bestseller — ${product.salesCount} sold'
            : 'Quiet seller',
      ));

      // 6) التقييمات الصريحة (تعلم من الفيدباك)
      final feedbackValue = feedback[product.id] == true
          ? 1.0
          : (feedback[product.id] == false ? 0.0 : 0.5);
      factors.add(ScoreFactor(
        key: 'feedback',
        label: 'Your feedback',
        weight: _wFeedback,
        value: personalized ? feedbackValue : 0.5,
        reason: feedback[product.id] == true
            ? 'You liked similar picks before'
            : 'Not rated by you yet',
      ));

      final total = factors.fold(
        0.0,
        (sum, f) => sum + f.contribution,
      );

      scored.add(ScoredProduct(
        product: product,
        score: (total * 100).roundToDouble(),
        factors: factors,
      ));
    }

    scored.sort((a, b) {
      final scoreCompare = b.score.compareTo(a.score);
      if (scoreCompare != 0) return scoreCompare;
      return b.product.rating.compareTo(a.product.rating);
    });

    return scored.take(limit).toList();
  }

  static double _medianPrice(List<ProductEntity> products) {
    if (products.isEmpty) return 0;
    final prices = products.map((p) => p.price).toList()
      ..sort();
    final mid = prices.length ~/ 2;
    if (prices.length.isEven) {
      return (prices[mid - 1] + prices[mid]) / 2;
    }
    return prices[mid];
  }
}
