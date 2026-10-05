import 'dart:convert';

import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/foundation.dart';

import '../entities/comparison_result_entity.dart';
import '../entities/privacy_settings_entity.dart';
import '../entities/product_entity.dart';
import '../entities/shopping_preferences_entity.dart';
import '../repositories/comparison_repository.dart';

/// تنفيذ المقارنة الذكية بين المنتجات
/// (AI-powered product comparison).
///
/// بنبني جدول المعايير حتميًا (سعر،
/// تقييم، مراجعات، توفر، قيمة)
/// — ونضيف ملخص بلغة طبيعية من
/// الذكاء الاصطناعي لو متاح.
class ComparisonRepositoryImpl implements ComparisonRepository {
  late final GenerativeModel _model;

  ComparisonRepositoryImpl() {
    _model =
        FirebaseAI.googleAI().generativeModel(model: 'gemini-3.6-flash');
  }

  @override
  Future<ComparisonResult> compare({
    required List<ProductEntity> products,
    ShoppingPreferencesEntity? preferences,
    PrivacySettingsEntity? privacy,
  }) async {
    if (products.length < 2) {
      return ComparisonResult(
        products: products,
        criteria: const [],
        summary: 'Pick at least two products to compare.',
      );
    }

    // بنحسب متوسط السعر أولًا
    // عشان درجة "القيمة مقابل
    // السعر" في جدول المعايير
    // تشتغل على متوسط صحيح
    // (مش صفر).
    _computeAvgPrice(products);

    // 1) جدول المعايير — حتمي
    // (متاح دايمًا، حتى أوفلاين).
    final criteria = _buildCriteria(products);

    // 2) الفائز — من الدرجة
    // المجمّعة للمعايير.
    final winnerId = _pickWinner(products);

    // 3) الملخص — من الذكاء
    // الاصطناعي (مع fallback حتمي).
    final (summary, reasons) = await _aiSummary(
      products,
      preferences,
      winnerId,
    );

    return ComparisonResult(
      products: products,
      criteria: criteria,
      winnerId: winnerId,
      summary: summary,
      reasons: reasons,
    );
  }

  /// يبني جدول المعايير الأساسية.
  List<ComparisonCriterion> _buildCriteria(
    List<ProductEntity> products,
  ) {
    final cheapest = products
        .reduce((a, b) => a.price <= b.price ? a : b);
    final highestRated = products
        .reduce((a, b) => a.rating >= b.rating ? a : b);
    final mostReviewed = products
        .reduce((a, b) => a.reviewCount >= b.reviewCount ? a : b);
    final bestValue = _bestValue(products);
    final newest = products
        .reduce((a, b) => a.createdAt.isAfter(b.createdAt) ? a : b);

    return [
      ComparisonCriterion(
        label: 'Price',
        values: {
          for (final p in products)
            p.id: p.price.toStringAsFixed(2),
        },
        bestProductId: cheapest.id,
      ),
      ComparisonCriterion(
        label: 'Rating',
        values: {
          for (final p in products)
            p.id:
                '${p.rating.toStringAsFixed(1)} ★ (${p.reviewCount} reviews)',
        },
        bestProductId: highestRated.id,
      ),
      ComparisonCriterion(
        label: 'Popularity',
        values: {
          for (final p in products)
            p.id: '${p.salesCount} sold',
        },
        bestProductId: mostReviewed.id,
      ),
      ComparisonCriterion(
        label: 'Value for money',
        values: {
          for (final p in products)
            p.id: _valueLabel(_valueScore(p)),
        },
        bestProductId: bestValue?.id,
      ),
      ComparisonCriterion(
        label: 'Availability',
        values: {
          for (final p in products)
            p.id: p.stock > 0 ? 'In stock (${p.stock})' : 'Out of stock',
        },
        bestProductId: products
            .where((p) => p.stock > 0)
            .fold<String?>(
              null,
              (prev, p) => prev == null
                  ? p.id
                  : (p.stock >
                          _productById(products, prev).stock
                      ? p.id
                      : prev),
            ),
      ),
      ComparisonCriterion(
        label: 'Freshness',
        values: {
          for (final p in products)
            p.id:
                '${newest.createdAt.difference(p.createdAt).inDays} days ${newest.createdAt.difference(p.createdAt).inDays == 0 ? "newest" : "older"}',
        },
        bestProductId: newest.id,
      ),
    ];
  }

  ProductEntity? _bestValue(List<ProductEntity> products) {
    if (products.isEmpty) return null;
    return products
        .reduce((a, b) =>
            _valueScore(a) >= _valueScore(b) ? a : b);
  }

  /// درجة القيمة = تقييم مقسوم على
  /// السعر النسبوي (مقارنة بالمتوسط).
  double _valueScore(ProductEntity p) {
    final avgPrice = _avgPrice;
    if (avgPrice <= 0) return p.rating;
    final priceFactor =
        (avgPrice / p.price).clamp(0.5, 2.0).toDouble();
    return p.rating * priceFactor;
  }

  String _valueLabel(double score) {
    if (score >= 4.5) return 'Excellent';
    if (score >= 3.5) return 'Good';
    if (score >= 2.5) return 'Fair';
    return 'Low';
  }

  ProductEntity _productById(
    List<ProductEntity> products,
    String id,
  ) {
    return products.firstWhere((p) => p.id == id);
  }

  double get _avgPrice => _avgPriceCache;
  double _avgPriceCache = 0;

  // نحسب المتوسط في compare() ونخزّنه
  // مؤقتًا (الكلاس stateless منطقيًا).
  void _computeAvgPrice(List<ProductEntity> products) {
    if (products.isEmpty) {
      _avgPriceCache = 0;
      return;
    }
    _avgPriceCache = products
            .map((p) => p.price)
            .reduce((a, b) => a + b) /
        products.length;
  }

  /// الفائز = أعلى مجموع مرجّح:
  /// تقييم 40% + قيمة 30% + شعبية 20%
  /// + توفر 10%.
  String? _pickWinner(List<ProductEntity> products) {
    _computeAvgPrice(products);
    if (products.isEmpty) return null;

    String? winner;
    var bestScore = -1.0;

    for (final p in products) {
      final ratingScore = (p.rating / 5) * 0.4;
      final valueScore =
          (_valueScore(p) / 5).clamp(0.0, 1.0).toDouble() * 0.3;
      final popularityScore =
          (p.salesCount / 100).clamp(0.0, 1.0).toDouble() * 0.2;
      final availabilityScore =
          p.stock > 0 ? 0.1 : 0.0;

      final total = ratingScore +
          valueScore +
          popularityScore +
          availabilityScore;

      if (total > bestScore) {
        bestScore = total;
        winner = p.id;
      }
    }

    return winner;
  }

  /// ملخص ذكي — من Gemini مع
  /// fallback حتمي.
  Future<(String, List<String>)> _aiSummary(
    List<ProductEntity> products,
    ShoppingPreferencesEntity? preferences,
    String? winnerId,
  ) async {
    final winner = winnerId == null
        ? null
        : products.where((p) => p.id == winnerId).toList().first;

    // ملخص حتمي احتياطي (متاح دايمًا).
    final fallbackSummary = winner == null
        ? 'No clear winner.'
        : '${winner.name} is the overall pick — best balance of rating (${winner.rating.toStringAsFixed(1)}★), value, and popularity (${winner.salesCount} sold).';

    final fallbackReasons = <String>[
      if (winner != null)
        'Highest combined score across rating, value and popularity',
      'Compared across ${products.length} products',
    ];

    try {
      final productList = products.map((p) {
        return {
          'name': p.name,
          'price': p.price,
          'rating': p.rating,
          'reviewCount': p.reviewCount,
          'salesCount': p.salesCount,
          'stock': p.stock,
        };
      }).toList();

      final prefLine = preferences != null && preferences.hasPreferences
          ? 'User budget: ${preferences.budgetMin ?? "any"}-${preferences.budgetMax ?? "any"}, prefers: ${preferences.qualityPreference}'
          : 'No specific user preferences.';

      final prompt = '''
Compare these ${products.length} products for a home decor shopper:
${const JsonEncoder.withIndent('  ').convert(productList)}

$prefLine

Write a concise comparison summary (2-3 sentences) and 3 bullet-point reasons explaining which product is the best overall pick and why. Mention prices and ratings.

Return ONLY JSON:
{
  "summary": "...",
  "reasons": ["...", "...", "..."]
}
''';

      final response = await _model.generateContent([Content.text(prompt)]);
      final text = response.text ?? '';
      final cleaned =
          text.replaceAll(RegExp(r'```json|```'), '').trim();
      final json = jsonDecode(cleaned) as Map<String, dynamic>;

      final summary = (json['summary'] as String?)?.trim();
      final reasons = (json['reasons'] as List? ?? const [])
          .map((e) => e.toString())
          .toList();

      return (
        summary ?? fallbackSummary,
        reasons.isNotEmpty ? reasons : fallbackReasons,
      );
    } catch (e) {
      debugPrint('== comparison AI summary failed: $e ==');
      return (fallbackSummary, fallbackReasons);
    }
  }
}
