import 'package:decoze_core/core.dart';
import 'package:equatable/equatable.dart';

sealed class CollectionsState extends Equatable {
  const CollectionsState();

  @override
  List<Object?> get props => [];
}

class CollectionsInitial extends CollectionsState {
  const CollectionsInitial();
}

class CollectionsLoading extends CollectionsState {
  const CollectionsLoading();
}

class CollectionsLoaded extends CollectionsState {
  final List<CollectionEntity> collections;

  const CollectionsLoaded({this.collections = const []});

  @override
  List<Object?> get props => [collections];
}

class CollectionsError extends CollectionsState {
  final String message;
  const CollectionsError(this.message);

  @override
  List<Object?> get props => [message];
}
