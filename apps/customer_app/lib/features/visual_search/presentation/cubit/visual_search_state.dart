import 'package:decoze_core/core.dart';
import 'package:equatable/equatable.dart';

sealed class VisualSearchState extends Equatable {
  const VisualSearchState();

  @override
  List<Object?> get props => [];
}

class VisualSearchInitial extends VisualSearchState {
  const VisualSearchInitial();
}

class VisualSearchLoading extends VisualSearchState {
  const VisualSearchLoading();
}

class VisualSearchLoaded extends VisualSearchState {
  final VisualSearchResult result;

  const VisualSearchLoaded({required this.result});

  @override
  List<Object?> get props => [result];
}

class VisualSearchError extends VisualSearchState {
  final String message;
  const VisualSearchError(this.message);

  @override
  List<Object?> get props => [message];
}
