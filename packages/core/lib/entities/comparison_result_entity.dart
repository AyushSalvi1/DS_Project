import 'package:equatable/equatable.dart';

import 'product_entity.dart';

/// معيار واحد في جدول المقارنة (السعر، التقييم،
/// عدد المراجعات، التوفر، القيمة...) مع قيمة
/// كل منتج وأيهم الأفضل.
class ComparisonCriterion extends Equatable {
  final String label;

  /// productId -> القيمة المعروضة.
  final Map<String, String> values;

  /// ID المنتج الأفضل في المعيار ده (لو فيه فائز واضح).
  final String? bestProductId;

  const ComparisonCriterion({
    required this.label,
    required this.values,
    this.bestProductId,
  });

  @override
  List<Object?> get props => [label, values, bestProductId];
}

/// نتيجة المقارنة الذكية بين المنتجات —
/// جدول معايير + الفائز + ملخص الذكاء الاصطناعي.
class ComparisonResult extends Equatable {
  final List<ProductEntity> products;
  final List<ComparisonCriterion> criteria;
  final String? winnerId;
  final String summary;
  final List<String> reasons;

  const ComparisonResult({
    required this.products,
    required this.criteria,
    this.winnerId,
    this.summary = '',
    this.reasons = const [],
  });

  ProductEntity? winner() {
    if (winnerId == null) return null;
    for (final p in products) {
      if (p.id == winnerId) return p;
    }
    return null;
  }

  @override
  List<Object?> get props => [products, criteria, winnerId, summary, reasons];
}
