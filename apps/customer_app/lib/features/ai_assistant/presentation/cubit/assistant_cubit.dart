import 'dart:async';

import 'package:decoze_core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'assistant_state.dart';

/// Cubit المساعد الذكي — ينفّذ رحلة
/// "اسأل → ابحث → حلل → قارن → أوصي →
/// وضّح → تتبّع → حوّل لأفضل موقع".
///
/// بيحافظ على تاريخ المحادثة (في
/// الذاكرة + كاش أوفلاين) وبيسجّل
/// نشاط "سؤال" في ذاكرة التسوق.
class AssistantCubit extends Cubit<AssistantState> {
  final AssistantRepository _assistantRepository;
  final ProductRepository _productRepository;
  final MerchantRepository _merchantRepository;
  final ActivityRepository _activityRepository;
  final OfflineCache _cache;

  String? _uid;
  final List<AssistantMessageEntity> _history = [];
  StreamSubscription<List<AssistantMessageEntity>>? _historySub;

  AssistantCubit({
    required AssistantRepository assistantRepository,
    required ProductRepository productRepository,
    required MerchantRepository merchantRepository,
    required ActivityRepository activityRepository,
    required OfflineCache cache,
  })  : _assistantRepository = assistantRepository,
        _productRepository = productRepository,
        _merchantRepository = merchantRepository,
        _activityRepository = activityRepository,
        _cache = cache,
        super(const AssistantInitial());

  /// بتتنادى لما المستخدم بيسجّل دخول
  /// (نفس نمط Cubits التانية).
  Future<void> attachUser(String? uid) async {
    _uid = uid;
    _history.clear();

    if (uid == null) {
      emit(const AssistantInitial());
      return;
    }

    // بنحاول نحمّل آخر محادثة من
    // الكاش الأوفلاين أولًا (متاح
    // من غير شبكة).
    final cached = _cache.getJsonList('assistant_history');
    if (cached.isNotEmpty) {
      _history.addAll(
        cached
            .map((json) => AssistantMessageEntity.fromJson(
                  json['id'] as String? ?? '',
                  json,
                ))
            .where((m) => m.uid == uid || m.uid.isEmpty)
            .toList(),
      );
      emit(AssistantLoaded(
        messages: List.unmodifiable(_history),
        suggestions: _assistantRepository.starterSuggestions(null),
      ));
    } else {
      emit(AssistantLoaded(
        messages: const [],
        suggestions: _assistantRepository.starterSuggestions(null),
      ));
    }
  }

  /// يسأل المساعد ويسجّل الرد في
  /// التاريخ والكاش وذاكرة التسوق.
  Future<void> ask(String message) async {
    final uid = _uid;
    if (uid == null || message.trim().isEmpty) return;

    final userMessage = AssistantMessageEntity(
      id: 'user-${DateTime.now().millisecondsSinceEpoch}',
      uid: uid,
      role: AssistantRole.user,
      text: message.trim(),
      timestamp: DateTime.now(),
    );

    _history.add(userMessage);
    emit(AssistantLoaded(
      messages: List.unmodifiable(_history),
      suggestions: const [],
      isLoading: true,
    ));

    // بنسجل سؤال البحث في ذاكرة
    // التسوق (لو التتبع مفعّل).
    unawaited(
      _activityRepository.recordActivity(
        UserActivityEntity(
          id: 'activity-${DateTime.now().millisecondsSinceEpoch}',
          uid: uid,
          type: ActivityType.ask,
          query: message.trim(),
          timestamp: DateTime.now(),
        ),
      ),
    );

    try {
      final response = await _assistantRepository.ask(
        uid: uid,
        message: message.trim(),
        history: _history,
      );

      final assistantMessage = AssistantMessageEntity(
        id: 'ai-${DateTime.now().millisecondsSinceEpoch}',
        uid: uid,
        role: AssistantRole.assistant,
        text: response.text,
        productIds: response.productIds,
        suggestions: response.suggestions,
        timestamp: DateTime.now(),
      );

      _history.add(assistantMessage);
      _persistHistory();

      emit(AssistantLoaded(
        messages: List.unmodifiable(_history),
        suggestions: response.suggestions,
      ));
    } catch (_) {
      // لو حصل خطأ بنرجع رسالة
      // واضحة ونحافظ على التاريخ.
      _history.add(
        AssistantMessageEntity(
          id: 'error-${DateTime.now().millisecondsSinceEpoch}',
          uid: uid,
          role: AssistantRole.assistant,
          text: 'Sorry, I hit a snag. Try asking in a few words, like "wooden coffee table under 200".',
          timestamp: DateTime.now(),
        ),
      );
      emit(AssistantLoaded(
        messages: List.unmodifiable(_history),
        suggestions: const [],
      ));
    }
  }

  /// ينفّذ إجراء سريع من أزرار
  /// الاقتراحات (مقارنة/تتبع/بدائل).
  Future<void> runSuggestion(String suggestion) async {
    await ask(suggestion);
  }

  /// يحمّل المنتجات المرتبطة برسالة
  /// معينة (لكروت المنتجات في المحادثة).
  Future<List<ProductEntity>> loadProducts(
    List<String> productIds,
  ) async {
    final futures = productIds.map((id) async {
      try {
        return await _productRepository.getProductById(id);
      } catch (_) {
        return null;
      }
    });
    final results = await Future.wait(futures);
    return results.whereType<ProductEntity>().toList();
  }

  /// يبحث في المواقع الخارجية
  /// عن رسالة/سؤال معين.
  Future<List<ExternalListingEntity>> searchWeb(String query) async {
    try {
      return await _merchantRepository.searchAcrossWeb(query);
    } catch (_) {
      return const [];
    }
  }

  /// مسح المحادثة (بيحترم
  /// إعدادات الخصوصية).
  Future<void> clearHistory() async {
    final uid = _uid;
    if (uid == null) return;

    _history.clear();
    await _cache.remove('assistant_history');
    unawaited(_assistantRepository.clearHistory(uid));

    emit(AssistantCleared(
      suggestions: _assistantRepository.starterSuggestions(null),
    ));
  }

  Future<void> _persistHistory() async {
    final uid = _uid;
    if (uid == null) return;

    // بنخزّن آخر 50 رسالة بس
    // عشان الكاش ما يكبرش.
    final toSave = _history.length > 50
        ? _history.sublist(_history.length - 50)
        : _history;

    await _cache.putJsonList(
      'assistant_history',
      toSave.map((m) => m.toJson()).toList(),
    );
  }

  @override
  Future<void> close() {
    _historySub?.cancel();
    return super.close();
  }
}
