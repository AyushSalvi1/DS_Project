import 'dart:async';

import 'package:decoze_core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'collections_state.dart';

/// Cubit المجموعات —
/// بيعرض مجموعات المستخدم
/// ويبني مجموعة جديدة
/// بالذكاء الاصطناعي.
class CollectionsCubit extends Cubit<CollectionsState> {
  final CollectionRepository _repository;
  final ProductRepository _productRepository;
  final String uid;

  StreamSubscription<List<CollectionEntity>>? _sub;

  CollectionsCubit({
    required CollectionRepository repository,
    required ProductRepository productRepository,
    required this.uid,
  })  : _repository = repository,
        _productRepository = productRepository,
        super(const CollectionsInitial()) {
    _watch();
  }

  void _watch() {
    _sub?.cancel();
    _sub = _repository.watchCollections(uid).listen(
      (collections) {
        emit(CollectionsLoaded(collections: collections));
      },
    );
  }

  /// يبني مجموعة جديدة
  /// من وصف نصي بالذكاء
  /// الاصطناعي.
  Future<void> buildCollection({
    required String brief,
    String? name,
    double? budget,
  }) async {
    emit(const CollectionsLoading());
    try {
      final catalog = await _productRepository.getProducts();
      await _repository.createFromBrief(
        uid: uid,
        brief: brief,
        name: name,
        budget: budget,
        catalog: catalog,
      );
      // الـ watch هيعيد
      // إصدار CollectionsLoaded
      // تلقائي لما تتضاف.
    } catch (e) {
      emit(const CollectionsError(
        'Could not build this collection.',
      ));
    }
  }

  Future<void> removeFromCollection(
    String collectionId,
    String productId,
  ) async {
    await _repository.removeFromCollection(
      uid,
      collectionId,
      productId,
    );
  }

  Future<void> deleteCollection(String collectionId) async {
    await _repository.deleteCollection(uid, collectionId);
  }

  Future<void> renameCollection(
    String collectionId,
    String name,
  ) async {
    await _repository.renameCollection(uid, collectionId, name);
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
