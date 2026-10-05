import 'package:cloud_firestore/cloud_firestore.dart';

/// مصدر بيانات تفضيلات التسوق وإعدادات
/// الخصوصية — مستند واحد لكل مستخدم
/// (`users/{uid}/preferences`).
class PreferencesRemoteDataSource {
  final FirebaseFirestore firestore;

  PreferencesRemoteDataSource({FirebaseFirestore? firestore})
      : firestore = firestore ?? FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> _prefsDoc(String uid) =>
      firestore.collection('users').doc(uid).collection('profile').doc('preferences');

  DocumentReference<Map<String, dynamic>> _privacyDoc(String uid) =>
      firestore.collection('users').doc(uid).collection('profile').doc('privacy');

  Stream<Map<String, dynamic>?> watchPreferences(String uid) {
    return _prefsDoc(uid).snapshots().map(
          (doc) => doc.data(),
        );
  }

  Future<void> savePreferences(String uid, Map<String, dynamic> data) {
    return _prefsDoc(uid).set(data, SetOptions(merge: true));
  }

  Stream<Map<String, dynamic>?> watchPrivacySettings(String uid) {
    return _privacyDoc(uid).snapshots().map((doc) => doc.data());
  }

  Future<void> savePrivacySettings(
    String uid,
    Map<String, dynamic> data,
  ) {
    return _privacyDoc(uid).set(data, SetOptions(merge: true));
  }
}
