import 'package:decoze_core/core.dart';
import 'package:equatable/equatable.dart';

sealed class AnalyticsState extends Equatable {
  const AnalyticsState();

  @override
  List<Object?> get props => [];
}

class AnalyticsInitial extends AnalyticsState {
  const AnalyticsInitial();
}

class AnalyticsLoading extends AnalyticsState {
  const AnalyticsLoading();
}

class AnalyticsLoaded extends AnalyticsState {
  final UserAnalytics userAnalytics;
  final RecommendationAnalytics recommendationAnalytics;

  const AnalyticsLoaded({
    required this.userAnalytics,
    required this.recommendationAnalytics,
  });

  @override
  List<Object?> get props => [userAnalytics, recommendationAnalytics];
}

class AnalyticsError extends AnalyticsState {
  final String message;
  const AnalyticsError(this.message);

  @override
  List<Object?> get props => [message];
}
