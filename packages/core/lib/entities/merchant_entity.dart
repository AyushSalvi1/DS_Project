import 'package:equatable/equatable.dart';

/// تاجر/بائع خارجي — موقع أو متجر تاني بيبيع منتجات مش بتاعتنا.
/// بيستخدم في مقارنة الأسعار عبر المواقع وتحويل المستخدم للموقع الأفضل.
class MerchantEntity extends Equatable {
  final String id;
  final String name;
  final String domain;
  final String? logoUrl;

  /// تقييم التاجر (0-5) من تقييمات المستخدمين.
  final double rating;
  final int reviewCount;

  /// درجة الموثوقية المحسوبة (0-100) — بتتجمع من التقييم وعدد
  /// المراجعات وسياسات الإرجاع وسرعة الشحن ونسبة التواجد في المخزون.
  final double reliabilityScore;
  final String? returnPolicy;
  final int shippingDaysMin;
  final int shippingDaysMax;
  final bool isVerified;

  const MerchantEntity({
    required this.id,
    required this.name,
    required this.domain,
    this.logoUrl,
    this.rating = 0,
    this.reviewCount = 0,
    this.reliabilityScore = 0,
    this.returnPolicy,
    this.shippingDaysMin = 0,
    this.shippingDaysMax = 0,
    this.isVerified = false,
  });

  String get shippingEstimate =>
      shippingDaysMin == shippingDaysMax
          ? '$shippingDaysMin days'
          : '$shippingDaysMin-$shippingDaysMax days';

  /// تصنيف نصي مبسّط لدرجة الموثوقية عشان يظهر في الـ UI.
  String reliabilityLabel(String excellent, String good, String average) {
    if (reliabilityScore >= 85) return excellent;
    if (reliabilityScore >= 65) return good;
    return average;
  }

  factory MerchantEntity.fromJson(String id, Map<String, dynamic> json) {
    return MerchantEntity(
      id: id,
      name: json['name'] as String? ?? '',
      domain: json['domain'] as String? ?? '',
      logoUrl: json['logoUrl'] as String?,
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
      reliabilityScore: (json['reliabilityScore'] as num?)?.toDouble() ?? 0,
      returnPolicy: json['returnPolicy'] as String?,
      shippingDaysMin: (json['shippingDaysMin'] as num?)?.toInt() ?? 0,
      shippingDaysMax: (json['shippingDaysMax'] as num?)?.toInt() ?? 0,
      isVerified: json['isVerified'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'domain': domain,
        'logoUrl': logoUrl,
        'rating': rating,
        'reviewCount': reviewCount,
        'reliabilityScore': reliabilityScore,
        'returnPolicy': returnPolicy,
        'shippingDaysMin': shippingDaysMin,
        'shippingDaysMax': shippingDaysMax,
        'isVerified': isVerified,
      };

  @override
  List<Object?> get props => [
        id,
        name,
        domain,
        logoUrl,
        rating,
        reviewCount,
        reliabilityScore,
        returnPolicy,
        shippingDaysMin,
        shippingDaysMax,
        isVerified,
      ];
}
