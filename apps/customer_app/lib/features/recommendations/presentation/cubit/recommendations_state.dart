import 'package:decoze_core/core.dart';
import 'package:equatable/equatable.dart';

sealed class RecommendationsState extends Equatable {
  const RecommendationsState();

  @override
  List<Object?> get props => [];
}

class RecommendationsInitial extends RecommendationsState {
  const RecommendationsInitial();
}

class RecommendationsLoading extends RecommendationsState {
  const RecommendationsLoading();
}

class RecommendationsLoaded extends RecommendationsState {
  final List<ScoredProduct> products;

  const RecommendationsLoaded(this.products);

  @override
  List<Object?> get props => [products];
}

class RecommendationsError extends RecommendationsState {
  final String message;
  const RecommendationsError(this.message);

  @override
  List<Object?> get props => [message];
}
