import 'package:equatable/equatable.dart';

/// حالة توفر المنتج في موقع تاجر خارجي.
enum ListingAvailability { inStock, outOfStock, preOrder, unknown }

/// عرض منتج على موقع تاجر خارجي — الأساس بتاع "البحث في
/// المواقع المتعددة" ومقارنة الأسعار وتحويل المستخدم
/// للموقع الأفضل (redirect).
class ExternalListingEntity extends Equatable {
  final String id;
  final String merchantId;

  /// ID المنتج المحلي اللي طابقه لو موجود (عبر كشف التكرار)،
  /// أو null لو ده عرض مستقل من نتايج البحث.
  final String? productId;
  final String title;
  final String description;
  final double price;
  final double? originalPrice;
  final String currency;

  /// الرابط المباشر لصفحة المنتج عند التاجر — ده اللي
  /// بنفتحه في المتصفح لما المستخدم يدوس "زيارة المتجر".
  final String productUrl;
  final String? imageUrl;
  final ListingAvailability availability;
  final double? shippingCost;
  final int? deliveryDays;
  final double rating;
  final int reviewCount;
  final DateTime lastSeenAt;

  const ExternalListingEntity({
    required this.id,
    required this.merchantId,
    this.productId,
    required this.title,
    this.description = '',
    required this.price,
    this.originalPrice,
    this.currency = 'USD',
    required this.productUrl,
    this.imageUrl,
    this.availability = ListingAvailability.unknown,
    this.shippingCost,
    this.deliveryDays,
    this.rating = 0,
    this.reviewCount = 0,
    required this.lastSeenAt,
  });

  /// السعر الفعلي للمستخدم (السعر + الشحن لو معروف).
  double get effectivePrice => price + (shippingCost ?? 0);

  /// نسبة الخصم مقابل السعر الأصلي (0-1)، أو null لو مش متوفر.
  double get discountFraction {
    final original = originalPrice;
    if (original == null || original <= 0 || price >= original) return null;
    return (original - price) / original;
  }

  bool get isInStock => availability == ListingAvailability.inStock;

  factory ExternalListingEntity.fromJson(String id, Map<String, dynamic> json) {
    return ExternalListingEntity(
      id: id,
      merchantId: json['merchantId'] as String? ?? '',
      productId: json['productId'] as String?,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      originalPrice: (json['originalPrice'] as num?)?.toDouble(),
      currency: json['currency'] as String? ?? 'USD',
      productUrl: json['productUrl'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
      availability: ListingAvailability.values.firstWhere(
        (e) => e.name == json['availability'],
        orElse: () => ListingAvailability.unknown,
      ),
      shippingCost: (json['shippingCost'] as num?)?.toDouble(),
      deliveryDays: (json['deliveryDays'] as num?)?.toInt(),
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
      lastSeenAt: DateTime.tryParse(json['lastSeenAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'merchantId': merchantId,
        'productId': productId,
        'title': title,
        'description': description,
        'price': price,
        'originalPrice': originalPrice,
        'currency': currency,
        'productUrl': productUrl,
        'imageUrl': imageUrl,
        'availability': availability.name,
        'shippingCost': shippingCost,
        'deliveryDays': deliveryDays,
        'rating': rating,
        'reviewCount': reviewCount,
        'lastSeenAt': lastSeenAt.toIso8601String(),
      };

  @override
  List<Object?> get props => [
        id,
        merchantId,
        productId,
        title,
        description,
        price,
        originalPrice,
        currency,
        productUrl,
        imageUrl,
        availability,
        shippingCost,
        deliveryDays,
        rating,
        reviewCount,
        lastSeenAt,
      ];
}
