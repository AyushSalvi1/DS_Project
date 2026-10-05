import 'package:decoze_core/core.dart';
import 'package:equatable/equatable.dart';

sealed class PriceTrackingState extends Equatable {
  const PriceTrackingState();

  @override
  List<Object?> get props => [];
}

class PriceTrackingInitial extends PriceTrackingState {
  const PriceTrackingInitial();
}

class PriceTrackingLoading extends PriceTrackingState {
  const PriceTrackingLoading();
}

class PriceTrackingLoaded extends PriceTrackingState {
  final List<PriceAlertEntity> alerts;
  final PriceHistory? history;
  final String? selectedListingId;

  const PriceTrackingLoaded({
    this.alerts = const [],
    this.history,
    this.selectedListingId,
  });

  @override
  List<Object?> get props => [alerts, history, selectedListingId];
}

class PriceTrackingError extends PriceTrackingState {
  final String message;
  const PriceTrackingError(this.message);

  @override
  List<Object?> get props => [message];
}
