import '../entities/price_alert_entity.dart';
import '../entities/price_history_entity.dart';

/// فاحص التنبيهات السعرية — يقارن التنبيهات
/// النشطة ضد الأسعار الحالية ويرجّع
/// اللي اتحقق (مع نوع التحقق).
class PriceAlertChecker {
  /// يفحص تنبيه واحد ضد سعر حالي.
  /// بيرجّع true لو التنبيه اتحقق.
  static bool evaluate({
    required PriceAlertEntity alert,
    required double currentPrice,
    double? previousPrice,
    bool currentlyInStock = true,
  }) {
    switch (alert.type) {
      case PriceAlertType.targetPrice:
        final target = alert.targetPrice;
        return target != null && currentPrice <= target;

      case PriceAlertType.priceDrop:
        final percent = alert.percentDrop ?? 10;
        final reference = previousPrice ?? currentPrice;
        if (reference <= 0) return false;
        final dropPercent =
            ((reference - currentPrice) / reference) * 100;
        return dropPercent >= percent;

      case PriceAlertType.backInStock:
        return currentlyInStock;
    }
  }

  /// يفحص تنبيه ضد تاريخ أسعار كامل —
  /// بيستخدم آخر نقطتين (السعر الحالي
  /// واللي قبله) لحساب نسبة الانخفاض.
  static bool evaluateWithHistory({
    required PriceAlertEntity alert,
    required PriceHistory? history,
    bool currentlyInStock = true,
  }) {
    if (history == null || history.points.isEmpty) {
      // مفيش تاريخ — بنفحص التوفر بس.
      if (alert.type == PriceAlertType.backInStock) {
        return currentlyInStock;
      }
      return false;
    }

    final currentPrice = history.currentPrice!;
    final points = history.points;
    final previousPrice =
        points.length >= 2 ? points[points.length - 2].price : null;

    return evaluate(
      alert: alert,
      currentPrice: currentPrice,
      previousPrice: previousPrice,
      currentlyInStock: currentlyInStock,
    );
  }

  /// نسبة الانخفاض من أعلى سعر في التاريخ
  /// للسعر الحالي (0-100)، أو null لو مش متوفر.
  static double? dropFromHighest(PriceHistory history) {
    final highest = history.highestPrice;
    final current = history.currentPrice;
    if (highest == null || current == null || highest <= 0) return null;
    if (current >= highest) return 0;
    return ((highest - current) / highest) * 100;
  }

  /// وفر محتمل لو السعر نزل لأدنى سعر
  /// تاريخي (أو للسعر المستهدف).
  static double? potentialSavings({
    required double currentPrice,
    double? targetPrice,
    double? lowestHistoricalPrice,
  }) {
    final reference = targetPrice ?? lowestHistoricalPrice;
    if (reference == null || reference >= currentPrice) return null;
    return currentPrice - reference;
  }
}
