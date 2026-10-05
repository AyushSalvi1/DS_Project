import 'package:cached_network_image/cached_network_image.dart';
import 'package:customer_app/features/product/presentation/screens/product_detail_screen.dart';
import 'package:customer_app/features/wishlist/presentation/cubit/wishlist_cubit.dart';
import 'package:customer_app/features/wishlist/presentation/cubit/wishlist_state.dart';
import 'package:customer_app/features/wishlist/presentation/widgets/target_price_sheet.dart';
import 'package:customer_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:customer_app/features/auth/presentation/cubit/auth_state.dart';
import 'package:decoze_core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// شاشة قائمة الرغبات الذكية —
/// منتجات محفوظة مع تتبع
/// السعر المستهدف وتنبيهات
/// الانخفاض والتوفر.
class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    final uid = authState is AuthAuthenticated ? authState.user.uid : '';

    return Scaffold(
      appBar: AppBar(title: Text(context.strings.wishlistTitle)),
      body: BlocProvider(
        create: (_) => WishlistCubit(
          repository: WishlistRepositoryImpl(
            productRepository: ProductRepositoryImpl(),
          ),
          uid: uid,
        ),
        child: const _WishlistBody(),
      ),
    );
  }
}

class _WishlistBody extends StatelessWidget {
  const _WishlistBody();

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;

    return BlocBuilder<WishlistCubit, WishlistState>(
      builder: (context, state) {
        if (state is! WishlistLoaded) {
          return const Center(child: CircularProgressIndicator());
        }

        final items = state.items;
        if (items.isEmpty) {
          return _EmptyState(strings: strings);
        }

        return RefreshIndicator(
          onRefresh: () async {
            // البث المباشر بحدث
            // تلقائي — مفيش حاجة
            // نشطالها هنا.
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final product = state.products[item.productId];
              return _WishlistTile(
                item: item,
                product: product,
              );
            },
          ),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  final AppStrings strings;

  const _EmptyState({required this.strings});

  @override
  Widget build(BuildContext context) {
    const brand = BrandConfig.decoze;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border,
              size: 64,
              color: brand.accent,
            ),
            const SizedBox(height: 16),
            Text(
              strings.wishlistEmpty,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              strings.wishlistEmptyHint,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: brand.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WishlistTile extends StatelessWidget {
  final WishlistItemEntity item;
  final ProductEntity? product;

  const _WishlistTile({required this.item, required this.product});

  @override
  Widget build(BuildContext context) {
    const brand = BrandConfig.decoze;
    final strings = context.strings;

    final productId = item.productId;
    final name = product?.name ?? productId;
    final price = product?.price;
    final target = item.targetPrice;

    // حالة السعر المستهدف.
    final (statusLabel, statusColor) = _targetStatus(
      price,
      target,
      strings,
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: product == null
            ? null
            : () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        ProductDetailScreen(productId: productId),
                  ),
                ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // صورة المنتج.
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: product == null
                    ? Container(
                        width: 64,
                        height: 64,
                        color: brand.surface,
                      )
                    : CachedNetworkImage(
                        imageUrl: product!.thumbnail,
                        width: 64,
                        height: 64,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(
                          width: 64,
                          height: 64,
                          color: brand.surface,
                        ),
                      ),
              ),
              const SizedBox(width: 14),

              // البيانات.
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (price != null)
                      Text(
                        '${strings.wishlistCurrentPrice}: ${brand.currencySymbol} ${price.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: brand.accent,
                        ),
                      ),
                    if (target != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        '${strings.wishlistTargetPrice}: ${brand.currencySymbol} ${target.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        statusLabel,
                        style: TextStyle(
                          fontSize: 11,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // أزرار.
              Column(
                children: [
                  // السعر المستهدف.
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    tooltip: strings.wishlistAddTarget,
                    onPressed: () => _showTargetSheet(context),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    tooltip: strings.wishlistRemove,
                    onPressed: () => context
                        .read<WishlistCubit>()
                        .removeItem(productId),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  (String, Color) _targetStatus(
    double? price,
    double? target,
    AppStrings strings,
  ) {
    if (target == null || price == null) {
      return (strings.optional, BrandConfig.decoze.textSecondary);
    }
    if (price <= target) {
      return (
        strings.wishlistTargetReached,
        Colors.green,
      );
    }
    return (
      strings.wishlistAboveTarget,
      BrandConfig.decoze.accent,
    );
  }

  void _showTargetSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => BlocProvider.value(
        value: context.read<WishlistCubit>(),
        child: TargetPriceSheet(
          productId: item.productId,
          currentTarget: item.targetPrice,
        ),
      ),
    );
  }
}
