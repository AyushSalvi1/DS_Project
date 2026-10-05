import '../entities/price_alert_entity.dart';
import '../entities/price_history_entity.dart';

/// عقد تتبع الأسعار والتنبيهات الذكية.
abstract class PriceTrackingRepository {
  /// بث مباشر لتاريخ أسعار عرض معين.
  Stream<PriceHistory?> watchPriceHistory(String listingId);

  /// يسجل نقطة سعر جديدة لتاريخ عرض (بيتنادى
  /// من سكرابر/Cloud Function أو من فحص دوري).
  Future<void> recordPricePoint(String listingId, double price);

  /// بث مباشر لتنبيهات المستخدم النشطة.
  Stream<List<PriceAlertEntity>> watchAlerts(String uid);

  Future<void> addAlert(PriceAlertEntity alert);
  Future<void> updateAlert(PriceAlertEntity alert);
  Future<void> removeAlert(String uid, String alertId);

  /// يفحص التنبيهات ضد أسعار العروض الحالية ويرجّع
  /// اللي اتحقق (نزول السعر / رجوع التوفر). التنبيهات
  /// اللي اتحقق بيتحدّث حالة `triggeredAt` وبيتكتب
  /// إشعار للمستخدم عبر NotificationRepository.
  Future<List<PriceAlertEntity>> checkAlerts(String uid);

  /// يفحص تنبيهات منتج محلي معين (بيتنادى من
  /// صفحة تفاصيل المنتج).
  Future<void> checkAlertsForProduct(String uid, String productId);
}
