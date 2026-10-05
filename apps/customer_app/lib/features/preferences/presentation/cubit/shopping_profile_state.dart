import 'package:decoze_core/core.dart';
import 'package:equatable/equatable.dart';

sealed class ShoppingProfileState extends Equatable {
  const ShoppingProfileState();

  @override
  List<Object?> get props => [];
}

class ShoppingProfileInitial extends ShoppingProfileState {
  const ShoppingProfileInitial();
}

class ShoppingProfileLoading extends ShoppingProfileState {
  const ShoppingProfileLoading();
}

class ShoppingProfileLoaded extends ShoppingProfileState {
  final ShoppingPreferencesEntity preferences;
  final List<CategoryEntity> categories;

  const ShoppingProfileLoaded({
    required this.preferences,
    required this.categories,
  });

  @override
  List<Object?> get props => [preferences, categories];
}

class ShoppingProfileError extends ShoppingProfileState {
  final String message;
  const ShoppingProfileError(this.message);

  @override
  List<Object?> get props => [message];
}
