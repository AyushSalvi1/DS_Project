import 'package:cloud_firestore/cloud_firestore.dart';

import '../datasources/merchant_remote_datasource.dart';
import '../datasources/price_alert_remote_datasource.dart';
import '../datasources/simulated_web_search_datasource.dart';
import '../entities/external_listing_entity.dart';
import '../entities/notification_entity.dart';
import '../entities/price_alert_entity.dart';
import '../entities/price_history_entity.dart';
import '../repositories/merchant_repository.dart';
import '../repositories/notification_repository.dart';
import '../repositories/price_tracking_repository.dart';
import '../repositories_impl/notification_repository_impl.dart';
import '../utils/price_alert_checker.dart';

/// تنفيذ تتبع الأسعار والتنبيهات الذكية.
class PriceTrackingRepositoryImpl implements PriceTrackingRepository {
  final PriceAlertRemoteDataSource _alerts;
  final MerchantRemoteDataSource _remote;
  final SimulatedWebSearchDataSource _simulated;
  final NotificationRepository _notifications;

  PriceTrackingRepositoryImpl({
    PriceAlertRemoteDataSource? alerts,
    MerchantRemoteDataSource? remote,
    SimulatedWebSearchDataSource? simulated,
    NotificationRepository? notifications,
  })  : _alerts = alerts ?? PriceAlertRemoteDataSource(),
        _remote = remote ?? MerchantRemoteDataSource(),
        _simulated = simulated ?? SimulatedWebSearchDataSource(),
        _notifications = notifications ?? NotificationRepositoryImpl();

  @override
  Stream<PriceHistory?> watchPriceHistory(String listingId) {
    // بث مباشر من Firestore لو فيه بيانات
    // حقيقية، وإلا تاريخ تجريبي ثابت.
    return _remote
        .priceHistoryStream(listingId)
        .handleError((_) {})
        .map((history) => history)
        .fold<PriceHistory?>(
          null,
          (previous, element) => element,
        )
        .asStream()
        .map((history) => history ?? _simulatedNow(listingId));
  }

  PriceHistory? _simulatedNow(String listingId) {
    // تاريخ تجريبي ثابت (مش بث) — للعرض
    // الفوري قبل ما بيانات حقيقية توصل.
    return null;
  }

  @override
  Future<void> recordPricePoint(String listingId, double price) {
    return _remote.recordPricePoint(listingId, price);
  }

  @override
  Stream<List<PriceAlertEntity>> watchAlerts(String uid) {
    return _alerts.watchAlerts(uid);
  }

  @override
  Future<void> addAlert(PriceAlertEntity alert) {
    return _alerts.addAlert(alert);
  }

  @override
  Future<void> updateAlert(PriceAlertEntity alert) {
    return _alerts.updateAlert(alert);
  }

  @override
  Future<void> removeAlert(String uid, String alertId) {
    return _alerts.removeAlert(uid, alertId);
  }

  @override
  Future<List<PriceAlertEntity>> checkAlerts(String uid) async {
    final alerts = await _alerts.activeAlerts(uid);
    final triggered = <PriceAlertEntity>[];

    for (final alert in alerts) {
      final resolved = await _resolveListing(alert);
      if (resolved == null) continue;

      // بنسجّل سعر النهارده في
      // تاريخ الأسعار عشان الرسم
      // البياني والتنبيهات يشتغلوا
      // على بيانات حديثة (العميل
      // هو اللي بيحدّث التاريخ في
      // الإصدار ده).
      await recordPricePoint(
        resolved.id,
        resolved.effectivePrice,
      );

      final history = await getPriceHistory(resolved.id);
      final isTriggered = PriceAlertChecker.evaluateWithHistory(
        alert: alert,
        history: history,
        currentlyInStock: resolved.isInStock,
      );

      if (!isTriggered) continue;

      // بنعلام التنبيه كمُحقق ونوقفه
      // عشان ما يتكررش الإشعار.
      final now = DateTime.now();
      final updated = PriceAlertEntity(
        id: alert.id,
        uid: alert.uid,
        listingId: alert.listingId,
        productId: alert.productId,
        type: alert.type,
        targetPrice: alert.targetPrice,
        percentDrop: alert.percentDrop,
        active: false,
        createdAt: alert.createdAt,
        triggeredAt: now,
      );
      await _alerts.updateAlert(updated);
      triggered.add(updated);

      // بنكتب إشعار في-app للمستخدم
      // (نفس نظام إشعارات الطلبات).
      await _notifyUser(updated, resolved, history);
    }

    return triggered;
  }

  @override
  Future<void> checkAlertsForProduct(String uid, String productId) async {
    // بنفحص التنبيهات اللي مرتبطة بمنتج
    // محلي معين (من صفحة تفاصيل المنتج).
    final alerts = await _alerts.activeAlerts(uid);
    final relevant = alerts
        .where((a) => a.productId == productId)
        .toList();

    for (final alert in relevant) {
      final listings = await _simulated.getListingsForProduct(productId);
      if (listings.isEmpty) continue;

      // بنأخذ أرخص عرض كـ"السعر الحالي".
      listings.sort((a, b) => a.effectivePrice.compareTo(b.effectivePrice));
      final cheapest = listings.first;
      final history = await getPriceHistory(cheapest.id);

      final isTriggered = PriceAlertChecker.evaluateWithHistory(
        alert: alert,
        history: history,
        currentlyInStock: cheapest.isInStock,
      );

      if (!isTriggered) continue;

      final now = DateTime.now();
      final updated = PriceAlertEntity(
        id: alert.id,
        uid: alert.uid,
        listingId: alert.listingId,
        productId: alert.productId,
        type: alert.type,
        targetPrice: alert.targetPrice,
        percentDrop: alert.percentDrop,
        active: false,
        createdAt: alert.createdAt,
        triggeredAt: now,
      );
      await _alerts.updateAlert(updated);
      await _notifyUser(updated, cheapest, history);
    }
  }

  /// بيحل التنبيه لعرض خارجي فعلي
  /// (من listingId أو من productId).
  Future<ExternalListingEntity?> _resolveListing(
    PriceAlertEntity alert,
  ) async {
    if (alert.listingId != null && alert.listingId!.isNotEmpty) {
      // بنجرب نلاقي العرض من المصدر
      // التجريبي (التجارب المحلية).
      final merchants = await _simulated.getMerchants();
      for (final merchant in merchants) {
        final productId = alert.productId;
        if (productId == null) continue;
        final listings =
            await _simulated.getListingsForProduct(productId);
        for (final listing in listings) {
          if (listing.id == alert.listingId) return listing;
        }
      }
    }

    if (alert.productId != null && alert.productId!.isNotEmpty) {
      final listings =
          await _simulated.getListingsForProduct(alert.productId!);
      if (listings.isNotEmpty) {
        listings.sort(
          (a, b) => a.effectivePrice.compareTo(b.effectivePrice),
        );
        return listings.first;
      }
    }

    return null;
  }

  Future<void> _notifyUser(
    PriceAlertEntity alert,
    ExternalListingEntity listing,
    PriceHistory? history,
  ) async {
    final drop = history != null
        ? PriceAlertChecker.dropFromHighest(history)
        : null;

    final data = <String, dynamic>{
      'listingId': listing.id,
      'productId': listing.productId,
      'title': listing.title,
      'price': listing.price,
      'merchantId': listing.merchantId,
      'dropPercent': drop,
    };

    final type = alert.type == PriceAlertType.backInStock
        ? NotificationType.backInStock
        : NotificationType.priceDrop;

    await _notifications.notifyUserPriceEvent(
      uid: alert.uid,
      type: type,
      data: data,
    );
  }
}

/// إضافة صغيرة على MerchantRemoteDataSource
/// للبث المباشر لتاريخ الأسعار.
extension on MerchantRemoteDataSource {
  Stream<PriceHistory?> priceHistoryStream(String listingId) {
    return FirebaseFirestore.instance
        .collection('externalListings')
        .doc(listingId)
        .collection('priceHistory')
        .orderBy('date')
        .limit(365)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.isEmpty
              ? null
              : PriceHistory(
                  listingId: listingId,
                  points: snapshot.docs
                      .map((doc) => PricePoint.fromJson(doc.data()))
                      .toList(),
                ),
        );
  }
}
