import 'package:equatable/equatable.dart';

/// عنصر في قائمة الرغبات الذكية — مش بس منتج مفضّل، دول
/// بيترافقوا مع تتبع السعر وتنبيهات الانخفاض والتوفر.
class WishlistItemEntity extends Equatable {
  final String uid;
  final String productId;
  final DateTime addedAt;

  /// السعر المستهدف اللي المستخدم عايز يتبقى متنبه لو نزل السعر تحته.
  final double? targetPrice;
  final bool notifyOnPriceDrop;
  final bool notifyOnAvailability;

  const WishlistItemEntity({
    required this.uid,
    required this.productId,
    required this.addedAt,
    this.targetPrice,
    this.notifyOnPriceDrop = true,
    this.notifyOnAvailability = false,
  });

  factory WishlistItemEntity.fromJson(
    String uid,
    String productId,
    Map<String, dynamic> json,
  ) {
    return WishlistItemEntity(
      uid: uid,
      productId: productId,
      addedAt: DateTime.tryParse(json['addedAt'] as String? ?? '') ??
          DateTime.now(),
      targetPrice: (json['targetPrice'] as num?)?.toDouble(),
      notifyOnPriceDrop: json['notifyOnPriceDrop'] as bool? ?? true,
      notifyOnAvailability: json['notifyOnAvailability'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'addedAt': addedAt.toIso8601String(),
        'targetPrice': targetPrice,
        'notifyOnPriceDrop': notifyOnPriceDrop,
        'notifyOnAvailability': notifyOnAvailability,
      };

  WishlistItemEntity copyWith({
    double? targetPrice,
    bool clearTargetPrice = false,
    bool? notifyOnPriceDrop,
    bool? notifyOnAvailability,
  }) {
    return WishlistItemEntity(
      uid: uid,
      productId: productId,
      addedAt: addedAt,
      targetPrice: clearTargetPrice ? null : (targetPrice ?? this.targetPrice),
      notifyOnPriceDrop: notifyOnPriceDrop ?? this.notifyOnPriceDrop,
      notifyOnAvailability:
          notifyOnAvailability ?? this.notifyOnAvailability,
    );
  }

  @override
  List<Object?> get props => [
        uid,
        productId,
        addedAt,
        targetPrice,
        notifyOnPriceDrop,
        notifyOnAvailability,
      ];
}
