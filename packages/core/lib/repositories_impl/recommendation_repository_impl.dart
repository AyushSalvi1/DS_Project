import '../datasources/analytics_remote_datasource.dart';
import '../datasources/recently_viewed_remote_datasource.dart';
import '../entities/privacy_settings_entity.dart';
import '../entities/product_entity.dart';
import '../entities/scored_product_entity.dart';
import '../entities/shopping_preferences_entity.dart';
import '../repositories/favourite_repository.dart';
import '../repositories/order_repository.dart';
import '../repositories/product_repository.dart';
import '../repositories/recommendation_repository.dart';
import '../utils/explainable_scoring_engine.dart';

/// تنفيذ محرك التوصية المتقدم مع
/// التفسير (Explainable AI recommendations).
///
/// بنجمع إشارات المستخدم (مشتريات،
/// مفضلة، مشاهدة، تقييمات التوصيات)
/// ونمررها لـ ExplainableScoringEngine
/// اللي بيدرج كل منتج مع عوامل
/// وأسباب مقروضة.
class RecommendationRepositoryImpl
    implements RecommendationRepository {
  final ProductRepository _productRepository;
  final OrderRepository _orderRepository;
  final FavouriteRepository _favouriteRepository;
  final RecentlyViewedRemoteDataSource _recentlyViewed;
  final AnalyticsRemoteDataSource _analytics;
  final PreferencesRepository _preferences;

  /// ذاكرة تقييمات التوصيات
  /// (productId -> liked) — تعلم
  /// محلي فوري قبل ما ينزل
  /// Firestore.
  final Map<String, bool> _feedbackMemory = {};

  RecommendationRepositoryImpl({
    ProductRepository? productRepository,
    OrderRepository? orderRepository,
    FavouriteRepository? favouriteRepository,
    RecentlyViewedRemoteDataSource? recentlyViewed,
    AnalyticsRemoteDataSource? analytics,
    PreferencesRepository? preferences,
  })  : _productRepository =
            productRepository ?? ProductRepositoryImpl(),
        _orderRepository =
            orderRepository ?? OrderRepositoryImpl(),
        _favouriteRepository =
            favouriteRepository ?? FavouriteRepositoryImpl(),
        _recentlyViewed =
            recentlyViewed ?? RecentlyViewedRemoteDataSource(),
        _analytics = analytics ?? AnalyticsRemoteDataSource(),
        _preferences = preferences ?? PreferencesRepositoryImpl();

  @override
  Future<List<ScoredProduct>> recommend({
    required String uid,
    required List<ProductEntity> catalog,
    ShoppingPreferencesEntity? preferences,
    PrivacySettingsEntity? privacy,
    int limit = 10,
  }) async {
    // بنجمع إشارات المستخدم —
    // لو فشل أي نداء بنكمل
    // بالباقي (مش بنكسر التوصية).
    List<String> purchased = [];
    List<String> favorites = [];
    List<String> viewed = [];

    try {
      final orders = await _orderRepository.getOrders(uid);
      purchased = orders
          .expand((o) => o.items.map((i) => i.productId))
          .toSet()
          .toList();
    } catch (_) {}

    try {
      favorites = await _favouriteRepository
          .watchFavoriteIds(uid)
          .first;
    } catch (_) {}

    try {
      viewed = await _recentlyViewed
          .watchRecentlyViewedIds(uid)
          .first;
    } catch (_) {}

    // تفضيلات المستخدم (لو مش
    // متمررة من الـ caller).
    ShoppingPreferencesEntity? effectivePrefs = preferences;
    if (effectivePrefs == null) {
      try {
        effectivePrefs =
            await _preferences.watchPreferences(uid).first;
      } catch (_) {}
    }

    // إعدادات الخصوصية (لو مش
    // متمررة).
    PrivacySettingsEntity? effectivePrivacy = privacy;
    if (effectivePrivacy == null) {
      try {
        effectivePrivacy =
            await _preferences.watchPrivacySettings(uid).first;
      } catch (_) {}
    }

    // تقييمات التوصيات السابقة
    // (تعلم من الفيدباك).
    final feedback = <String, bool>{..._feedbackMemory};
    try {
      final rows = await _analytics.getFeedback(uid);
      for (final row in rows) {
        feedback[row.productId] = row.liked;
      }
    } catch (_) {}

    // نستبعد المنتجات اللي المستخدم
    /// شافها/اشتراها/فضّلها أصلاً
    /// (إلا لو التخصيص مقفول).
    final excludeIds = <String>{};
    if (effectivePrivacy?.personalizationEnabled ?? true) {
      excludeIds.addAll(purchased);
      excludeIds.addAll(viewed);
    }

    return ExplainableScoringEngine.score(
      catalog: catalog,
      purchasedIds: purchased,
      favoriteIds: favorites,
      viewedIds: viewed,
      feedback: feedback,
      preferences: effectivePrefs,
      privacy: effectivePrivacy,
      excludeIds: excludeIds,
      limit: limit,
    );
  }

  @override
  Future<List<ScoredProduct>> similarTo(
    ProductEntity product, {
    required List<ProductEntity> catalog,
    int limit = 8,
  }) async {
    // بدائل "مشابه" مع درجة
    /// تفسيرية مبسّطة.
    final similar = catalog.where((p) {
      if (p.id == product.id) return false;
      if (p.categoryId == product.categoryId) return true;
      if (product.subcategoryId != null &&
          p.subcategoryId == product.subcategoryId) {
        return true;
      }
      return false;
    }).toList();

    similar.sort((a, b) {
      final ratingCompare = b.rating.compareTo(a.rating);
      if (ratingCompare != 0) return ratingCompare;
      return b.reviewCount.compareTo(a.reviewCount);
    });

    return similar.take(limit).map((p) {
      return ScoredProduct(
        product: p,
        score: (p.rating / 5 * 100).roundToDouble(),
        factors: [
          ScoreFactor(
            key: 'same_category',
            label: 'Same category',
            weight: 0.5,
            value:
                p.categoryId == product.categoryId ? 1.0 : 0.5,
            reason: p.categoryId == product.categoryId
                ? 'Same category as ${product.name}'
                : 'Related to ${product.name}',
          ),
          ScoreFactor(
            key: 'rating',
            label: 'Rating',
            weight: 0.5,
            value: (p.rating / 5).clamp(0.0, 1.0).toDouble(),
            reason: 'Rated ${p.rating.toStringAsFixed(1)}★ by ${p.reviewCount} buyers',
          ),
        ],
      );
    }).toList();
  }

  @override
  Future<void> recordFeedback({
    required String uid,
    required String productId,
    required bool liked,
  }) async {
    // ذاكرة محلية فورية (تعلم
    // سريع) + تسجيل دائم.
    _feedbackMemory[productId] = liked;

    try {
      await _analytics.recordFeedback(
        uid: uid,
        productId: productId,
        liked: liked,
      );
    } catch (_) {}
  }
}
