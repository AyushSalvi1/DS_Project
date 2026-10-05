import 'package:cloud_firestore/cloud_firestore.dart';

import '../entities/user_activity_entity.dart';

/// مصدر بيانات ذاكرة التسوق — سجل
/// النشاط تحت مستند المستخدم.
class ActivityRemoteDataSource {
  final FirebaseFirestore firestore;

  ActivityRemoteDataSource({FirebaseFirestore? firestore})
      : firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _activity(String uid) =>
      firestore.collection('users').doc(uid).collection('activity');

  Future<void> recordActivity(UserActivityEntity activity) {
    return _activity(activity.uid).doc(activity.id).set(activity.toJson());
  }

  Stream<List<UserActivityEntity>> watchRecentActivity(
    String uid, {
    int limit = 50,
  }) {
    return _activity(uid)
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => UserActivityEntity.fromJson(doc.id, doc.data()))
              .toList(),
        );
  }

  Future<List<UserActivityEntity>> getActivity(
    String uid, {
    int limit = 200,
  }) async {
    final snapshot =
        await _activity(uid).orderBy('timestamp', descending: true).limit(limit).get();
    return snapshot.docs
        .map((doc) => UserActivityEntity.fromJson(doc.id, doc.data()))
        .toList();
  }

  /// آخر عمليات بحث فريدة (بترتيب الأحدث).
  Stream<List<String>> watchRecentSearches(String uid, {int limit = 10}) {
    return watchRecentActivity(uid, limit: 100).map((activities) {
      final seen = <String>{};
      final searches = <String>[];
      for (final activity in activities) {
        if (activity.type != ActivityType.search) continue;
        final query = activity.query;
        if (query == null || query.trim().isEmpty) continue;
        final normalized = query.trim().toLowerCase();
        if (seen.contains(normalized)) continue;
        seen.add(normalized);
        searches.add(query.trim());
        if (searches.length >= limit) break;
      }
      return searches;
    });
  }

  Future<void> clearActivity(String uid) {
    return _activity(uid).get().then((snapshot) {
      final batch = firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      return batch.commit();
    });
  }
}
