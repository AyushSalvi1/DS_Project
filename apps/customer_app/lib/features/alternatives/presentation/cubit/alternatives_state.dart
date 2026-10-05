import 'package:decoze_core/core.dart';
import 'package:equatable/equatable.dart';

sealed class AlternativesState extends Equatable {
  const AlternativesState();

  @override
  List<Object?> get props => [];
}

class AlternativesInitial extends AlternativesState {
  const AlternativesInitial();
}

class AlternativesLoading extends AlternativesState {
  const AlternativesLoading();
}

class AlternativesLoaded extends AlternativesState {
  final ProductEntity original;
  final List<AlternativeProduct> alternatives;

  const AlternativesLoaded({
    required this.original,
    required this.alternatives,
  });

  @override
  List<Object?> get props => [original, alternatives];
}

class AlternativesError extends AlternativesState {
  final String message;
  const AlternativesError(this.message);

  @override
  List<Object?> get props => [message];
}
