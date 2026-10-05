import 'package:decoze_core/core.dart';
import 'package:equatable/equatable.dart';

sealed class PrivacyState extends Equatable {
  const PrivacyState();

  @override
  List<Object?> get props => [];
}

class PrivacyInitial extends PrivacyState {
  const PrivacyInitial();
}

class PrivacyLoading extends PrivacyState {
  const PrivacyLoading();
}

class PrivacyLoaded extends PrivacyState {
  final PrivacySettingsEntity settings;

  const PrivacyLoaded({required this.settings});

  @override
  List<Object?> get props => [settings];
}

class PrivacyError extends PrivacyState {
  final String message;
  const PrivacyError(this.message);

  @override
  List<Object?> get props => [message];
}
