import 'package:decoze_core/core.dart';
import 'package:equatable/equatable.dart';

sealed class CompatibilityState extends Equatable {
  const CompatibilityState();

  @override
  List<Object?> get props => [];
}

class CompatibilityInitial extends CompatibilityState {
  const CompatibilityInitial();
}

class CompatibilityLoading extends CompatibilityState {
  const CompatibilityLoading();
}

class CompatibilityLoaded extends CompatibilityState {
  final ProductEntity product;
  final List<CompatibilityEntity> compatible;

  const CompatibilityLoaded({
    required this.product,
    required this.compatible,
  });

  @override
  List<Object?> get props => [product, compatible];
}

class CompatibilityError extends CompatibilityState {
  final String message;
  const CompatibilityError(this.message);

  @override
  List<Object?> get props => [message];
}
