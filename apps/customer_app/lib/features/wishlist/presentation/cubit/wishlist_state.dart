import 'package:decoze_core/core.dart';
import 'package:equatable/equatable.dart';

sealed class WishlistState extends Equatable {
  const WishlistState();

  @override
  List<Object?> get props => [];
}

class WishlistInitial extends WishlistState {
  const WishlistInitial();
}

class WishlistLoading extends WishlistState {
  const WishlistLoading();
}

class WishlistLoaded extends WishlistState {
  final List<WishlistItemEntity> items;

  /// productId -> ProductEntity
  final Map<String, ProductEntity> products;

  const WishlistLoaded({
    this.items = const [],
    this.products = const {},
  });

  @override
  List<Object?> get props => [items, products];
}

class WishlistError extends WishlistState {
  final String message;
  const WishlistError(this.message);

  @override
  List<Object?> get props => [message];
}
