import 'package:decoze_core/core.dart';
import 'package:equatable/equatable.dart';

sealed class DuplicatesState extends Equatable {
  const DuplicatesState();

  @override
  List<Object?> get props => [];
}

class DuplicatesInitial extends DuplicatesState {
  const DuplicatesInitial();
}

class DuplicatesLoading extends DuplicatesState {
  const DuplicatesLoading();
}

class DuplicatesLoaded extends DuplicatesState {
  final List<DuplicateGroup> groups;
  final Map<String, ProductEntity> productsById;
  final Map<String, ExternalListingEntity> listingsById;

  const DuplicatesLoaded({
    this.groups = const [],
    this.productsById = const {},
    this.listingsById = const {},
  });

  @override
  List<Object?> get props => [groups, productsById, listingsById];
}

class DuplicatesError extends DuplicatesState {
  final String message;
  const DuplicatesError(this.message);

  @override
  List<Object?> get props => [message];
}
