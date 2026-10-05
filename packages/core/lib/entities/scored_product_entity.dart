import 'package:equatable/equatable.dart';

import 'product_entity.dart';

/// عامل واحد في التقييم التفسيري (Explainable AI) —
/// كل عامل ليه وزن وقيمة normalized وسبب
/// مقروء بيظهر للمستخدم.
class ScoreFactor extends Equatable {
  final String key;
  final String label;

  /// أهمية العامل في الدرجة النهائية (0-1).
  final double weight;

  /// قيمة العامل للمنتج بعد التطبيع (0-1).
  final double value;

  /// السبب المقروء (مثال: "مطابق لفئتك المفضلة: Living Room").
  final String reason;

  const ScoreFactor({
    required this.key,
    required this.label,
    required this.weight,
    required this.value,
    required this.reason,
  });

  /// مساهمة العامل في الدرجة النهائية.
  double get contribution => weight * value;

  @override
  List<Object?> get props => [key, label, weight, value, reason];
}

/// منتج مع درجته التفسيرية — الأساس بتاع
/// "ليه اترشح لك ده؟" (Explainable AI).
class ScoredProduct extends Equatable {
  final ProductEntity product;

  /// الدرجة النهائية (0-100).
  final double score;
  final List<ScoreFactor> factors;

  const ScoredProduct({
    required this.product,
    required this.score,
    required this.factors,
  });

  /// أقوى 3 أسباب مقروضة للعرض في الـ UI.
  List<String> get topReasons {
    final sorted = [...factors]
      ..sort((a, b) => b.contribution.compareTo(a.contribution));
    return sorted
        .where((f) => f.value > 0.05)
        .take(3)
        .map((f) => f.reason)
        .toList();
  }

  @override
  List<Object?> get props => [product, score, factors];
}
