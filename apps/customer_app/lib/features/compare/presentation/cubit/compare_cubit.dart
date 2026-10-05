import 'package:decoze_core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'compare_state.dart';

/// Cubit المقارنة الذكية —
/// بياخد المنتجات المختارة
/// وبيرجّع جدول معايير + الفائز
/// + ملخص مبرر.
class CompareCubit extends Cubit<CompareState> {
  final ComparisonRepository _repository;

  CompareCubit({ComparisonRepository? repository})
      : _repository = repository ?? ComparisonRepositoryImpl(),
        super(const CompareInitial());

  Future<void> compare(
    List<ProductEntity> products, {
    ShoppingPreferencesEntity? preferences,
    PrivacySettingsEntity? privacy,
  }) async {
    if (products.isEmpty) {
      emit(const CompareError('Add at least two products to compare.'));
      return;
    }

    emit(const CompareLoading());
    try {
      final result = await _repository.compare(
        products: products,
        preferences: preferences,
        privacy: privacy,
      );
      emit(CompareLoaded(result: result));
    } catch (e) {
      emit(const CompareError('Could not compare these products.'));
    }
  }
}
