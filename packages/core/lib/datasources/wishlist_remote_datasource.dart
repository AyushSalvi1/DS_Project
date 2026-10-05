import 'package:cloud_firestore/cloud_firestore.dart';

import '../entities/wishlist_item_entity.dart';

/// مصدر بيانات قائمة الرغبات الذكية —
/// تحت مستند المستخدم، بمفتاح = productId
/// عشان المنتج مش بيتكرر في القائمة.
class WishlistRemoteDataSource {
  final FirebaseFirestore firestore;

  WishlistRemoteDataSource({FirebaseFirestore? firestore})
      : firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _wishlist(String uid) =>
      firestore.collection('users').doc(uid).collection('wishlist');

  Stream<List<WishlistItemEntity>> watchWishlist(String uid) {
    return _wishlist(uid).orderBy('addedAt', descending: true).snapshots().map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => WishlistItemEntity.fromJson(
                  uid,
                  doc.id,
                  doc.data(),
                ),
              )
              .toList(),
        );
  }

  Future<void> addItem(String uid, String productId) {
    return _wishlist(uid).doc(productId).set({
      'addedAt': DateTime.now().toIso8601String(),
      'notifyOnPriceDrop': true,
      'notifyOnAvailability': false,
    });
  }

  Future<void> removeItem(String uid, String productId) {
    return _wishlist(uid).doc(productId).delete();
  }

  Future<void> setField(
    String uid,
    String productId,
    Map<String, dynamic> data,
  ) {
    return _wishlist(uid).doc(productId).set(data, SetOptions(merge: true));
  }

  Future<bool> isInWishlist(String uid, String productId) async {
    final doc = await _wishlist(uid).doc(productId).get();
    return doc.exists;
  }
}
