import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// كاش أوفلاين عام — بيخزّن محتوى
/// محفوظ/حديث (بحث حديث، منتجات مشاهدة،
/// قايمة الرغبات، المجموعات، رسائل
/// المساعد) في shared_preferences عشان
/// يفضل متاح من غير شبكة.
///
/// بنفس فكرة HomeCacheService في الصفحة
/// الرئيسية: بنعرض الكاش فورًا وبنحدثه
/// في الخلفية لما الشبكة ترجع.
class OfflineCache {
  final SharedPreferences _prefs;

  OfflineCache(this._prefs);

  static Future<OfflineCache> create() async {
    final prefs = await SharedPreferences.getInstance();
    return OfflineCache(prefs);
  }

  Future<void> putString(String key, String value) =>
      _prefs.setString('offline:$key', value);

  Future<void> putJsonList(String key, List<Map<String, dynamic>> items) =>
      _prefs.setString('offline:$key', jsonEncode(items));

  Future<void> putStringList(String key, List<String> items) =>
      _prefs.setStringList('offline:$key', items);

  String? getString(String key) => _prefs.getString('offline:$key');

  List<String> getStringList(String key) =>
      _prefs.getStringList('offline:$key') ?? const [];

  List<Map<String, dynamic>> getJsonList(String key) {
    final raw = _prefs.getString('offline:$key');
    if (raw == null) return const [];
    try {
      final decoded = jsonDecode(raw) as List;
      return List<Map<String, dynamic>>.from(decoded);
    } catch (_) {
      return const [];
    }
  }

  Future<void> remove(String key) => _prefs.remove('offline:$key');

  /// بمسح كل المحتوى المحفوظ محليًا
  /// (بيتنادى من إعدادات الخصوصية).
  Future<void> clearAll() async {
    final keys = _prefs.getKeys().where((k) => k.startsWith('offline:'));
    for (final key in keys) {
      await _prefs.remove(key);
    }
  }
}
