import '../entities/comparison_result_entity.dart';
import '../entities/privacy_settings_entity.dart';
import '../entities/product_entity.dart';
import '../entities/shopping_preferences_entity.dart';

/// عقد المقارنة الذكية بين المنتجات —
/// جدول معايير + الفائز + ملخص مبرر.
abstract class ComparisonRepository {
  Future<ComparisonResult> compare({
    required List<ProductEntity> products,
    ShoppingPreferencesEntity? preferences,
    PrivacySettingsEntity? privacy,
  });
}
