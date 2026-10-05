import '../entities/external_listing_entity.dart';
import '../entities/merchant_entity.dart';
import '../entities/price_history_entity.dart';

/// عقد البحث عبر المواقع المتعددة ومقارنة الأسعار.
///
/// التنفيذ الافتراضي بيجيب البيانات من Firestore (المجموعة
/// `externalListings` اللي بيغذيها سكرابر/Cloud Function في
/// الإنتاج)، ولو فاضية بي fall back لمصدر تجريبي مبني من
/// الكتالوج المحلي عشان الشاشة تشتغل من غير إعداد إضافي.
/// عشان تربط API حقيقي (SerpAPI/Google Shopping/سكرابر خاص)،
/// نفّذ الواجهة ده وحقنها في MerchantRepositoryImpl.
abstract class WebSearchDataSource {
  /// يبحث في عروض المواقع الخارجية بسؤال نصي.
  Future<List<ExternalListingEntity>> searchListings(
    String query, {
    String? categoryId,
    double? maxPrice,
    int limit,
  });

  /// كل عروض موقع خارجي لمنتج محلي معين (عبر كشف التكرار).
  Future<List<ExternalListingEntity>> getListingsForProduct(
    String productId,
  );

  /// التجار المتاحين مع بيانات الموثوقية.
  Future<List<MerchantEntity>> getMerchants();

  /// تاجر واحد بالـ ID.
  Future<MerchantEntity?> getMerchant(String merchantId);

  /// تاريخ أسعار عرض معين.
  Future<PriceHistory?> getPriceHistory(String listingId);
}

abstract class MerchantRepository {
  /// البحث عبر المواقع — الخطوة الأساسية في رحلة
  /// "اسأل الـ AI → ابحث في النت".
  Future<List<ExternalListingEntity>> searchAcrossWeb(
    String query, {
    String? categoryId,
    double? maxPrice,
    int limit = 20,
  });

  /// كل عروض المواقع لمنتج محلي (مقارنة الأسعار
  /// في صفحة تفاصيل المنتج).
  Future<List<ExternalListingEntity>> getListingsForProduct(
    String productId,
  );

  Future<List<MerchantEntity>> getMerchants();
  Future<MerchantEntity?> getMerchant(String merchantId);

  /// تاريخ أسعار عرض معين (للرسم البياني).
  Future<PriceHistory?> getPriceHistory(String listingId);

  /// سجل التحويل للموقع الخارجي (تحليلات + ذاكرة المستخدم).
  Future<void> recordRedirect(String uid, ExternalListingEntity listing);
}
