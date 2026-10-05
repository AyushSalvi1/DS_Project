import 'package:equatable/equatable.dart';

/// نوع التنبيه السعري اللي المستخدم فعّّله.
enum PriceAlertType { priceDrop, targetPrice, backInStock }

/// تنبيه سعر/توفر — بيتراقب المستخدم منتج معين وبيبقى
/// متنبه لما السعر ينزل تحت حد معين أو المنتج يرجع يتوفر.
class PriceAlertEntity extends Equatable {
  final String id;
  final String uid;

  /// ID العرض الخارجي (listing) أو ID المنتج المحلي —
  /// [listingId] للمقارنة عبر المواقع، [productId] للمنتجات المحلية.
  final String? listingId;
  final String? productId;
  final PriceAlertType type;

  /// السعر المستهدف (لـ targetPrice) أو نسبة الانخفاض المطلوبة
  /// كنسبة مئوية (لـ priceDrop، مثال: 10 = انخفاض 10%).
  final double? targetPrice;
  final double? percentDrop;
  final bool active;
  final DateTime createdAt;
  final DateTime? triggeredAt;

  const PriceAlertEntity({
    required this.id,
    required this.uid,
    this.listingId,
    this.productId,
    required this.type,
    this.targetPrice,
    this.percentDrop,
    this.active = true,
    required this.createdAt,
    this.triggeredAt,
  });

  factory PriceAlertEntity.fromJson(String id, Map<String, dynamic> json) {
    return PriceAlertEntity(
      id: id,
      uid: json['uid'] as String? ?? '',
      listingId: json['listingId'] as String?,
      productId: json['productId'] as String?,
      type: PriceAlertType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => PriceAlertType.priceDrop,
      ),
      targetPrice: (json['targetPrice'] as num?)?.toDouble(),
      percentDrop: (json['percentDrop'] as num?)?.toDouble(),
      active: json['active'] as bool? ?? true,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      triggeredAt: json['triggeredAt'] != null
          ? DateTime.tryParse(json['triggeredAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'listingId': listingId,
        'productId': productId,
        'type': type.name,
        'targetPrice': targetPrice,
        'percentDrop': percentDrop,
        'active': active,
        'createdAt': createdAt.toIso8601String(),
        'triggeredAt': triggeredAt?.toIso8601String(),
      };

  @override
  List<Object?> get props => [
        id,
        uid,
        listingId,
        productId,
        type,
        targetPrice,
        percentDrop,
        active,
        createdAt,
        triggeredAt,
      ];
}
