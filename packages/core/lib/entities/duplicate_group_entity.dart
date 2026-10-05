import 'package:equatable/equatable.dart';

/// مجموعة تكرار (Duplicate Group) — نفس المنتج
/// متلاقي في أكتر من موقع/تاجر أو مكرر في
/// الكتالوج المحلي. بيساعد في "كشف التكرار
/// الذكي عبر المواقع".
class DuplicateGroup extends Equatable {
  /// ID المنتج الأصلي (المرجعي) في المجموعة.
  final String canonicalProductId;

  /// IDs العروض الخارجية اللي طابقت المنتج الأصلي.
  final List<String> listingIds;

  /// IDs المنتجات المحلية المكررة (لو فيه أكتر من واحد).
  final List<String> productIds;

  /// درجة التشابه (0-1) اللي على أساسها اتجمعت المجموعة.
  final double similarity;

  const DuplicateGroup({
    required this.canonicalProductId,
    this.listingIds = const [],
    this.productIds = const [],
    required this.similarity,
  });

  @override
  List<Object?> get props =>
      [canonicalProductId, listingIds, productIds, similarity];
}
