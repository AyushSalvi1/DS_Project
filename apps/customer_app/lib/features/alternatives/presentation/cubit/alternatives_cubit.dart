import 'package:decoze_core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'alternatives_state.dart';

/// Cubit البدائل —
/// بياخد منتج ويقترح
/// أرخص / أفضل / مشابه
/// / أحدث بدلالة الأسباب.
class AlternativesCubit extends Cubit<AlternativesState> {
  final AlternativesRepository _repository;
  final ProductRepository _productRepository;
  final MerchantRepository _merchantRepository;

  AlternativesCubit({
    AlternativesRepository? repository,
    ProductRepository? productRepository,
    MerchantRepository? merchantRepository,
  })  : _repository = repository ?? AlternativesRepositoryImpl(),
        _productRepository =
            productRepository ?? ProductRepositoryImpl(),
        _merchantRepository =
            merchantRepository ?? MerchantRepositoryImpl(),
        super(const AlternativesInitial());

  Future<void> find(String productId) async {
    emit(const AlternativesLoading());
    try {
      final original =
          await _productRepository.getProductById(productId);
      final catalog = await _productRepository.getProducts();

      // عروض المواقع الخارجية
      // لنفس المنتج (بدائل
      // من تانيين).
      final listings = await _merchantRepository
          .getListingsForProduct(productId);

      final alternatives = await _repository.findAlternatives(
        original,
        catalog: catalog,
        webListings: listings,
      );

      emit(AlternativesLoaded(
        original: original,
        alternatives: alternatives,
      ));
    } catch (e) {
      emit(const AlternativesError(
        'Could not find alternatives for this product.',
      ));
    }
  }
}
