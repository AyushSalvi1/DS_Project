import '../entities/review_entity.dart';
import '../entities/sentiment_entity.dart';

/// عقد تحليل المشاعر الذكي لتقييمات المنتج.
abstract class SentimentRepository {
  /// يحلل تقييمات منتج ويرجّع تقرير مشاعر
  /// (ملخص + إيجابيات + سلبيات + جوانب).
  /// النتيجة بيتخزّن (cache) على المنتج عشان
  /// ما نعيدش طلب الـ AI كل مرة.
  Future<SentimentReport> analyze(
    String productId,
    List<ReviewEntity> reviews,
  );
}
