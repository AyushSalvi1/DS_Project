import 'package:decoze_core/core.dart';
import 'package:equatable/equatable.dart';

sealed class MerchantsState extends Equatable {
  const MerchantsState();

  @override
  List<Object?> get props => [];
}

class MerchantsInitial extends MerchantsState {
  const MerchantsInitial();
}

class MerchantsLoading extends MerchantsState {
  const MerchantsLoading();
}

class MerchantsLoaded extends MerchantsState {
  final List<MerchantEntity> merchants;

  const MerchantsLoaded({this.merchants = const []});

  @override
  List<Object?> get props => [merchants];
}

class MerchantsError extends MerchantsState {
  final String message;
  const MerchantsError(this.message);

  @override
  List<Object?> get props => [message];
}
