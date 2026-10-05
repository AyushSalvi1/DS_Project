import 'package:decoze_core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'merchants_state.dart';

/// Cubit التجار —
/// بيعرض التجار الخارجيين
/// مع الموثوقية.
class MerchantsCubit extends Cubit<MerchantsState> {
  final MerchantRepository _repository;

  MerchantsCubit({MerchantRepository? repository})
      : _repository = repository ?? MerchantRepositoryImpl(),
        super(const MerchantsInitial());

  Future<void> load() async {
    emit(const MerchantsLoading());
    try {
      final merchants = await _repository.getMerchants();
      emit(MerchantsLoaded(merchants: merchants));
    } catch (e) {
      emit(const MerchantsError(
        'Could not load merchants.',
      ));
    }
  }
}
