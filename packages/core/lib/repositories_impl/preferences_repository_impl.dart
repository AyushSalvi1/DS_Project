import '../datasources/activity_remote_datasource.dart';
import '../datasources/analytics_remote_datasource.dart';
import '../datasources/preferences_remote_datasource.dart';
import '../entities/privacy_settings_entity.dart';
import '../entities/shopping_preferences_entity.dart';
import '../entities/user_activity_entity.dart';
import '../repositories/activity_repository.dart';
import '../repositories/preferences_repository.dart';

/// تنفيذ تفضيلات التسوق + إعدادات
/// الخصوصية + ذاكرة النشاط.
class PreferencesRepositoryImpl implements PreferencesRepository {
  final PreferencesRemoteDataSource remoteDataSource;
  final ActivityRemoteDataSource _activityDataSource;
  final AnalyticsRemoteDataSource _analyticsDataSource;

  PreferencesRepositoryImpl({
    PreferencesRemoteDataSource? remoteDataSource,
    ActivityRemoteDataSource? activityDataSource,
    AnalyticsRemoteDataSource? analyticsDataSource,
  })  : remoteDataSource =
            remoteDataSource ?? PreferencesRemoteDataSource(),
        _activityDataSource =
            activityDataSource ?? ActivityRemoteDataSource(),
        _analyticsDataSource =
            analyticsDataSource ?? AnalyticsRemoteDataSource();

  @override
  Stream<ShoppingPreferencesEntity> watchPreferences(String uid) {
    return remoteDataSource.watchPreferences(uid).map(
          (json) => json == null
              ? _defaultPreferences(uid)
              : ShoppingPreferencesEntity.fromJson(uid, json),
        );
  }

  @override
  Future<void> savePreferences(ShoppingPreferencesEntity preferences) {
    return remoteDataSource.savePreferences(
      preferences.uid,
      preferences.toJson(),
    );
  }

  @override
  Stream<PrivacySettingsEntity> watchPrivacySettings(String uid) {
    return remoteDataSource.watchPrivacySettings(uid).map(
          (json) => json == null
              ? _defaultPrivacy(uid)
              : PrivacySettingsEntity.fromJson(uid, json),
        );
  }

  @override
  Future<void> savePrivacySettings(
    String uid,
    PrivacySettingsEntity settings,
  ) {
    return remoteDataSource.savePrivacySettings(uid, settings.toJson());
  }

  @override
  Future<void> clearPersonalData(String uid) async {
    // بنرجّع التفضيلات والخصوصية
    // للافتراضي ونمسح النشاط
    // وتقييمات التوصيات — كل
    // البيانات الشخصية تحت
    // مستند المستخدم (حق
    // "النسيان" الكامل).
    await remoteDataSource.savePreferences(
      uid,
      _defaultPreferences(uid).toJson(),
    );
    await remoteDataSource.savePrivacySettings(
      uid,
      _defaultPrivacy(uid).toJson(),
    );
    await _activityDataSource.clearActivity(uid);
    await _analyticsDataSource.clearFeedback(uid);
  }

  ShoppingPreferencesEntity _defaultPreferences(String uid) {
    return ShoppingPreferencesEntity(uid: uid, updatedAt: DateTime.now());
  }

  PrivacySettingsEntity _defaultPrivacy(String uid) {
    return PrivacySettingsEntity(uid: uid, updatedAt: DateTime.now());
  }
}

/// تنفيذ ذاكرة التسوق (نشاط المستخدم).
class ActivityRepositoryImpl implements ActivityRepository {
  final ActivityRemoteDataSource remoteDataSource;

  ActivityRepositoryImpl({ActivityRemoteDataSource? remoteDataSource})
      : remoteDataSource = remoteDataSource ?? ActivityRemoteDataSource();

  @override
  Future<void> recordActivity(UserActivityEntity activity) {
    return remoteDataSource.recordActivity(activity);
  }

  @override
  Stream<List<UserActivityEntity>> watchRecentActivity(
    String uid, {
    int limit = 50,
  }) {
    return remoteDataSource.watchRecentActivity(uid, limit: limit);
  }

  @override
  Future<List<UserActivityEntity>> getActivity(
    String uid, {
    int limit = 200,
  }) {
    return remoteDataSource.getActivity(uid, limit: limit);
  }

  @override
  Stream<List<String>> watchRecentSearches(
    String uid, {
    int limit = 10,
  }) {
    return remoteDataSource.watchRecentSearches(uid, limit: limit);
  }

  @override
  Future<void> clearActivity(String uid) {
    return remoteDataSource.clearActivity(uid);
  }
}
