import 'package:equatable/equatable.dart';

import 'product_entity.dart';

/// نوع البديل المقترح.
enum AlternativeType { cheaper, better, similar, newer }

/// بديل مقترح لمنتج — أرخص / أفضل / مشابه / أحدث —
/// مع السبب والوفورات المحتملة.
class AlternativeProduct extends Equatable {
  final ProductEntity product;
  final AlternativeType type;
  final String reason;

  /// المبلغ اللي المستخدم بيوفّره (للبدائل الأرخص).
  final double? savings;

  /// درجة ملاءمة البديل (0-100).
  final double score;

  const AlternativeProduct({
    required this.product,
    required this.type,
    required this.reason,
    this.savings,
    required this.score,
  });

  @override
  List<Object?> get props => [product, type, reason, savings, score];
}
