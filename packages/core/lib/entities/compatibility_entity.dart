import 'package:equatable/equatable.dart';

/// توصيفة توافق منتج مع منتج تاني
/// ("دول بيشتغلوا مع بعض" / "بيتكملوا بعض").
class CompatibilityEntity extends Equatable {
  final String productId;
  final String compatibleProductId;

  /// درجة التوافق (0-100).
  final double score;
  final String reason;

  const CompatibilityEntity({
    required this.productId,
    required this.compatibleProductId,
    required this.score,
    required this.reason,
  });

  @override
  List<Object?> get props => [productId, compatibleProductId, score, reason];
}
