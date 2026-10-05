import '../entities/analytics_entity.dart';

/// عقد تحليلات المستخدم والتوصيات.
abstract class AnalyticsRepository {
  /// تحليلات نشاط المستخدم (بحث/مشاهدة/مقارنة/شراء/
  /// تحويل/تنبيهات/وفورات).
  Future<UserAnalytics> getUserAnalytics(String uid);

  /// تحليلات أداء التوصيات (ظهور/نقر/شراء/تقييم).
  Future<RecommendationAnalytics> getRecommendationAnalytics(
    String uid,
  );

  /// يسجل تقييم المستخدم لتوصية (إعجاب/عدم إعجاب) —
  /// الوقود بتاع "تعلم الـ AI" من التقييم.
  Future<void> recordRecommendationFeedback({
    required String uid,
    required String productId,
    required bool liked,
    String context = 'home',
  });

  /// تقييمات المستخدم الأخيرة (لو محتاج تعرضها).
  Stream<List<RecommendationFeedbackEntity>> watchFeedback(
    String uid, {
    int limit = 50,
  });

  /// يسجل حدث عرض توصية (لحساب نسبة القبول).
  Future<void> recordRecommendationImpression(
    String uid,
    List<String> productIds,
  );
}

/// تقييم مستخدم لتوصية معينة.
class RecommendationFeedbackEntity {
  final String id;
  final String uid;
  final String productId;
  final bool liked;
  final String context;
  final DateTime timestamp;

  const RecommendationFeedbackEntity({
    required this.id,
    required this.uid,
    required this.productId,
    required this.liked,
    this.context = 'home',
    required this.timestamp,
  });
}
