import 'package:cloud_firestore/cloud_firestore.dart';

import '../entities/collection_entity.dart';

/// مصدر بيانات المجموعات (AI collections) —
/// تحت مستند المستخدم.
class CollectionRemoteDataSource {
  final FirebaseFirestore firestore;

  CollectionRemoteDataSource({FirebaseFirestore? firestore})
      : firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _collections(String uid) =>
      firestore.collection('users').doc(uid).collection('collections');

  Stream<List<CollectionEntity>> watchCollections(String uid) {
    return _collections(uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => CollectionEntity.fromJson(doc.id, doc.data()))
              .toList(),
        );
  }

  Future<void> createCollection(CollectionEntity collection) {
    return _collections(collection.uid)
        .doc(collection.id)
        .set(collection.toJson());
  }

  Future<void> updateCollection(CollectionEntity collection) {
    return _collections(collection.uid)
        .doc(collection.id)
        .update(collection.toJson());
  }

  Future<void> deleteCollection(String uid, String collectionId) {
    return _collections(uid).doc(collectionId).delete();
  }
}
