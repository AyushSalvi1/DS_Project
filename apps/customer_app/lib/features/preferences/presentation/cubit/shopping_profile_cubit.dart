import 'package:decoze_core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'shopping_profile_state.dart';

/// Cubit ملف التسوق —
/// بيحمّل تفضيلات
/// المستخدم ويحفظها.
class ShoppingProfileCubit extends Cubit<ShoppingProfileState> {
  final PreferencesRepository _repository;
  final CategoryRepository _categoryRepository;
  final String uid;

  ShoppingProfileCubit({
    required PreferencesRepository repository,
    required CategoryRepository categoryRepository,
    required this.uid,
  })  : _repository = repository,
        _categoryRepository = categoryRepository,
        super(const ShoppingProfileInitial());

  Future<void> load() async {
    emit(const ShoppingProfileLoading());
    try {
      final results = await Future.wait([
        _repository.watchPreferences(uid).first,
        _categoryRepository.getCategories(),
      ]);

      emit(ShoppingProfileLoaded(
        preferences: results[0] as ShoppingPreferencesEntity,
        categories: results[1] as List<CategoryEntity>,
      ));
    } catch (e) {
      emit(const ShoppingProfileError(
        'Could not load preferences.',
      ));
    }
  }

  Future<void> save(
    ShoppingPreferencesEntity preferences,
  ) async {
    try {
      await _repository.savePreferences(
        preferences.copyWith(uid: uid, updatedAt: DateTime.now()),
      );
      // بنعيد إصدار الحالة
      // المحفوظة عشان الـ UI
      // يتحدث.
      if (state is ShoppingProfileLoaded) {
        final current = state as ShoppingProfileLoaded;
        emit(ShoppingProfileLoaded(
          preferences: preferences.copyWith(
            uid: uid,
            updatedAt: DateTime.now(),
          ),
          categories: current.categories,
        ));
      }
    } catch (e) {
      // فشل الحفظ مش بيوقف
      // الشاشة.
    }
  }
}
