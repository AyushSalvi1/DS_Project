import 'package:decoze_core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'compatibility_state.dart';

/// Cubit التوافق —
/// بييجد المنتجات اللي
/// بتكمل المنتج الحالي.
class CompatibilityCubit extends Cubit<CompatibilityState> {
  final CompatibilityRepository _repository;
  final ProductRepository _productRepository;
  final OrderRepository _orderRepository;

  CompatibilityCubit({
    CompatibilityRepository? repository,
    ProductRepository? productRepository,
    OrderRepository? orderRepository,
  })  : _repository = repository ?? CompatibilityRepositoryImpl(),
        _productRepository =
            productRepository ?? ProductRepositoryImpl(),
        _orderRepository = orderRepository ?? OrderRepositoryImpl(),
        super(const CompatibilityInitial());

  Future<void> find(String productId, String uid) async {
    emit(const CompatibilityLoading());
    try {
      final results = await Future.wait([
        _productRepository.getProductById(productId),
        _productRepository.getProducts(),
        // مشتريات المستخدم
        // (عشان نرشح حاجات
        // بتكمل اللي اشتراه).
        _safePurchased(uid),
      ]);

      final product = results[0] as ProductEntity;
      final catalog = results[1] as List<ProductEntity>;
      final purchased = results[2] as List<String>;

      final compatible = await _repository.getCompatibleProducts(
        product,
        catalog: catalog,
        purchasedProductIds: purchased,
      );

      emit(CompatibilityLoaded(
        product: product,
        compatible: compatible,
      ));
    } catch (e) {
      emit(const CompatibilityError(
        'Could not find compatible products.',
      ));
    }
  }

  Future<List<String>> _safePurchased(String uid) async {
    try {
      final orders = await _orderRepository.getOrders(uid);
      return orders
          .expand((o) => o.items.map((i) => i.productId))
          .toSet()
          .toList();
    } catch (_) {
      return const [];
    }
  }
}
