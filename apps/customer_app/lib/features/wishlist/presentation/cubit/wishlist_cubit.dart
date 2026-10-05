import 'dart:async';

import 'package:decoze_core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'wishlist_state.dart';

/// Cubit قائمة الرغبات
/// الذكية — بيعرض العناصر
/// مع تتبع السعر والتنبيهات.
class WishlistCubit extends Cubit<WishlistState> {
  final WishlistRepository _repository;
  final String uid;

  StreamSubscription<List<WishlistItemEntity>>? _sub;

  WishlistCubit({
    required WishlistRepository repository,
    required this.uid,
  })  : _repository = repository,
        super(const WishlistInitial()) {
    _watch();
  }

  void _watch() {
    _sub?.cancel();
    _sub = _repository.watchWishlist(uid).listen(
      (items) async {
        // بنحمّل تفاصيل المنتجات
        // الكاملة لكل عنصر.
        final productIds =
            items.map((i) => i.productId).toList();
        List<ProductEntity> products = const [];
        try {
          products = await _repository.loadProducts(
            uid,
            productIds,
          );
        } catch (_) {}

        final byId = {for (final p in products) p.id: p};
        emit(WishlistLoaded(
          items: items,
          products: byId,
        ));
      },
    );
  }

  Future<void> addItem(String productId) async {
    await _repository.addItem(uid, productId);
  }

  Future<void> removeItem(String productId) async {
    await _repository.removeItem(uid, productId);
  }

  Future<void> setTargetPrice(
    String productId,
    double? targetPrice,
  ) async {
    await _repository.setTargetPrice(
      uid,
      productId,
      targetPrice,
    );
  }

  Future<void> setNotifyOnPriceDrop(
    String productId,
    bool enabled,
  ) async {
    await _repository.setNotifyOnPriceDrop(
      uid,
      productId,
      enabled,
    );
  }

  Future<void> setNotifyOnAvailability(
    String productId,
    bool enabled,
  ) async {
    await _repository.setNotifyOnAvailability(
      uid,
      productId,
      enabled,
    );
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
