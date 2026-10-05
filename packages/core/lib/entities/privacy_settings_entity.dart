// `PrivacySettingsEntity` lives in `shopping_preferences_entity.dart`
// (alongside `ShoppingPreferencesEntity`). This file exists purely so the
// many `import '.../entities/privacy_settings_entity.dart';` sites resolve;
// it exposes only the privacy class to keep imports intentional.
export 'shopping_preferences_entity.dart' show PrivacySettingsEntity;
