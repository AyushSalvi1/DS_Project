import 'package:decoze_core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'sentiment_state.dart';

/// Cubit تحليل المشاعر —
/// بيحلل تقييمات منتج
/// ويرجّع ملخص المشاعر.
class SentimentCubit extends Cubit<SentimentState> {
  final SentimentRepository _sentimentRepository;
  final ProductRepository _productRepository;

  SentimentCubit({
    SentimentRepository? sentimentRepository,
    ProductRepository? productRepository,
  })  : _sentimentRepository =
            sentimentRepository ?? SentimentRepositoryImpl(),
        _productRepository =
            productRepository ?? ProductRepositoryImpl(),
        super(const SentimentInitial());

  Future<void> analyze(String productId) async {
    emit(const SentimentLoading());
    try {
      final results = await Future.wait([
        _productRepository.getProductById(productId),
        _productRepository.getReviews(productId),
      ]);

      final product = results[0] as ProductEntity;
      final reviews = results[1] as List<ReviewEntity>;

      final report = await _sentimentRepository.analyze(
        productId,
        reviews,
      );

      emit(SentimentLoaded(product: product, report: report));
    } catch (e) {
      emit(const SentimentError(
        'Could not analyze reviews sentiment.',
      ));
    }
  }
}
