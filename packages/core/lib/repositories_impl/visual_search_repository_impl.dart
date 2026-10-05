import 'dart:convert';
import 'dart:typed_data';

import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/foundation.dart';

import '../entities/product_entity.dart';
import '../repositories/product_repository.dart';
import '../repositories/search_repository.dart';
import '../repositories/visual_search_repository.dart';
import '../repositories_impl/product_repository_impl.dart';
import '../repositories_impl/search_repository_impl.dart';

/// تنفيذ البحث بالصورة (AI visual
/// product search) — الصورة بترسل
/// للذكاء الاصطناعي فيصف المنتج
/// ونطابق الوصف على الكتالوج.
class VisualSearchRepositoryImpl implements VisualSearchRepository {
  late final GenerativeModel _model;
  final SearchRepository _searchRepository;
  final ProductRepository _productRepository;

  VisualSearchRepositoryImpl({
    SearchRepository? searchRepository,
    ProductRepository? productRepository,
  })  : _searchRepository =
            searchRepository ?? SearchRepositoryImpl(),
        _productRepository =
            productRepository ?? ProductRepositoryImpl() {
    _model =
        FirebaseAI.googleAI().generativeModel(model: 'gemini-3.6-flash');
  }

  @override
  Future<VisualSearchResult> searchByImage(
    Uint8List imageBytes, {
    String mimeType = 'image/jpeg',
    List<ProductEntity>? candidates,
  }) async {
    final catalog = candidates ??
        await _safeCatalog();

    try {
      // نرسل الصورة + prompt للذكاء
      // الاصطناعي متعدد الوسائط.
      final response = await _model.generateContent([
        Content.multi([
          const TextPart(
            'Describe this product for an e-commerce search in a home decor store. '
            'What object is it? What material, color, and style? '
            'List 3-6 search keywords a shopper would use to find it.',
          ),
          DataPart(mimeType, imageBytes),
        ]),
      ]);

      final text = response.text ?? '';
      final cleaned =
          text.replaceAll(RegExp(r'```json|```'), '').trim();

      // بنحاول نقرأ JSON منظم أولًا
      // (لو الـ AI رجّع JSON)، وإلا
      // بنستخدم النص نفسه كوصف.
      String description = text.trim();
      List<String> keywords = [];

      try {
        final json = jsonDecode(cleaned) as Map<String, dynamic>;
        description = (json['description'] as String?) ?? description;
        keywords = (json['keywords'] as List? ?? const [])
            .map((e) => e.toString())
            .toList();
      } catch (_) {
        // مش JSON — بنستخرج كلمات
        // مفتاحية من النص نفسه.
        keywords = _extractKeywords(text);
      }

      // نرتب الكتالوج بالكلمات
      // المفتاحية المستخرجة.
      final query = keywords.join(' ');
      final rankedIds = query.isEmpty
          ? <String>[]
          : await _searchRepository.rankMatchingProducts(
              query,
              catalog,
            );

      final productsById = {
        for (final p in catalog) p.id: p,
      };
      final ranked = rankedIds
          .map((id) => productsById[id])
          .whereType<ProductEntity>()
          .map((p) => p.id)
          .toList();

      return VisualSearchResult(
        description: description.isEmpty
            ? 'Product photo detected'
            : description,
        keywords: keywords,
        rankedProductIds: ranked,
      );
    } catch (e) {
      debugPrint('== visual search AI call failed: $e ==');
      // لو فشل الـ AI: نرجع نتيجة
      // فاضية مع رسالة واضحة.
      return const VisualSearchResult(
        description:
            'Could not analyze the image. Try a clearer photo with the product in the center.',
      );
    }
  }

  Future<List<ProductEntity>> _safeCatalog() async {
    try {
      return await _productRepository.getProducts();
    } catch (_) {
      return const [];
    }
  }

  /// يستخرج كلمات مفتاحية من نص
  /// وصف (بدون JSON).
  List<String> _extractKeywords(String text) {
    final stopWords = {
      'the', 'a', 'an', 'and', 'or', 'of', 'for', 'with', 'in',
      'on', 'is', 'it', 'this', 'that', 'to', 'as', 'be', 'at',
      'by', 'from', 'would', 'could', 'may', 'might', 'likely',
      'appears', 'looks', 'seems', 'made', 'with', 'has', 'have',
    };

    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
        .split(RegExp(r'\s+'))
        .where(
          (word) =>
              word.length > 2 && !stopWords.contains(word),
        )
        .take(8)
        .toList();
  }
}
