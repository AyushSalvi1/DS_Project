import '../datasources/activity_remote_datasource.dart';
import '../datasources/analytics_remote_datasource.dart';
import '../datasources/order_remote_datasource.dart';
import '../entities/analytics_entity.dart';
import '../repositories/analytics_repository.dart';

/// تنفيذ تحليلات المستخدم والتوصيات.
class AnalyticsRepositoryImpl implements AnalyticsRepository {
  final AnalyticsRemoteDataSource _analytics;
  final ActivityRemoteDataSource _activity;
  final OrderRemoteDataSource _orders;

  AnalyticsRepositoryImpl({
    AnalyticsRemoteDataSource? analytics,
    ActivityRemoteDataSource? activity,
    OrderRemoteDataSource? orders,
  })  : _analytics = analytics ?? AnalyticsRemoteDataSource(),
        _activity = activity ?? ActivityRemoteDataSource(),
        _orders = orders ?? OrderRemoteDataSource();

  @override
  Future<UserAnalytics> getUserAnalytics(String uid) async {
    // بنجمع النشاط الكامل للمستخدم.
    final activities = await _activity.getActivity(uid, limit: 1000);

    var searches = 0;
    var views = 0;
    var comparisons = 0;
    var purchases = 0;
    var redirects = 0;

    final categoryCounts = <String, int>{};
    final dayCounts = <DateTime, int>{};

    for (final activity in activities) {
      switch (activity.type) {
        case ActivityType.search:
          searches++;
          break;
        case ActivityType.view:
          views++;
          break;
        case ActivityType.compare:
          comparisons++;
          break;
        case ActivityType.purchase:
          purchases++;
          break;
        case ActivityType.redirect:
          redirects++;
          break;
        case ActivityType.wishlist:
        case ActivityType.ask:
          break;
      }

      // اهتمامات الفئات (من المشاهدة
      // والشراء).
      final productId = activity.productId;
      if (productId != null &&
          (activity.type == ActivityType.view ||
              activity.type == ActivityType.purchase)) {
        // بنخزّن عداد بسيط — الفئة
        // بتتحدد من الـ product في
        // الـ UI layer (أو من الكتالوج).
        categoryCounts[productId] =
            (categoryCounts[productId] ?? 0) + 1;
      }

      // نشاط يومي (آخر 7 أيام).
      final day = DateTime(
        activity.timestamp.year,
        activity.timestamp.month,
        activity.timestamp.day,
      );
      dayCounts[day] = (dayCounts[day] ?? 0) + 1;
    }

    // الطلبات الفعلية = مشتريات حقيقية.
    try {
      final orders = await _orders.getOrders(uid);
      purchases += orders.length;
    } catch (_) {}

    // نشاط آخر 7 أيام (مرتب).
    final now = DateTime.now();
    final activityByDay = <int>[];
    for (var i = 6; i >= 0; i--) {
      final day = DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(Duration(days: i));
      activityByDay.add(dayCounts[day] ?? 0);
    }

    // اهتمامات الفئات الأعلى.
    final topCategories = categoryCounts.entries
        .map(
          (e) => CategoryInterest(
            categoryId: e.key,
            interactions: e.value,
            score: e.value.toDouble(),
          ),
        )
        .toList()
      ..sort((a, b) => b.interactions.compareTo(a.interactions));

    return UserAnalytics(
      totalSearches: searches,
      totalViews: views,
      totalComparisons: comparisons,
      totalPurchases: purchases,
      totalRedirects: redirects,
      topCategories: topCategories.take(5).toList(),
      activityByDay: activityByDay,
    );
  }

  @override
  Future<RecommendationAnalytics> getRecommendationAnalytics(
    String uid,
  ) async {
    final feedback = await _analytics.getFeedback(uid);
    final impressions = await _analytics.totalImpressions(uid);

    var positive = 0;
    var negative = 0;
    var clicked = 0;

    for (final row in feedback) {
      if (row.liked) {
        positive++;
        clicked++;
      } else {
        negative++;
      }
    }

    return RecommendationAnalytics(
      shown: impressions,
      clicked: clicked,
      purchased: positive, // تقدير: الإعجاب ≈ القبول
      feedbackPositive: positive,
      feedbackNegative: negative,
    );
  }

  @override
  Future<void> recordRecommendationFeedback({
    required String uid,
    required String productId,
    required bool liked,
    String context = 'home',
  }) {
    return _analytics.recordFeedback(
      uid: uid,
      productId: productId,
      liked: liked,
      context: context,
    );
  }

  @override
  Stream<List<RecommendationFeedbackEntity>> watchFeedback(
    String uid, {
    int limit = 50,
  }) {
    return _analytics.watchFeedback(uid).map(
      (rows) => rows
          .map(
            (row) => RecommendationFeedbackEntity(
              id: row.id,
              uid: uid,
              productId: row.productId,
              liked: row.liked,
              context: row.context,
              timestamp: DateTime.now(),
            ),
          )
          .toList(),
    );
  }

  @override
  Future<void> recordRecommendationImpression(
    String uid,
    List<String> productIds,
  ) {
    if (productIds.isEmpty) return Future.value();
    return _analytics.recordImpression(uid, productIds);
  }
}
