import 'package:decoze_core/core.dart';
import 'package:equatable/equatable.dart';

sealed class CompareState extends Equatable {
  const CompareState();

  @override
  List<Object?> get props => [];
}

class CompareInitial extends CompareState {
  const CompareInitial();
}

class CompareLoading extends CompareState {
  const CompareLoading();
}

class CompareLoaded extends CompareState {
  final ComparisonResult result;

  const CompareLoaded({required this.result});

  @override
  List<Object?> get props => [result];
}

class CompareError extends CompareState {
  final String message;
  const CompareError(this.message);

  @override
  List<Object?> get props => [message];
}
