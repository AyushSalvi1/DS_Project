import 'package:cloud_firestore/cloud_firestore.dart';

import '../entities/analytics_entity.dart';

/// مصدر بيانات التحليلات — أحداث التقييم
/// والانطباعات تحت مستند المستخدم.
class AnalyticsRemoteDataSource {
  final FirebaseFirestore firestore;

  AnalyticsRemoteDataSource({FirebaseFirestore? firestore})
      : firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _feedback(String uid) =>
      firestore.collection('users').doc(uid).collection('recommendationFeedback');

  CollectionReference<Map<String, dynamic>> _impressions(String uid) =>
      firestore.collection('users').doc(uid).collection('recommendationImpressions');

  Future<void> recordFeedback({
    required String uid,
    required String productId,
    required bool liked,
    String context = 'home',
  }) async {
    final now = DateTime.now();
    final id = '${now.millisecondsSinceEpoch}-${productId}';
    await _feedback(uid).doc(id).set({
      'productId': productId,
      'liked': liked,
      'context': context,
      'timestamp': now.toIso8601String(),
    });
  }

  Stream<List<AnalyticsFeedbackRow>> watchFeedback(String uid) {
    return _feedback(uid).orderBy('timestamp', descending: true).limit(50).snapshots().map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => AnalyticsFeedbackRow(
                  doc.id,
                  (doc.data()['productId'] as String?) ?? '',
                  (doc.data()['liked'] as bool?) ?? false,
                  (doc.data()['context'] as String?) ?? 'home',
                ),
              )
              .toList(),
        );
  }

  Future<void> recordImpression(
    String uid,
    List<String> productIds,
  ) async {
    final now = DateTime.now();
    final dayKey = '${now.year}-${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
    final doc = _impressions(uid).doc(dayKey);

    // عداد يومي بسيط: بنضيف IDs جديدة لمصفوفة
    // ونحفظ عدد الانطباعات (merge عشان ما
    // نكسر بيانات اليوم الحالي).
    await doc.set({
      'count': FieldValue.increment(productIds.length),
      'productIds': FieldValue.arrayUnion(productIds),
      'date': DateTime(now.year, now.month, now.day).toIso8601String(),
    }, SetOptions(merge: true));
  }

  Future<int> totalImpressions(String uid) async {
    final snapshot = await _impressions(uid).get();
    var total = 0;
    for (final doc in snapshot.docs) {
      total += (doc.data()['count'] as num?)?.toInt() ?? 0;
    }
    return total;
  }

  Future<List<AnalyticsFeedbackRow>> getFeedback(String uid) async {
    final snapshot = await _feedback(uid).orderBy('timestamp', descending: true).limit(200).get();
    return snapshot.docs
        .map(
          (doc) => AnalyticsFeedbackRow(
            doc.id,
            (doc.data()['productId'] as String?) ?? '',
            (doc.data()['liked'] as bool?) ?? false,
            (doc.data()['context'] as String?) ?? 'home',
          ),
        )
        .toList();
  }

  /// بيمسح كل تقييمات التوصيات
  /// (حق "النسيان" في إعدادات
  /// الخصوصية).
  Future<void> clearFeedback(String uid) async {
    final snapshot = await _feedback(uid).get();
    final batch = firestore.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}

/// صف تقييم خام (قبل التحويل للـ Entity).
class AnalyticsFeedbackRow {
  final String id;
  final String productId;
  final bool liked;
  final String context;

  const AnalyticsFeedbackRow(
    this.id,
    this.productId,
    this.liked,
    this.context,
  );
}
