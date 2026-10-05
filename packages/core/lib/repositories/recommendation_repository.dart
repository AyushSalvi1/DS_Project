import '../entities/privacy_settings_entity.dart';
import '../entities/product_entity.dart';
import '../entities/scored_product_entity.dart';
import '../entities/shopping_preferences_entity.dart';

/// عقد محرك التوصية المتقدم مع التفسير
/// (Explainable AI) — كل توصية بتيجي مع
/// درجتها وأسباب مقروضة.
abstract class RecommendationRepository {
  /// يرشح منتجات للمستخدم مع درجات تفسيرية
  /// (عوامل + أسباب مقروضة لكل منتج).
  Future<List<ScoredProduct>> recommend({
    required String uid,
    required List<ProductEntity> catalog,
    ShoppingPreferencesEntity? preferences,
    PrivacySettingsEntity? privacy,
    int limit = 10,
  });

  /// يرشح منتجات مشابهة لمنتج معين (لـ
  /// "لأنك شفت ده").
  Future<List<ScoredProduct>> similarTo(
    ProductEntity product, {
    required List<ProductEntity> catalog,
    int limit = 8,
  });

  /// يسجل تقييم المستخدم لتوصية (يعزز/يخمد
  /// الفئات والكلمات المرتبطة في المحرك).
  Future<void> recordFeedback({
    required String uid,
    required String productId,
    required bool liked,
  });
}
