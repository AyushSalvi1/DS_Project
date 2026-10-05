import 'package:equatable/equatable.dart';

/// نقطة سعر واحدة في تاريخ سعر المنتج عند تاجر معين.
class PricePoint extends Equatable {
  final DateTime date;
  final double price;

  const PricePoint({required this.date, required this.price});

  factory PricePoint.fromJson(Map<String, dynamic> json) => PricePoint(
        date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
        price: (json['price'] as num?)?.toDouble() ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'price': price,
      };

  @override
  List<Object?> get props => [date, price];
}

/// تاريخ أسعار عرض واحد (listing) — بيستخدم في رسم
/// بيانية تاريخ السعر وتنبيهات انخفاض السعر.
class PriceHistory extends Equatable {
  final String listingId;
  final List<PricePoint> points;

  const PriceHistory({required this.listingId, required this.points});

  double? get currentPrice {
    if (points.isEmpty) return null;
    // آخر نقطة بالتاريخ مش بالترتيب
    // اللي اتخزنت فيه عشان النتيجة
    // صح حتى لو النقاط مش مرتبة.
    var latest = points.first;
    for (final p in points) {
      if (p.date.isAfter(latest.date)) latest = p;
    }
    return latest.price;
  }

  double? get lowestPrice =>
      points.isEmpty ? null : points.reduce((a, b) => a.price < b.price ? a : b).price;

  double? get highestPrice =>
      points.isEmpty ? null : points.reduce((a, b) => a.price > b.price ? a : b).price;

  factory PriceHistory.fromJson(String listingId, Map<String, dynamic> json) {
    return PriceHistory(
      listingId: listingId,
      points: (json['points'] as List? ?? const [])
          .map((e) => PricePoint.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'points': points.map((p) => p.toJson()).toList(),
      };

  @override
  List<Object?> get props => [listingId, points];
}
