import '../entities/category_entity.dart';
import '../entities/external_listing_entity.dart';
import '../entities/merchant_entity.dart';
import '../entities/price_history_entity.dart';
import '../entities/product_entity.dart';
import 'merchant_remote_datasource.dart';
import 'product_remote_datasource.dart';

/// مصدر بيانات تجريبي للبحث عبر المواقع —
/// بيشتغل من غير أي إعداد إضافي: بيولّد
/// عروض تاجر خارجي واقعية من الكتالوج
/// المحلي (أسعار متفاوتة، شحن، توفر،
/// وتاريخ أسعار 90 يوم).
///
/// في الإنتاج: استبدله بـ MerchantRemoteDataSource
/// (Firestore) اللي بيغذيها سكرابر/Cloud
/// Function حقيقي. MerchantRepositoryImpl بيستخدم
/// الفوري ويسقط على ده لو مجموعة `externalListings`
/// فاضية.
class SimulatedWebSearchDataSource implements WebSearchDataSource {
  final MerchantRemoteDataSource _remote;

  SimulatedWebSearchDataSource({MerchantRemoteDataSource? remote})
      : _remote = remote ?? MerchantRemoteDataSource();

  /// التجار التجريبيون — بيحاكوا مواقع
  /// بيع متعددة بنفس المنتج بأسعار مختلفة.
  static const _demoMerchants = [
    MerchantEntity(
      id: 'merchant-homemart',
      name: 'HomeMart',
      domain: 'homemart.example',
      rating: 4.6,
      reviewCount: 12480,
      reliabilityScore: 92,
      returnPolicy: '30-day returns',
      shippingDaysMin: 3,
      shippingDaysMax: 5,
      isVerified: true,
    ),
    MerchantEntity(
      id: 'merchant-furniturehub',
      name: 'FurnitureHub',
      domain: 'furniturehub.example',
      rating: 4.3,
      reviewCount: 8310,
      reliabilityScore: 81,
      returnPolicy: '14-day returns',
      shippingDaysMin: 5,
      shippingDaysMax: 9,
      isVerified: true,
    ),
    MerchantEntity(
      id: 'merchant-decordirect',
      name: 'DecorDirect',
      domain: 'decordirect.example',
      rating: 4.1,
      reviewCount: 3120,
      reliabilityScore: 74,
      returnPolicy: '14-day returns',
      shippingDaysMin: 7,
      shippingDaysMax: 12,
      isVerified: false,
    ),
    MerchantEntity(
      id: 'merchant-stylebay',
      name: 'StyleBay',
      domain: 'stylebay.example',
      rating: 3.8,
      reviewCount: 940,
      reliabilityScore: 58,
      returnPolicy: '7-day returns',
      shippingDaysMin: 10,
      shippingDaysMax: 18,
      isVerified: false,
    ),
  ];

  @override
  Future<List<MerchantEntity>> getMerchants() async => _demoMerchants;

  @override
  Future<MerchantEntity?> getMerchant(String merchantId) async {
    for (final m in _demoMerchants) {
      if (m.id == merchantId) return m;
    }
    return null;
  }

  @override
  Future<List<ExternalListingEntity>> searchListings(
    String query, {
    String? categoryId,
    double? maxPrice,
    int limit = 20,
  }) async {
    final products = await _catalog();
    final tokens = query.toLowerCase().split(RegExp(r'\s+')).where((t) => t.isNotEmpty).toList();

    final listings = <ExternalListingEntity>[];
    for (final product in products) {
      if (categoryId != null &&
          categoryId.isNotEmpty &&
          product.categoryId != categoryId) {
        continue;
      }

      final productListings = _listingsForProduct(product);
      for (final listing in productListings) {
        if (maxPrice != null && listing.effectivePrice > maxPrice) continue;
        if (tokens.isNotEmpty) {
          final haystack =
              '${listing.title} ${listing.description}'.toLowerCase();
          final matches = tokens
              .where((token) => haystack.contains(token))
              .length;
          if (matches == 0) continue;
        }
        listings.add(listing);
      }
    }

    listings.sort((a, b) => a.effectivePrice.compareTo(b.effectivePrice));
    return listings.take(limit).toList();
  }

  @override
  Future<List<ExternalListingEntity>> getListingsForProduct(
    String productId,
  ) async {
    final products = await _catalog();
    for (final product in products) {
      if (product.id == productId) {
        return _listingsForProduct(product);
      }
    }
    return const [];
  }

  @override
  Future<PriceHistory?> getPriceHistory(String listingId) async {
    // نحاول المصدر الحقيقي الأول — لو فيه بيانات
    // حقيقية من سكرابر بنستخدمها.
    final remote = await _remote.getPriceHistory(listingId);
    if (remote != null && remote.points.isNotEmpty) return remote;

    // لو مش متوفر: نولّد تاريخ 90 يوم حتمي
    // (بذرة ثابتة من ID العرض) عشان الرسم
    // البياني والتنبيهات تشتغل في الديمو.
    for (final merchant in _demoMerchants) {
      final products = await _catalog();
      for (final product in products) {
        final id = _listingId(product.id, merchant.id);
        if (id != listingId) continue;
        return PriceHistory(
          listingId: listingId,
          points: _generateHistory(product.price, listingId),
        );
      }
    }
    return null;
  }

  List<ExternalListingEntity> _listingsForProduct(ProductEntity product) {
    final now = DateTime.now();
    final result = <ExternalListingEntity>[];

    for (var i = 0; i < _demoMerchants.length; i++) {
      final merchant = _demoMerchants[i];

      // تغير حتمي في السعر لكل تاجر (±5%..30%) —
      // بذرة ثابتة من (معرف المنتج + التاجر).
      final variance =
          0.92 + 0.38 * _seed('${product.id}:${merchant.id}');
      final price = (product.price * variance).roundToDouble();
      final hasDiscount = _seed('${product.id}:${merchant.id}:disc') > 0.6;

      result.add(ExternalListingEntity(
        id: _listingId(product.id, merchant.id),
        merchantId: merchant.id,
        productId: product.id,
        title: product.name,
        description: product.description,
        price: price,
        originalPrice: hasDiscount
            ? (price * (1.08 + 0.15 * _seed('${product.id}:orig')))
                .roundToDouble()
            : null,
        productUrl:
            'https://${merchant.domain}/p/${product.id}-${merchant.id.split('-').last}',
        imageUrl: product.thumbnail,
        availability: _seed('${product.id}:${merchant.id}:stock') > 0.15
            ? ListingAvailability.inStock
            : ListingAvailability.outOfStock,
        shippingCost: _seed('${product.id}:${merchant.id}:ship') > 0.4
            ? (4 + 12 * _seed('${product.id}:${merchant.id}:shipc'))
                .roundToDouble()
            : 0,
        deliveryDays: merchant.shippingDaysMin +
            (merchant.shippingDaysMax - merchant.shippingDaysMin) ~/ 2,
        rating: product.rating,
        reviewCount: product.reviewCount,
        lastSeenAt: now,
      ));
    }

    return result;
  }

  String _listingId(String productId, String merchantId) =>
      'listing-$productId-${merchantId.split('-').last}';

  /// دالة بذرة حتمية (0..1) من نص — عشان
  /// النتايج التجريبية تفضل ثابتة كل مرة.
  double _seed(String input) {
    var hash = 0;
    for (var i = 0; i < input.length; i++) {
      hash = (hash * 31 + input.codeUnitAt(i)) & 0xFFFFFFFF;
    }
    return (hash % 10000) / 10000;
  }

  List<PricePoint> _generateHistory(double basePrice, String seedKey) {
    final points = <PricePoint>[];
    final now = DateTime.now();
    var price = basePrice * (0.95 + 0.1 * _seed('$seedKey:start'));

    for (var i = 90; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      // مشي عشوائي حتمي بسيط حول السعر الحالي.
      price = price +
          basePrice * (0.015) * (_seed('$seedKey:$i') - 0.48);
      price = price.clamp(basePrice * 0.7, basePrice * 1.35).toDouble();
      points.add(PricePoint(date: date, price: price.roundToDouble()));
    }

    return points;
  }

  Future<List<ProductEntity>> _catalog() async {
    // نستورد الكتالوج من Firestore عبر الـ
    // ProductRemoteDataSource (نفس مصدر الحقيقة).
    final docs = await ProductRemoteDataSource().getProducts();
    return docs
        .map((doc) => ProductEntity.fromJson(doc.id, doc.data()))
        .toList();
  }
}
