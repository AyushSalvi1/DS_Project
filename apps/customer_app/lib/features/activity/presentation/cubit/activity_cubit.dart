import 'dart:async';

import 'package:decoze_core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'activity_state.dart';

/// Cubit ذاكرة التسوق —
/// بيعرض آخر نشاط
/// المستخدم وبحثه.
class ActivityCubit extends Cubit<ActivityState> {
  final ActivityRepository _repository;
  final ProductRepository _productRepository;
  final String uid;

  StreamSubscription<List<UserActivityEntity>>? _activitySub;
  StreamSubscription<List<String>>? _searchesSub;

  List<UserActivityEntity> _activities = const [];
  List<String> _searches = const [];

  ActivityCubit({
    required ActivityRepository repository,
    required ProductRepository productRepository,
    required this.uid,
  })  : _repository = repository,
        _productRepository = productRepository,
        super(const ActivityInitial()) {
    _watch();
  }

  void _watch() {
    _activitySub?.cancel();
    _activitySub = _repository
        .watchRecentActivity(uid, limit: 30)
        .listen((activities) async {
      _activities = activities;
      await _rebuild();
    });

    _searchesSub?.cancel();
    _searchesSub = _repository
        .watchRecentSearches(uid, limit: 10)
        .listen((searches) async {
      _searches = searches;
      await _rebuild();
    });
  }

  Future<void> _rebuild() async {
    // بنحمّل المنتجات
    // للنشاط اللي فيه
    // productId (مشاهدة/
    // مقارنة/شراء) —
    // كل منتج لوحده
    // مع تجاهل الأخطاء
    // (منتج اتشال مثلاً).
    final productIds = _activities
        .where((a) => a.productId != null)
        .map((a) => a.productId!)
        .toSet()
        .toList();

    final productsById = <String, ProductEntity>{};
    if (productIds.isNotEmpty) {
      final futures = productIds.map((id) async {
        try {
          return await _productRepository.getProductById(id);
        } catch (_) {
          return null;
        }
      });
      final results = await Future.wait(futures);
      for (final p in results.whereType<ProductEntity>()) {
        productsById[p.id] = p;
      }
    }

    if (!isClosed) {
      emit(ActivityLoaded(
        activities: _activities,
        recentSearches: _searches,
        productsById: productsById,
      ));
    }
  }

  Future<void> refresh() => _rebuild();

  Future<void> clear() async {
    await _repository.clearActivity(uid);
    _activities = const [];
    _searches = const [];
    if (!isClosed) {
      emit(ActivityCleared(
        recentSearches: const [],
      ));
    }
  }

  @override
  Future<void> close() {
    _activitySub?.cancel();
    _searchesSub?.cancel();
    return super.close();
  }
}
