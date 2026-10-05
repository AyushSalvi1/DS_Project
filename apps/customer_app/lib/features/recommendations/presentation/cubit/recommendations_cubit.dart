import 'package:decoze_core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'recommendations_state.dart';

/// Cubit التوصية التفسيرية —
/// بيجلب المنتجات المرشحة
/// مع درجاتها وأسبابها،
/// ويسجل تقييم المستخدم
/// (تعلم من الفيدباك).
class RecommendationsCubit extends Cubit<RecommendationsState> {
  final RecommendationRepository _repository;
  final ProductRepository _productRepository;
  final PreferencesRepository _preferences;
  final String uid;

  List<ScoredProduct> _current = const [];

  RecommendationsCubit({
    RecommendationRepository? repository,
    ProductRepository? productRepository,
    PreferencesRepository? preferences,
    required this.uid,
  })  : _repository =
            repository ?? RecommendationRepositoryImpl(),
        _productRepository =
            productRepository ?? ProductRepositoryImpl(),
        _preferences =
            preferences ?? PreferencesRepositoryImpl(),
        super(const RecommendationsInitial());

  Future<void> load() async {
    emit(const RecommendationsLoading());
    try {
      final catalog =
          await _productRepository.getProducts();

      // بنجمع تفضيلات
      // المستخدم والخصوصية
      // عشان التوصية تتخصص.
      final prefs =
          await _preferences.watchPreferences(uid).first;
      final privacy =
          await _preferences.watchPrivacySettings(uid).first;

      final scored = await _repository.recommend(
        uid: uid,
        catalog: catalog,
        preferences: prefs,
        privacy: privacy,
        limit: 12,
      );

      _current = scored;
      emit(RecommendationsLoaded(scored));
    } catch (e) {
      emit(const RecommendationsError(
        'Could not load recommendations.',
      ));
    }
  }

  Future<void> like(String productId) =>
      _feedback(productId, true);

  Future<void> dislike(String productId) =>
      _feedback(productId, false);

  Future<void> _feedback(
    String productId,
    bool liked,
  ) async {
    await _repository.recordFeedback(
      uid: uid,
      productId: productId,
      liked: liked,
    );
    // بنعيد إصدار القائمة
    // عشان الـ UI يتحدث
    // (وقتلة فايباك هيظهر
    // في الحالة التالية).
    if (state is RecommendationsLoaded) {
      emit(RecommendationsLoaded(_current));
    }
  }
}
