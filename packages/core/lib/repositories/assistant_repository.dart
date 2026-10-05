import '../entities/assistant_message_entity.dart';
import '../entities/privacy_settings_entity.dart';
import '../entities/shopping_preferences_entity.dart';

/// عقد المساعد الذكي للمحادثة — بيستقبل سؤال
/// المستخدم بلغة طبيعية ويرجّع رد منظم:
/// نص + منتجات مرتبطة + اقتراحات الخطوة التالية.
abstract class AssistantRepository {
  /// يسأل المساعد. [history] آخر الرسائل للسياق،
  /// والتفضيلات بتستخدم عشان الرد يكون شخصي.
  Future<AssistantResponse> ask({
    required String uid,
    required String message,
    List<AssistantMessageEntity> history = const [],
    ShoppingPreferencesEntity? preferences,
  });

  /// بث مباشر لتاريخ المحادثة (يتم حفظه تلقائيًا).
  Stream<List<AssistantMessageEntity>> watchHistory(String uid);

  /// مسح المحادثة (بيحترم إعدادات الخصوصية).
  Future<void> clearHistory(String uid);

  /// اقتراحات جاهزة للشاشة فاضية (حسب التفضيلات).
  List<String> starterSuggestions(ShoppingPreferencesEntity? preferences);
}
