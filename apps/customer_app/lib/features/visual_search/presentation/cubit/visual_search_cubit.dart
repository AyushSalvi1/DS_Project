import 'dart:io';
import 'dart:typed_data';

import 'package:decoze_core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import 'visual_search_state.dart';

/// Cubit البحث البصري —
/// بياخد صورة وبيحللها
/// بالذكاء الاصطناعي ويرجّع
/// المنتجات الأقرب.
class VisualSearchCubit extends Cubit<VisualSearchState> {
  final VisualSearchRepository _visualSearchRepository;
  final ProductRepository _productRepository;
  final MerchantRepository _merchantRepository;

  VisualSearchCubit({
    required VisualSearchRepository visualSearchRepository,
    required ProductRepository productRepository,
    required MerchantRepository merchantRepository,
  })  : _visualSearchRepository = visualSearchRepository,
        _productRepository = productRepository,
        _merchantRepository = merchantRepository,
        super(const VisualSearchInitial());

  Future<void> pickImage() async {
    try {
      final image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      if (image == null) return;
      await _analyze(File(image.path));
    } catch (e) {
      emit(const VisualSearchError('Could not pick the image.'));
    }
  }

  Future<void> captureImage() async {
    try {
      final image = await ImagePicker().pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      if (image == null) return;
      await _analyze(File(image.path));
    } catch (e) {
      emit(const VisualSearchError('Could not capture a photo.'));
    }
  }

  Future<void> _analyze(File imageFile) async {
    emit(const VisualSearchLoading());

    try {
      final bytes = await imageFile.readAsBytes();
      final catalog = await _productRepository.getProducts();

      final result = await _visualSearchRepository.searchByImage(
        Uint8List.fromList(bytes),
        candidates: catalog,
      );

      emit(VisualSearchLoaded(result: result));
    } catch (e) {
      emit(const VisualSearchError(
        'Could not analyze the image. Try a clearer photo with the product in the center.',
      ));
    }
  }
}
