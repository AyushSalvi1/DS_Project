import '../entities/privacy_settings_entity.dart';
import '../entities/shopping_preferences_entity.dart';

/// عقد ملف التسوق الشخصي + إعدادات الخصوصية.
abstract class PreferencesRepository {
  /// بث مباشر لتفضيلات التسوق.
  Stream<ShoppingPreferencesEntity> watchPreferences(String uid);
  Future<void> savePreferences(ShoppingPreferencesEntity preferences);

  /// بث مباشر لإعدادات الخصوصية والتخصيص.
  Stream<PrivacySettingsEntity> watchPrivacySettings(String uid);
  Future<void> savePrivacySettings(String uid, PrivacySettingsEntity settings);

  /// بتمسح تفضيلات المستخدم ونشاطه وتقييماته
  /// (حق "النسيان" في إعدادات الخصوصية).
  Future<void> clearPersonalData(String uid);
}
