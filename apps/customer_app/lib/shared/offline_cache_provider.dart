import 'package:decoze_core/core.dart';

/// مزوّد الكاش الأوفلاين —
/// instance واحد بيتعمل
/// مرة واحدة في بداية التطبيق
/// (main.dart) ويبقى متاح
/// لأي Cubit.
class OfflineCacheProvider {
  static OfflineCache? _cache;

  /// بنناديها من main.dart
  /// بعد ما الـ app يتشغّل.
  static Future<OfflineCache> init() async {
    _cache ??= await OfflineCache.create();
    return _cache!;
  }

  /// الكاش الحالي — لازم
  /// init() تكون اتنادات
  /// الأول.
  static OfflineCache get cache {
    final cache = _cache;
    if (cache == null) {
      throw StateError(
        'OfflineCacheProvider.init() must be called before accessing cache',
      );
    }
    return cache;
  }

  static bool get isInitialized => _cache != null;
}
