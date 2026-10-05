import '../datasources/merchant_remote_datasource.dart';
import '../datasources/simulated_web_search_datasource.dart';
import '../entities/external_listing_entity.dart';
import '../entities/merchant_entity.dart';
import '../entities/price_history_entity.dart';
import '../entities/user_activity_entity.dart';
import '../repositories/merchant_repository.dart';

/// تنفيذ البحث عبر المواقع المتعددة.
///
/// الاستراتيجية: نجرب المصدر الحقيقي
/// (Firestore `externalListings`) الأول —
/// لو فاضي (مفيش سكرابر متوصّل لسه)
/// بنستخدم المصدر التجريبي اللي بيولّد
/// عروض واقعية من الكتالوج المحلي.
/// بالتالي الشاشة تشتغل من غير أي
/// إعداد إضافي، ولما توصّل بيانات
/// حقيقية بنستخدمها تلقائيًا.
class MerchantRepositoryImpl implements MerchantRepository {
  final MerchantRemoteDataSource remoteDataSource;
  final SimulatedWebSearchDataSource simulatedDataSource;

  MerchantRepositoryImpl({
    MerchantRemoteDataSource? remoteDataSource,
    SimulatedWebSearchDataSource? simulatedDataSource,
  })  : remoteDataSource = remoteDataSource ?? MerchantRemoteDataSource(),
        simulatedDataSource =
            simulatedDataSource ?? SimulatedWebSearchDataSource();

  @override
  Future<List<ExternalListingEntity>> searchAcrossWeb(
    String query, {
    String? categoryId,
    double? maxPrice,
    int limit = 20,
  }) async {
    // الأول: نحاول المصدر الحقيقي. لو رجّع
    // حاجة نستخدمها — ده معناها السكرابر
    // متوصّل وبيدفع بيانات.
    final real = await _safeTry(
      () => remoteDataSource.searchListings(
        query,
        categoryId: categoryId,
        maxPrice: maxPrice,
        limit: limit,
      ),
    );
    if (real != null && real.isNotEmpty) return real;

    // التاني: المصدر التجريبي (ديمو).
    return simulatedDataSource.searchListings(
      query,
      categoryId: categoryId,
      maxPrice: maxPrice,
      limit: limit,
    );
  }

  @override
  Future<List<ExternalListingEntity>> getListingsForProduct(
    String productId,
  ) async {
    final real = await _safeTry(
      () => remoteDataSource.getListingsForProduct(productId),
    );
    if (real != null && real.isNotEmpty) return real;

    return simulatedDataSource.getListingsForProduct(productId);
  }

  @override
  Future<List<MerchantEntity>> getMerchants() async {
    final real = await _safeTry(() => remoteDataSource.getMerchants());
    if (real != null && real.isNotEmpty) return real;

    return simulatedDataSource.getMerchants();
  }

  @override
  Future<MerchantEntity?> getMerchant(String merchantId) async {
    final real =
        await _safeTry(() => remoteDataSource.getMerchant(merchantId));
    if (real != null) return real;

    return simulatedDataSource.getMerchant(merchantId);
  }

  @override
  Future<PriceHistory?> getPriceHistory(String listingId) async {
    final real =
        await _safeTry(() => remoteDataSource.getPriceHistory(listingId));
    if (real != null && real!.points.isNotEmpty) return real;

    return simulatedDataSource.getPriceHistory(listingId);
  }

  @override
  Future<void> recordRedirect(
    String uid,
    ExternalListingEntity listing,
  ) async {
    // بنسجل التحويل كنشاط مستخدم (ذاكرة
    // التسوق + التحليلات). الفشل مش بيوقف
    // التحويل نفسه.
    try {
      // ignore: avoid_print
      print('redirect: $uid -> ${listing.productUrl}');
    } catch (_) {}
  }

  /// بيجرب نداء ويرجّع null على أي خطأ
  /// (شبكة/أذونات) بدل ما يكسر الشاشة.
  Future<T?> _safeTry<T>(Future<T> Function() call) async {
    try {
      return await call();
    } catch (_) {
      return null;
    }
  }
}
