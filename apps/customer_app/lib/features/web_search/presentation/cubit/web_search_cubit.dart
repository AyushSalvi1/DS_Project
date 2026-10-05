import 'package:decoze_core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'web_search_state.dart';

/// Cubit البحث عبر
/// المواقع — بيبحث في
/// عروض التجار الخارجيين.
class WebSearchCubit extends Cubit<WebSearchState> {
  final MerchantRepository _repository;

  WebSearchCubit({MerchantRepository? repository})
      : _repository = repository ?? MerchantRepositoryImpl(),
        super(const WebSearchInitial());

  Future<void> search(String query) async {
    if (query.trim().isEmpty) return;

    emit(const WebSearchLoading());
    try {
      final results = await _repository.searchAcrossWeb(
        query.trim(),
      );
      emit(WebSearchLoaded(query: query.trim(), results: results));
    } catch (e) {
      emit(const WebSearchError(
        'Could not search across websites.',
      ));
    }
  }
}
