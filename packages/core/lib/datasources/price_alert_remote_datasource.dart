import 'package:cloud_firestore/cloud_firestore.dart';

import '../entities/price_alert_entity.dart';

/// مصدر بيانات تنبيهات السعر —
/// تحت مستند المستخدم مباشرة.
class PriceAlertRemoteDataSource {
  final FirebaseFirestore firestore;

  PriceAlertRemoteDataSource({FirebaseFirestore? firestore})
      : firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _alerts(String uid) =>
      firestore.collection('users').doc(uid).collection('priceAlerts');

  Stream<List<PriceAlertEntity>> watchAlerts(String uid) {
    return _alerts(uid).orderBy('createdAt', descending: true).snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => PriceAlertEntity.fromJson(doc.id, doc.data()))
              .toList(),
        );
  }

  Future<void> addAlert(PriceAlertEntity alert) {
    return _alerts(alert.uid).doc(alert.id).set(alert.toJson());
  }

  Future<void> updateAlert(PriceAlertEntity alert) {
    return _alerts(alert.uid).doc(alert.id).update(alert.toJson());
  }

  Future<void> removeAlert(String uid, String alertId) {
    return _alerts(uid).doc(alertId).delete();
  }

  /// التنبيهات النشطة فقط (للفحص الدوري).
  Future<List<PriceAlertEntity>> activeAlerts(String uid) async {
    final snapshot =
        await _alerts(uid).where('active', isEqualTo: true).get();
    return snapshot.docs
        .map((doc) => PriceAlertEntity.fromJson(doc.id, doc.data()))
        .toList();
  }
}
