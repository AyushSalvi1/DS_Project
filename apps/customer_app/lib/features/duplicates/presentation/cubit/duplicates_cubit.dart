import 'package:decoze_core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'duplicates_state.dart';

/// Cubit كشف التكرار —
/// بيقارن المنتجات المحلية
/// بالعروض الخارجية ويرجّع
/// مجموعات التكرار.
class DuplicatesCubit extends Cubit<DuplicatesState> {
  final DuplicateDetectionRepository _repository;
  final ProductRepository _productRepository;
  final MerchantRepository _merchantRepository;

  DuplicatesCubit({
    DuplicateDetectionRepository? repository,
    ProductRepository? productRepository,
    MerchantRepository? merchantRepository,
  })  : _repository = repository ?? DuplicateDetectionRepositoryImpl(),
        _productRepository =
            productRepository ?? ProductRepositoryImpl(),
        _merchantRepository =
            merchantRepository ?? MerchantRepositoryImpl(),
        super(const DuplicatesInitial());

  Future<void> scan() async {
    emit(const DuplicatesLoading());
    try {
      // بنجمع المنتجات المحلية
      // والعروض الخارجية.
      final localProducts = await _productRepository.getProducts();

      // بنجمع عروض كل المنتجات
      // من المواقع الخارجية.
      final allListings = <ExternalListingEntity>[];
      for (final product in localProducts.take(30)) {
        final listings =
            await _merchantRepository.getListingsForProduct(product.id);
        allListings.addAll(listings);
      }

      final groups = await _repository.findDuplicates(
        localProducts: localProducts,
        webListings: allListings,
      );

      final productsById = {
        for (final p in localProducts) p.id: p,
      };
      final listingsById = {
        for (final l in allListings) l.id: l,
      };

      emit(DuplicatesLoaded(
        groups: groups,
        productsById: productsById,
        listingsById: listingsById,
      ));
    } catch (e) {
      emit(const DuplicatesError(
        'Could not scan for duplicates.',
      ));
    }
  }
}
