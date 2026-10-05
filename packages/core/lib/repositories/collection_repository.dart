import '../entities/collection_entity.dart';
import '../entities/product_entity.dart';

/// عقد "AI setup / collection builder" —
/// المستخدم يوصف الإعداد بكلماته والذكاء
/// الاصطناعي بيختار المنتجات المناسبة.
abstract class CollectionRepository {
  /// بث مباشر لمجموعات المستخدم.
  Stream<List<CollectionEntity>> watchCollections(String uid);

  /// يبني مجموعة من وصف نصي (brief) — بيستخدم
  /// الذكاء الاصطناعي لاختيار المنتجات من الكتالوج.
  Future<CollectionEntity> createFromBrief({
    required String uid,
    required String brief,
    String? name,
    double? budget,
    required List<ProductEntity> catalog,
  });

  Future<void> addToCollection(
    String uid,
    String collectionId,
    String productId,
  );
  Future<void> removeFromCollection(
    String uid,
    String collectionId,
    String productId,
  );
  Future<void> deleteCollection(String uid, String collectionId);
  Future<void> renameCollection(
    String uid,
    String collectionId,
    String name,
  );
}
