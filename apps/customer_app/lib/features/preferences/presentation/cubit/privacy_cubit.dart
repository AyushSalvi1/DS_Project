import 'package:decoze_core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'privacy_state.dart';

/// Cubit إعدادات
/// الخصوصية — بيعرض
/// ويحفظ التبديلات
/// ويمسح البيانات.
class PrivacyCubit extends Cubit<PrivacyState> {
  final PreferencesRepository _repository;
  final String uid;

  PrivacyCubit({
    required PreferencesRepository repository,
    required this.uid,
  })  : _repository = repository,
        super(const PrivacyInitial());

  Future<void> load() async {
    emit(const PrivacyLoading());
    try {
      final settings =
          await _repository.watchPrivacySettings(uid).first;
      emit(PrivacyLoaded(settings: settings));
    } catch (e) {
      emit(const PrivacyError(
        'Could not load privacy settings.',
      ));
    }
  }

  Future<void> _save(PrivacySettingsEntity settings) async {
    emit(PrivacyLoaded(settings: settings));
    await _repository.savePrivacySettings(uid, settings);
  }

  Future<void> setPersonalization(bool enabled) async {
    if (state is! PrivacyLoaded) return;
    final current = (state as PrivacyLoaded).settings;
    await _save(
      current.copyWith(
        personalizationEnabled: enabled,
        updatedAt: DateTime.now(),
      ),
    );
  }

  Future<void> setActivityTracking(bool enabled) async {
    if (state is! PrivacyLoaded) return;
    final current = (state as PrivacyLoaded).settings;
    await _save(
      current.copyWith(
        activityTrackingEnabled: enabled,
        updatedAt: DateTime.now(),
      ),
    );
  }

  Future<void> setAnalyticsSharing(bool enabled) async {
    if (state is! PrivacyLoaded) return;
    final current = (state as PrivacyLoaded).settings;
    await _save(
      current.copyWith(
        analyticsSharingEnabled: enabled,
        updatedAt: DateTime.now(),
      ),
    );
  }

  Future<void> clearPersonalData() async {
    await _repository.clearPersonalData(uid);
    // بنعيد تحميل الافتراضي.
    await load();
  }
}
