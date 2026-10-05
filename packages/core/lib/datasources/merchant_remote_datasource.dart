import 'package:cloud_firestore/cloud_firestore.dart';

import '../entities/external_listing_entity.dart';
import '../entities/merchant_entity.dart';
import '../entities/price_history_entity.dart';

/// مصدر البيانات الحقيقي للبحث عبر المواقع —
/// بيسحب التجار والعروض الخارجية من Firestore
/// (في الإنتاج بيغذيها سكرابر/Cloud Function
/// بيتزامن مع مواقع التجار).
class MerchantRemoteDataSource {
  final FirebaseFirestore firestore;

  MerchantRemoteDataSource({FirebaseFirestore? firestore})
      : firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _merchants =>
      firestore.collection('merchants');

  /// العروض الخارجية — مجموعة جذرية لأنها
  /// مش مملوكة لمستخدم معين.
  CollectionReference<Map<String, dynamic>> get _listings =>
      firestore.collection('externalListings');

  Future<List<MerchantEntity>> getMerchants() async {
    final snapshot = await _merchants.get();
    return snapshot.docs
        .map((doc) => MerchantEntity.fromJson(doc.id, doc.data()))
        .toList();
  }

  Future<MerchantEntity?> getMerchant(String merchantId) async {
    final doc = await _merchants.doc(merchantId).get();
    if (!doc.exists || doc.data() == null) return null;
    return MerchantEntity.fromJson(doc.id, doc.data()!);
  }

  Future<List<ExternalListingEntity>> searchListings(
    String query, {
    String? categoryId,
    double? maxPrice,
    int limit = 20,
  }) async {
    Query<Map<String, dynamic>> queryRef = _listings;

    if (maxPrice != null) {
      queryRef = queryRef.where('price', isLessThanOrEqualTo: maxPrice);
    }

    // ملاحظة: Firestore مش بيدعم بحث نصي كامل، فبنجيب
    // مجموعة معقولة ونفلتر/نرتب محليًا بالكلمات المفتاحية.
    queryRef = queryRef.limit(limit * 3);

    final snapshot = await queryRef.get();
    var listings = snapshot.docs
        .map((doc) => ExternalListingEntity.fromJson(doc.id, doc.data()))
        .toList();

    if (query.trim().isNotEmpty) {
      final tokens = query.toLowerCase().split(RegExp(r'\s+'));
      listings.sort((a, b) {
        final scoreA = _relevance(a.title, a.description, tokens);
        final scoreB = _relevance(b.title, b.description, tokens);
        return scoreB.compareTo(scoreA);
      });
      listings = listings.where((l) {
        final score = _relevance(l.title, l.description, tokens);
        return score > 0;
      }).toList();
    } else {
      listings.sort((a, b) => a.effectivePrice.compareTo(b.effectivePrice));
    }

    if (categoryId != null && categoryId.isNotEmpty) {
      listings = listings
          .where((l) => l.productId == null || true)
          .toList();
    }

    return listings.take(limit).toList();
  }

  double _relevance(String title, String description, List<String> tokens) {
    final haystack = '$title $description'.toLowerCase();
    var score = 0.0;
    for (final token in tokens) {
      if (token.isEmpty) continue;
      if (haystack.contains(token)) {
        score += title.toLowerCase().contains(token) ? 2.0 : 1.0;
      }
    }
    return score;
  }

  Future<List<ExternalListingEntity>> getListingsForProduct(
    String productId,
  ) async {
    final snapshot = await _listings
        .where('productId', isEqualTo: productId)
        .get();
    return snapshot.docs
        .map((doc) => ExternalListingEntity.fromJson(doc.id, doc.data()))
        .toList();
  }

  Future<PriceHistory?> getPriceHistory(String listingId) async {
    final snapshot = await _listings
        .doc(listingId)
        .collection('priceHistory')
        .orderBy('date')
        .limit(365)
        .get();

    if (snapshot.docs.isEmpty) return null;

    return PriceHistory(
      listingId: listingId,
      points: snapshot.docs
          .map((doc) => PricePoint.fromJson(doc.data()))
          .toList(),
    );
  }

  Future<void> recordPricePoint(String listingId, double price) {
    final now = DateTime.now();
    final dayKey = '${now.year}-${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
    return _listings.doc(listingId).collection('priceHistory').doc(dayKey).set({
      'date': DateTime(now.year, now.month, now.day)
          .toIso8601String(),
      'price': price,
    });
  }
}
