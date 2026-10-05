import '../datasources/wishlist_remote_datasource.dart';
import '../entities/product_entity.dart';
import '../entities/wishlist_item_entity.dart';
import '../repositories/product_repository.dart';
import '../repositories/wishlist_repository.dart';

/// تنفيذ قائمة الرغبات الذكية —
/// IDs من Firestore + تفاصيل المنتجات
/// من ProductRepository (نفس مبدأ
/// FavouriteRepository بالظبط).
class WishlistRepositoryImpl implements WishlistRepository {
  final WishlistRemoteDataSource remoteDataSource;
  final ProductRepository _productRepository;

  WishlistRepositoryImpl({
    WishlistRemoteDataSource? remoteDataSource,
    required ProductRepository productRepository,
  })  : remoteDataSource = remoteDataSource ?? WishlistRemoteDataSource(),
        _productRepository = productRepository;

  @override
  Stream<List<WishlistItemEntity>> watchWishlist(String uid) {
    return remoteDataSource.watchWishlist(uid);
  }

  @override
  Future<List<ProductEntity>> loadProducts(
    String uid,
    List<String> productIds,
  ) async {
    final futures = productIds.map((id) async {
      try {
        return await _productRepository.getProductById(id);
      } catch (_) {
        return null;
      }
    });
    final results = await Future.wait(futures);
    return results.whereType<ProductEntity>().toList();
  }

  @override
  Future<void> addItem(String uid, String productId) {
    return remoteDataSource.addItem(uid, productId);
  }

  @override
  Future<void> removeItem(String uid, String productId) {
    return remoteDataSource.removeItem(uid, productId);
  }

  @override
  Future<void> setTargetPrice(
    String uid,
    String productId,
    double? targetPrice,
  ) {
    if (targetPrice == null) {
      return remoteDataSource.setField(
        uid,
        productId,
        {'targetPrice': null, 'notifyOnPriceDrop': false},
      );
    }
    return remoteDataSource.setField(
      uid,
      productId,
      {'targetPrice': targetPrice, 'notifyOnPriceDrop': true},
    );
  }

  @override
  Future<void> setNotifyOnPriceDrop(
    String uid,
    String productId,
    bool enabled,
  ) {
    return remoteDataSource.setField(
      uid,
      productId,
      {'notifyOnPriceDrop': enabled},
    );
  }

  @override
  Future<void> setNotifyOnAvailability(
    String uid,
    String productId,
    bool enabled,
  ) {
    return remoteDataSource.setField(
      uid,
      productId,
      {'notifyOnAvailability': enabled},
    );
  }

  @override
  Future<bool> isInWishlist(String uid, String productId) {
    return remoteDataSource.isInWishlist(uid, productId);
  }
}
