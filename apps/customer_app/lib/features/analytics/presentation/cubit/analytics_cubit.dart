import 'package:decoze_core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'analytics_state.dart';

/// Cubit التحليلات —
/// نشاط المستخدم وأداء
/// التوصيات.
class AnalyticsCubit extends Cubit<AnalyticsState> {
  final AnalyticsRepository _repository;
  final String uid;

  AnalyticsCubit({
    required AnalyticsRepository repository,
    required this.uid,
  })  : _repository = repository,
        super(const AnalyticsInitial());

  Future<void> load() async {
    emit(const AnalyticsLoading());
    try {
      final results = await Future.wait([
        _repository.getUserAnalytics(uid),
        _repository.getRecommendationAnalytics(uid),
      ]);

      emit(AnalyticsLoaded(
        userAnalytics: results[0] as UserAnalytics,
        recommendationAnalytics:
            results[1] as RecommendationAnalytics,
      ));
    } catch (e) {
      emit(const AnalyticsError(
        'Could not load analytics.',
      ));
    }
  }
}
