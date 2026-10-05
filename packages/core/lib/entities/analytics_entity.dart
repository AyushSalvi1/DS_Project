import 'package:equatable/equatable.dart';

/// اهتمام المستخدم بفئة معينة — عدد التفاعلات
/// ودرجة مجمّعة (للتحليلات والتوصية).
class CategoryInterest extends Equatable {
  final String categoryId;
  final int interactions;
  final double score;

  const CategoryInterest({
    required this.categoryId,
    required this.interactions,
    required this.score,
  });

  @override
  List<Object?> get props => [categoryId, interactions, score];
}

/// لقطة تحليلات المستخدم — نشاطه وتحويلاته
/// ووفورات السعر اللي حققها.
class UserAnalytics extends Equatable {
  final int totalSearches;
  final int totalViews;
  final int totalComparisons;
  final int totalPurchases;
  final int totalRedirects;
  final int priceAlertsTriggered;

  /// إجمالي الوفورات بالعملة (من انخفاضات السعر اللي اتنبّه عليها).
  final double totalSavings;
  final List<CategoryInterest> topCategories;

  /// نشاط آخر 7 أيام (index 0 = الأقدم).
  final List<int> activityByDay;

  const UserAnalytics({
    this.totalSearches = 0,
    this.totalViews = 0,
    this.totalComparisons = 0,
    this.totalPurchases = 0,
    this.totalRedirects = 0,
    this.priceAlertsTriggered = 0,
    this.totalSavings = 0,
    this.topCategories = const [],
    this.activityByDay = const [],
  });

  int get totalActivity =>
      totalSearches + totalViews + totalComparisons + totalPurchases;

  @override
  List<Object?> get props => [
        totalSearches,
        totalViews,
        totalComparisons,
        totalPurchases,
        totalRedirects,
        priceAlertsTriggered,
        totalSavings,
        topCategories,
        activityByDay,
      ];
}

/// تحليلات أداء التوصيات — اتقبلت إيه واترفضت إيه.
class RecommendationAnalytics extends Equatable {
  final int shown;
  final int clicked;
  final int purchased;
  final int feedbackPositive;
  final int feedbackNegative;

  const RecommendationAnalytics({
    this.shown = 0,
    this.clicked = 0,
    this.purchased = 0,
    this.feedbackPositive = 0,
    this.feedbackNegative = 0,
  });

  double get clickThroughRate => shown == 0 ? 0 : clicked / shown;
  double get acceptanceRate => shown == 0 ? 0 : purchased / shown;
  double get positiveFeedbackRate =>
      (feedbackPositive + feedbackNegative) == 0
          ? 0
          : feedbackPositive / (feedbackPositive + feedbackNegative);

  @override
  List<Object?> get props =>
      [shown, clicked, purchased, feedbackPositive, feedbackNegative];
}
