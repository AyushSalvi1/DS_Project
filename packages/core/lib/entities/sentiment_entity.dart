import 'package:equatable/equatable.dart';

/// تحليل المشاعر لجانب واحد من التقييمات
/// (الجودة، السعر، الشحن، التصميم...).
class AspectSentiment extends Equatable {
  final String aspect;

  /// درجة المشاعر (-1 سلبي .. 1 إيجابي).
  final double score;
  final int mentions;

  const AspectSentiment({
    required this.aspect,
    required this.score,
    required this.mentions,
  });

  @override
  List<Object?> get props => [aspect, score, mentions];
}

/// تقرير تحليل المشاعر الذكي لتقييمات منتج —
/// ملخص عام + إيجابيات وسلبيات + جوانب مفصّلة.
class SentimentReport extends Equatable {
  final String productId;

  /// المشاعر العامة (-1 .. 1).
  final double overall;
  final List<AspectSentiment> aspects;
  final String summary;
  final List<String> pros;
  final List<String> cons;

  const SentimentReport({
    required this.productId,
    required this.overall,
    this.aspects = const [],
    this.summary = '',
    this.pros = const [],
    this.cons = const [],
  });

  String sentimentLabel(String positive, String neutral, String negative) {
    if (overall >= 0.2) return positive;
    if (overall <= -0.2) return negative;
    return neutral;
  }

  @override
  List<Object?> get props =>
      [productId, overall, aspects, summary, pros, cons];
}
