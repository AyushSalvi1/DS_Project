import 'package:decoze_core/core.dart';
import 'package:equatable/equatable.dart';

sealed class ActivityState extends Equatable {
  const ActivityState();

  @override
  List<Object?> get props => [];
}

class ActivityInitial extends ActivityState {
  const ActivityInitial();
}

class ActivityLoading extends ActivityState {
  const ActivityLoading();
}

class ActivityLoaded extends ActivityState {
  final List<UserActivityEntity> activities;
  final List<String> recentSearches;

  /// productId -> ProductEntity
  final Map<String, ProductEntity> productsById;

  const ActivityLoaded({
    this.activities = const [],
    this.recentSearches = const [],
    this.productsById = const {},
  });

  @override
  List<Object?> get props => [activities, recentSearches, productsById];
}

class ActivityCleared extends ActivityState {
  final List<String> recentSearches;

  const ActivityCleared({this.recentSearches = const []});

  @override
  List<Object?> get props => [recentSearches];
}

class ActivityError extends ActivityState {
  final String message;
  const ActivityError(this.message);

  @override
  List<Object?> get props => [message];
}
