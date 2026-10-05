import 'package:decoze_core/core.dart';
import 'package:equatable/equatable.dart';

sealed class SentimentState extends Equatable {
  const SentimentState();

  @override
  List<Object?> get props => [];
}

class SentimentInitial extends SentimentState {
  const SentimentInitial();
}

class SentimentLoading extends SentimentState {
  const SentimentLoading();
}

class SentimentLoaded extends SentimentState {
  final ProductEntity product;
  final SentimentReport report;

  const SentimentLoaded({
    required this.product,
    required this.report,
  });

  @override
  List<Object?> get props => [product, report];
}

class SentimentError extends SentimentState {
  final String message;
  const SentimentError(this.message);

  @override
  List<Object?> get props => [message];
}
