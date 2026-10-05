import 'dart:convert';

import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/foundation.dart';

import '../datasources/collection_remote_datasource.dart';
import '../entities/assistant_message_entity.dart';
import '../entities/category_entity.dart';
import '../entities/collection_entity.dart';
import '../entities/product_entity.dart';
import '../entities/shopping_preferences_entity.dart';
import '../repositories/assistant_repository.dart';
import '../repositories/category_repository.dart';
import '../repositories/collection_repository.dart';
import '../repositories/product_repository.dart';
import '../repositories_impl/category_repository_impl.dart';
import '../repositories_impl/product_repository_impl.dart';
import '../utils/price_alert_checker.dart';

/// تنفيذ المساعد الذكي للمحادثة
/// (Conversational AI Shopping Assistant).
///
/// الرحلة: اسأل الـ AI → بيحلل السؤال
/// → يبحث في الكتالوج (ومواقع خارجية)
/// → يوصي بمنتجات مبررة → يقترح
/// الخطوة التالية (قارن / تتبع / بدائل).
class AssistantRepositoryImpl implements AssistantRepository {
  late final GenerativeModel _model;
  final ProductRepository _productRepository;
  final CategoryRepository _categoryRepository;

  AssistantRepositoryImpl({
    ProductRepository? productRepository,
    CategoryRepository? categoryRepository,
  })  : _productRepository =
            productRepository ?? ProductRepositoryImpl(),
        _categoryRepository =
            categoryRepository ?? CategoryRepositoryImpl() {
    _model =
        FirebaseAI.googleAI().generativeModel(model: 'gemini-3.6-flash');
  }

  @override
  Future<AssistantResponse> ask({
    required String uid,
    required String message,
    List<AssistantMessageEntity> history = const [],
    ShoppingPreferencesEntity? preferences,
  }) async {
    // بنجمع السياق: الكتالوج + الفئات
    // + تفضيلات المستخدم.
    List<ProductEntity> products;
    List<CategoryEntity> categories;
    try {
      final results = await Future.wait([
        _productRepository.getProducts(),
        _categoryRepository.getCategories(),
      ]);
      products = (results[0] as List<ProductEntity>);
      categories = (results[1] as List<CategoryEntity>);
    } catch (_) {
      products = [];
      categories = [];
    }

    final prompt = _buildPrompt(
      message: message,
      history: history,
      products: products,
      categories: categories,
      preferences: preferences,
    );

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      final text = response.text ?? '';
      final cleaned =
          text.replaceAll(RegExp(r'```json|```'), '').trim();
      final json = jsonDecode(cleaned) as Map<String, dynamic>;

      final productIds = (json['productIds'] as List? ?? const [])
          .map((e) => e.toString())
          .where(products.map((p) => p.id).toSet().contains)
          .toList();

      return AssistantResponse(
        text: (json['reply'] as String? ?? '').trim(),
        productIds: productIds,
        suggestions: (json['suggestions'] as List? ?? const [])
            .map((e) => e.toString())
            .toList(),
        action: (json['action'] as String? ?? 'none'),
      );
    } catch (e) {
      debugPrint('== assistant AI call failed: $e ==');
      // لو الـ AI فشل: نرجع رد
      // حتمي مبني على بحث الكلمات
      // المفتاحية بدل ما نكسر المحادثة.
      return _fallbackResponse(message, products);
    }
  }

  @override
  Stream<List<AssistantMessageEntity>> watchHistory(String uid) {
    // التاريخ بيتخزّن محليًا في الـ
    // cubit (OfflineCache) — البث
    // ده مكانه من الـ cubit نفسه.
    return const Stream.empty();
  }

  @override
  Future<void> clearHistory(String uid) async {
    // بيتم من الـ cubit عبر OfflineCache.
  }

  @override
  List<String> starterSuggestions(
    ShoppingPreferencesEntity? preferences,
  ) {
    final hasCats =
        preferences?.preferredCategoryIds.isNotEmpty ?? false;
    return [
      'What\'s the best deal in ${hasCats ? "my favorites" : "furniture"}?',
      'Find me a cheaper alternative to a sofa',
      'Compare my recently viewed items',
      'Track the price of something I like',
    ];
  }

  String _buildPrompt({
    required String message,
    required List<AssistantMessageEntity> history,
    required List<ProductEntity> products,
    required List<CategoryEntity> categories,
    ShoppingPreferencesEntity? preferences,
  }) {
    final productList = products.take(60).map((p) {
      return {
        'id': p.id,
        'name': p.name,
        'category': p.categoryId,
        'price': p.price,
        'rating': p.rating,
        'reviews': p.reviewCount,
      };
    }).toList();

    final categoryNames = categories.map((c) => c.name).toList();

    final historyLines = history.take(8).map((m) {
      final role = m.role == AssistantRole.user ? 'User' : 'Assistant';
      return '$role: ${m.text}';
    }).join('\n');

    final prefLine = preferences != null && preferences.hasPreferences
        ? 'User preferences: budget ${preferences.budgetMin ?? "any"}-${preferences.budgetMax ?? "any"}, categories: ${preferences.preferredCategoryIds.join(", ")}, styles: ${preferences.styleKeywords.join(", ")}'
        : 'User preferences: none set';

    return '''
You are the shopping assistant for a home decor e-commerce app. Your job is to help the user find, compare, and track products across websites.

Available categories: ${categoryNames.join(', ')}
$prefLine

Product catalog (id, name, category, price, rating, reviews):
${const JsonEncoder.withIndent('  ').convert(productList)}

Conversation so far:
$historyLines

User's latest message: "$message"

Respond with ONLY a JSON object (no markdown, no explanation) in this exact shape:
{
  "reply": "Helpful answer in the user's language (English or Arabic). Mention 1-2 products by name and why they fit. If the user asks to compare, track prices, or find alternatives, say what you'll do next.",
  "productIds": ["up to 4 product ids from the catalog above that best answer the request"],
  "suggestions": ["next quick action 1", "next quick action 2", "next quick action 3"],
  "action": "one of: search | compare | track | alternatives | none"
}

Rules:
- If the request is vague, recommend top-rated products in the user's preferred categories.
- If the user asks "cheaper", pick same-category products with lower price.
- If the user asks to compare, pick the 2-3 most relevant products.
- Suggestions must be short phrases the user can tap (e.g. "Compare these", "Track the price", "Show cheaper options").
''';
  }

  /// رد حتمي احتياطي: بحث كلمات
  /// مفتاحية بسيط في الكتالوج.
  AssistantResponse _fallbackResponse(
    String message,
    List<ProductEntity> products,
  ) {
    final tokens = message
        .toLowerCase()
        .split(RegExp(r'[^a-z0-9\u0600-\u06FF]+'))
        .where((t) => t.length > 2)
        .toSet();

    final matches = products.where((p) {
      final haystack =
          '${p.name} ${p.description}'.toLowerCase();
      return tokens.any((t) => haystack.contains(t));
    }).toList();

    matches.sort((a, b) => b.rating.compareTo(a.rating));
    final top = matches.take(4).toList();

    if (top.isEmpty) {
      return const AssistantResponse(
        text:
            'I couldn\'t find products matching that. Try describing what you\'re looking for in a few words — like "wooden coffee table under 200".',
        suggestions: ['Show top rated', 'Browse categories'],
        action: 'search',
      );
    }

    final names = top.map((p) => p.name).take(2).join(' and ');
    return AssistantResponse(
      text:
          'Here\'s what I found: $names${top.length > 2 ? ' and ${top.length - 2} more' : ''}. They match your search and are among the best rated in their category.',
      productIds: top.map((p) => p.id).toList(),
      suggestions: const [
        'Compare these',
        'Find cheaper alternatives',
        'Track the price',
      ],
      action: 'search',
    );
  }
}

/// تنفيذ "AI setup / collection builder" —
/// بياخد وصف المستخدم النصي (brief)
/// ويبني مجموعة منتجات منسجمة.
class CollectionRepositoryImpl implements CollectionRepository {
  late final GenerativeModel _model;
  final CollectionRemoteDataSource _remote;
  final ProductRepository _productRepository;

  CollectionRepositoryImpl({
    CollectionRemoteDataSource? remote,
    ProductRepository? productRepository,
  })  : _remote = remote ?? CollectionRemoteDataSource(),
        _productRepository =
            productRepository ?? ProductRepositoryImpl() {
    _model =
        FirebaseAI.googleAI().generativeModel(model: 'gemini-3.6-flash');
  }

  @override
  Stream<List<CollectionEntity>> watchCollections(String uid) {
    return _remote.watchCollections(uid);
  }

  @override
  Future<CollectionEntity> createFromBrief({
    required String uid,
    required String brief,
    String? name,
    double? budget,
    required List<ProductEntity> catalog,
  }) async {
    // الخطوة 1: الذكاء الاصطناعي بيختار
    // المنتجات المناسبة للوصف.
    final pickedIds = await _pickProducts(brief, budget, catalog);

    // الخطوة 2: لو الـ AI فشل/رجّع حاجات
    // قليلة، نكمل بالأعلى تقييمًا في
    // نفس الفئات.
    final picked = <ProductEntity>[];
    for (final id in pickedIds) {
      final match = catalog.where((p) => p.id == id).toList();
      if (match.isNotEmpty) picked.add(match.first);
    }

    if (picked.isEmpty) {
      final fallback = [...catalog]
        ..sort((a, b) => b.rating.compareTo(a.rating));
      picked.addAll(fallback.take(6));
    }

    // احترام الميزانية: نرتب حسب السعر
    // ونشيل اللي بيزيد عن الميزانية
    // لو المجموعة بتتعداها بكتير.
    if (budget != null) {
      picked.sort((a, b) => a.price.compareTo(b.price));
      var total = 0.0;
      final kept = <ProductEntity>[];
      for (final p in picked) {
        if (total + p.price <= budget * 1.15 || kept.isEmpty) {
          kept.add(p);
          total += p.price;
        }
      }
      picked
        ..clear()
        ..addAll(kept);
    }

    // الخطوة 3: ننشئ المجموعة في Firestore.
    final now = DateTime.now();
    final collection = CollectionEntity(
      id: 'collection-${now.millisecondsSinceEpoch}',
      uid: uid,
      name: name ?? _deriveName(brief),
      description: brief,
      productIds: picked.map((p) => p.id).toList(),
      style: _deriveStyle(brief),
      budget: budget,
      createdAt: now,
      aiGenerated: true,
    );

    await _remote.createCollection(collection);
    return collection;
  }

  /// الذكاء الاصطناعي بيختار IDs
  /// المنتجات المناسبة للوصف.
  Future<List<String>> _pickProducts(
    String brief,
    double? budget,
    List<ProductEntity> catalog,
  ) async {
    if (catalog.isEmpty) return const [];

    final productList = catalog.take(80).map((p) {
      return {
        'id': p.id,
        'name': p.name,
        'category': p.categoryId,
        'price': p.price,
        'rating': p.rating,
      };
    }).toList();

    final prompt = '''
You are building a product collection for a home decor store. The user described their setup:

"$brief"
${budget != null ? 'Total budget: $budget USD' : ''}

Available products (id, name, category, price, rating):
${const JsonEncoder.withIndent('  ').convert(productList)}

Pick 4-8 products that work TOGETHER as a coherent set (matching style, complementary pieces — e.g. sofa + coffee table + rug + lamp). Prefer highly rated items, and keep the total${budget != null ? ' within budget' : ''}.

Return ONLY a JSON array of product ids, no explanation:
["id1", "id2"]
''';

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      final text = response.text ?? '[]';
      final cleaned =
          text.replaceAll(RegExp(r'```json|```'), '').trim();
      final ids = (jsonDecode(cleaned) as List)
          .map((e) => e.toString())
          .toList();
      final validIds = catalog.map((p) => p.id).toSet();
      return ids.where(validIds.contains).toList();
    } catch (e) {
      debugPrint('== collection builder AI call failed: $e ==');
      return const [];
    }
  }

  String _deriveName(String brief) {
    // اسم مبسّط من أول 5 كلمات
    // في الوصف.
    final words = brief
        .split(RegExp(r'\s+'))
        .take(5)
        .join(' ');
    final trimmed = words.length > 40
        ? '${words.substring(0, 40)}…'
        : words;
    return trimmed.isEmpty ? 'My Collection' : trimmed;
  }

  String? _deriveStyle(String brief) {
    const styles = [
      'modern',
      'minimalist',
      'scandinavian',
      'bohemian',
      'industrial',
      'rustic',
      'vintage',
      'classic',
    ];
    final lower = brief.toLowerCase();
    for (final style in styles) {
      if (lower.contains(style)) return style;
    }
    return null;
  }

  @override
  Future<void> addToCollection(
    String uid,
    String collectionId,
    String productId,
  ) async {
    final collections = await _remote
        .watchCollections(uid)
        .first;
    final match = collections
        .where((c) => c.id == collectionId)
        .toList();
    if (match.isEmpty) return;

    final collection = match.first;
    if (collection.productIds.contains(productId)) return;

    final updated = collection.copyWith(
      productIds: [
        ...collection.productIds,
        productId,
      ],
    );
    await _remote.updateCollection(updated);
  }

  @override
  Future<void> removeFromCollection(
    String uid,
    String collectionId,
    String productId,
  ) async {
    final collections = await _remote
        .watchCollections(uid)
        .first;
    final match = collections
        .where((c) => c.id == collectionId)
        .toList();
    if (match.isEmpty) return;

    final collection = match.first;
    final updated = collection.copyWith(
      productIds: collection.productIds
          .where((id) => id != productId)
          .toList(),
    );
    await _remote.updateCollection(updated);
  }

  @override
  Future<void> deleteCollection(String uid, String collectionId) {
    return _remote.deleteCollection(uid, collectionId);
  }

  @override
  Future<void> renameCollection(
    String uid,
    String collectionId,
    String name,
  ) async {
    final collections = await _remote
        .watchCollections(uid)
        .first;
    final match = collections
        .where((c) => c.id == collectionId)
        .toList();
    if (match.isEmpty) return;

    final updated = match.first.copyWith(name: name);
    await _remote.updateCollection(updated);
  }
}
