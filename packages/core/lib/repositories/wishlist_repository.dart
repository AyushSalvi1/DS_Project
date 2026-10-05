import '../entities/product_entity.dart';
import '../entities/wishlist_item_entity.dart';

/// عقد قائمة الرغبات الذكية — مع تتبع السعر
/// وتنبيهات الانخفاض والتوفر.
abstract class WishlistRepository {
  /// بث مباشر لعناصر قائمة الرغبات مع أسعارها
  /// الحالية من المواقع الخارجية (لو متوفر).
  Stream<List<WishlistItemEntity>> watchWishlist(String uid);

  /// بنفس الـ IDs محمّلة بالمنتجات الكاملة.
  Future<List<ProductEntity>> loadProducts(
    String uid,
    List<String> productIds,
  );

  Future<void> addItem(String uid, String productId);
  Future<void> removeItem(String uid, String productId);
  Future<void> setTargetPrice(
    String uid,
    String productId,
    double? targetPrice,
  );
  Future<void> setNotifyOnPriceDrop(
    String uid,
    String productId,
    bool enabled,
  );
  Future<void> setNotifyOnAvailability(
    String uid,
    String productId,
    bool enabled,
  );
  Future<bool> isInWishlist(String uid, String productId);
}
