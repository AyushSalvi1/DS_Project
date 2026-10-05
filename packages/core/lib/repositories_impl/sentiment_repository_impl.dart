import 'dart:convert';

import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/foundation.dart';

import '../entities/review_entity.dart';
import '../entities/sentiment_entity.dart';
import '../repositories/sentiment_repository.dart';

/// تنفيذ تحليل المشاعر الذكي لتقييمات
/// المنتج (AI review & sentiment analysis).
///
/// بنحلل التقييمات بـ Gemini ونخزّن
/// النتيجة على المنتج (cache) عشان
/// ما نعيدش التحليل كل مرة.
class SentimentRepositoryImpl implements SentimentRepository {
  late final GenerativeModel _model;

  SentimentRepositoryImpl() {
    _model =
        FirebaseAI.googleAI().generativeModel(model: 'gemini-3.6-flash');
  }

  @override
  Future<SentimentReport> analyze(
    String productId,
    List<ReviewEntity> reviews,
  ) async {
    // مفيش تقييمات — تقرير محايد.
    if (reviews.isEmpty) {
      return SentimentReport(
        productId: productId,
        overall: 0,
        summary: 'No reviews yet — be the first to share your experience.',
      );
    }

    try {
      final reviewList = reviews.take(100).map((r) {
        return {
          'rating': r.rating,
          'comment': r.comment.length > 300
              ? '${r.comment.substring(0, 300)}…'
              : r.comment,
        };
      }).toList();

      final prompt = '''
Analyze these product reviews for a home decor store. Identify the overall sentiment, key aspects (quality, price, design, durability, shipping), and the most common pros and cons.

Reviews (rating 1-5 + comment):
${const JsonEncoder.withIndent('  ').convert(reviewList)}

Return ONLY JSON:
{
  "overall": -1.0 to 1.0,
  "aspects": [{"aspect": "quality", "score": -1.0 to 1.0, "mentions": 3}, ...],
  "summary": "2-3 sentence summary of what buyers say",
  "pros": ["...", "...", "..."],
  "cons": ["...", "..."]
}
''';

      final response = await _model.generateContent([Content.text(prompt)]);
      final text = response.text ?? '';
      final cleaned =
          text.replaceAll(RegExp(r'```json|```'), '').trim();
      final json = jsonDecode(cleaned) as Map<String, dynamic>;

      final aspects = (json['aspects'] as List? ?? const [])
          .map(
            (e) => AspectSentiment(
              aspect: (e['aspect'] as String?) ?? 'general',
              score: (e['score'] as num?)?.toDouble() ?? 0,
              mentions: (e['mentions'] as num?)?.toInt() ?? 0,
            ),
          )
          .toList();

      return SentimentReport(
        productId: productId,
        overall: (json['overall'] as num?)?.toDouble() ?? 0,
        aspects: aspects,
        summary: (json['summary'] as String?) ?? '',
        pros: (json['pros'] as List? ?? const [])
            .map((e) => e.toString())
            .toList(),
        cons: (json['cons'] as List? ?? const [])
            .map((e) => e.toString())
            .toList(),
      );
    } catch (e) {
      debugPrint('== sentiment AI call failed: $e ==');
      // Fallback حتمي: مشاعر من
      // متوسط التقييم + كلمات إيجابية/
      // سلبية بسيطة.
      return _deterministicReport(productId, reviews);
    }
  }

  /// تحليل حتمي احتياطي — يشتغل
  /// أوفلاين.
  SentimentReport _deterministicReport(
    String productId,
    List<ReviewEntity> reviews,
  ) {
    final avgRating = reviews
            .map((r) => r.rating)
            .reduce((a, b) => a + b) /
        reviews.length;
    final overall = ((avgRating - 3) / 2).clamp(-1.0, 1.0).toDouble();

    // نعد الكلمات الإيجابية والسلبية
    // في التعليقات.
    const positiveWords = [
      'love', 'great', 'excellent', 'amazing', 'perfect',
      'beautiful', 'quality', 'comfortable', 'sturdy',
      'recommend', 'happy', 'nice', 'good', 'best', 'wow',
      'جميل', 'ممتاز', 'رائع', 'محب', 'جودة', 'مريح', 'ممتازة',
    ];
    const negativeWords = [
      'bad', 'poor', 'terrible', 'broken', 'cheap', 'worst',
      'disappointed', 'return', 'waste', 'flimsy', 'scratch',
      'سيئ', 'رديء', 'مكسور', 'مخيب', 'ضعيف', 'خدش',
    ];

    final aspectMentions = <String, int>{};
    var positiveHits = 0;
    var negativeHits = 0;
    final pros = <String>[];
    final cons = <String>[];

    for (final review in reviews) {
      final comment = review.comment.toLowerCase();
      for (final word in positiveWords) {
        if (comment.contains(word)) {
          positiveHits++;
          aspectMentions['quality'] =
              (aspectMentions['quality'] ?? 0) + 1;
          if (pros.length < 3 && review.comment.isNotEmpty) {
            pros.add(review.comment.length > 120
                ? '${review.comment.substring(0, 120)}…'
                : review.comment);
          }
        }
      }
      for (final word in negativeWords) {
        if (comment.contains(word)) {
          negativeHits++;
          aspectMentions['quality'] =
              (aspectMentions['quality'] ?? 0) + 1;
          if (cons.length < 3 && review.comment.isNotEmpty) {
            cons.add(review.comment.length > 120
                ? '${review.comment.substring(0, 120)}…'
                : review.comment);
          }
        }
      }
    }

    final aspects = [
      AspectSentiment(
        aspect: 'quality',
        score: (positiveHits - negativeHits) /
            (positiveHits + negativeHits + 1),
        mentions: aspectMentions['quality'] ?? 0,
      ),
      AspectSentiment(
        aspect: 'value',
        score: overall * 0.8,
        mentions: reviews.length ~/ 3,
      ),
    ];

    return SentimentReport(
      productId: productId,
      overall: overall,
      aspects: aspects,
      summary: 'Based on ${reviews.length} reviews with an average rating of ${avgRating.toStringAsFixed(1)}★.',
      pros: pros,
      cons: cons,
    );
  }
}
