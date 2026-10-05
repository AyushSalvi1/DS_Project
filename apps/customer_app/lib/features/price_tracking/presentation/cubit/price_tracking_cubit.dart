import 'dart:async';

import 'package:decoze_core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'price_tracking_state.dart';

/// Cubit تتبع الأسعار —
/// بيراقب تنبيهات المستخدم
/// وتاريخ أسعار عرض معين.
class PriceTrackingCubit extends Cubit<PriceTrackingState> {
  final PriceTrackingRepository _repository;
  final String uid;

  StreamSubscription<List<PriceAlertEntity>>? _alertsSub;
  StreamSubscription<PriceHistory?>? _historySub;

  PriceTrackingCubit({
    required PriceTrackingRepository repository,
    required this.uid,
  })  : _repository = repository,
        super(const PriceTrackingInitial()) {
    _watchAlerts();
  }

  void _watchAlerts() {
    _alertsSub?.cancel();
    _alertsSub = _repository.watchAlerts(uid).listen(
      (alerts) {
        final current = state is PriceTrackingLoaded
            ? state as PriceTrackingLoaded
            : const PriceTrackingLoaded();

        emit(PriceTrackingLoaded(
          alerts: alerts,
          history: current.history,
          selectedListingId: current.selectedListingId,
        ));

        // لو مفيش عرض محدد لسه،
        // بنفتح أول تنبيه ليه عرض
        // خارجي عشان الرسم البياني
        // لأسعار بيظهر فورًا.
        if (current.selectedListingId == null) {
          String? firstListingId;
          for (final a in alerts) {
            if (a.listingId != null &&
                a.listingId!.isNotEmpty) {
              firstListingId = a.listingId;
              break;
            }
          }
          if (firstListingId != null) {
            selectListing(firstListingId);
          }
        }
      },
    );
  }

  /// يختار عرض معين ويعرض
  /// تاريخ أسعاره.
  void selectListing(String listingId) {
    _historySub?.cancel();
    _historySub = _repository.watchPriceHistory(listingId).listen(
      (history) {
        final current = state is PriceTrackingLoaded
            ? state as PriceTrackingLoaded
            : const PriceTrackingLoaded();
        emit(PriceTrackingLoaded(
          alerts: current.alerts,
          history: history,
          selectedListingId: listingId,
        ));
      },
    );
  }

  Future<void> addAlert({
    required PriceAlertType type,
    String? productId,
    String? listingId,
    double? targetPrice,
    double? percentDrop,
  }) async {
    final alert = PriceAlertEntity(
      id: 'alert-${DateTime.now().millisecondsSinceEpoch}',
      uid: uid,
      productId: productId,
      listingId: listingId,
      type: type,
      targetPrice: targetPrice,
      percentDrop: percentDrop,
      active: true,
      createdAt: DateTime.now(),
    );
    await _repository.addAlert(alert);
  }

  Future<void> removeAlert(String alertId) async {
    await _repository.removeAlert(uid, alertId);
  }

  Future<void> toggleAlert(PriceAlertEntity alert) async {
    final updated = PriceAlertEntity(
      id: alert.id,
      uid: alert.uid,
      productId: alert.productId,
      listingId: alert.listingId,
      type: alert.type,
      targetPrice: alert.targetPrice,
      percentDrop: alert.percentDrop,
      active: !alert.active,
      createdAt: alert.createdAt,
      triggeredAt: alert.triggeredAt,
    );
    await _repository.updateAlert(updated);
  }

  Future<void> checkNow() async {
    await _repository.checkAlerts(uid);
  }

  @override
  Future<void> close() {
    _alertsSub?.cancel();
    _historySub?.cancel();
    return super.close();
  }
}
