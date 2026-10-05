import 'package:decoze_core/core.dart';
import 'package:equatable/equatable.dart';

sealed class WebSearchState extends Equatable {
  const WebSearchState();

  @override
  List<Object?> get props => [];
}

class WebSearchInitial extends WebSearchState {
  const WebSearchInitial();
}

class WebSearchLoading extends WebSearchState {
  const WebSearchLoading();
}

class WebSearchLoaded extends WebSearchState {
  final String query;
  final List<ExternalListingEntity> results;

  const WebSearchLoaded({
    required this.query,
    required this.results,
  });

  @override
  List<Object?> get props => [query, results];
}

class WebSearchError extends WebSearchState {
  final String message;
  const WebSearchError(this.message);

  @override
  List<Object?> get props => [message];
}
