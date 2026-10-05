import 'package:cached_network_image/cached_network_image.dart';
import 'package:customer_app/features/product/presentation/screens/product_detail_screen.dart';
import 'package:customer_app/features/compatibility/presentation/cubit/compatibility_cubit.dart';
import 'package:customer_app/features/compatibility/presentation/cubit/compatibility_state.dart';
import 'package:decoze_core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// شاشة التوافق — منتجات
/// متناسقة مع المنتج
/// الحالي ("بتكمل بعض").
class CompatibilityScreen extends StatelessWidget {
  final String productId;

  const CompatibilityScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    final uid = authState is AuthAuthenticated ? authState.user.uid : '';

    return Scaffold(
      appBar: AppBar(title: Text(context.strings.compatibilityTitle)),
      body: BlocProvider(
        create: (_) => CompatibilityCubit()..find(productId, uid),
        child: BlocBuilder<CompatibilityCubit, CompatibilityState>(
          builder: (context, state) {
            return switch (state) {
              CompatibilityInitial() || CompatibilityLoading() =>
                const Center(child: CircularProgressIndicator()),
              CompatibilityError(:final message) =>
                Center(child: Text(message)),
              CompatibilityLoaded(:final product, :final compatible) =>
                _CompatibilityContent(
                    product: product,
                    compatible: compatible,
                  ),
            };
          },
        ),
      ),
    );
  }
}

class _CompatibilityContent extends StatelessWidget {
  final ProductEntity product;
  final List<CompatibilityEntity> compatible;

  const _CompatibilityContent({
    required this.product,
    required this.compatible,
  });

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // المنتج الأصلي.
        _OriginalCard(product: product),
        const SizedBox(height: 8),
        Text(
          strings.compatibilitySubtitle,
          style: TextStyle(
            color: BrandConfig.decoze.textSecondary,
          ),
        ),
        const SizedBox(height: 16),

        if (compatible.isEmpty)
          _EmptyState(strings: strings)
        else
          for (final item in compatible)
            _CompatibleTile(compatible: item),
      ],
    );
  }
}

class _OriginalCard extends StatelessWidget {
  final ProductEntity product;

  const _OriginalCard({required this.product});

  @override
  Widget build(BuildContext context) {
    const brand = BrandConfig.decoze;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: brand.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: brand.accent.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: product.thumbnail,
              width: 48,
              height: 48,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(
                width: 48,
                height: 48,
                color: brand.primaryBackground,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              product.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: brand.accent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              context.strings.compatibilityGoesWith,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: brand.accent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompatibleTile extends StatelessWidget {
  final CompatibilityEntity compatible;

  const _CompatibleTile({required this.compatible});

  @override
  Widget build(BuildContext context) {
    const brand = BrandConfig.decoze;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) =>
                ProductDetailScreen(productId: compatible.compatibleProductId),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              _CompatibleProductImage(
                productId: compatible.compatibleProductId,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // السبب.
                    Text(
                      compatible.reason,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // درجة التوافق.
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: compatible.score / 100,
                              minHeight: 5,
                              backgroundColor: brand.primaryBackground,
                              valueColor: const AlwaysStoppedAnimation(
                                BrandConfig.decoze.accent,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${compatible.score.toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: brand.accent,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

/// صورة المنتج المتوافق —
/// بيحمل المنتج بالـ ID.
class _CompatibleProductImage extends StatelessWidget {
  final String productId;

  const _CompatibleProductImage({required this.productId});

  @override
  Widget build(BuildContext context) {
    const brand = BrandConfig.decoze;

    return BlocProvider(
      create: (_) => ProductCubit(productRepository: ProductRepositoryImpl())
        ..loadProduct(productId),
      child: BlocBuilder<ProductCubit, ProductState>(
        builder: (context, state) {
          if (state is! ProductLoaded) {
            return Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: brand.surface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            );
          }

          return ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: state.product.thumbnail,
              width: 48,
              height: 48,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(
                width: 48,
                height: 48,
                color: brand.surface,
              ),
            ),
          );
        },
      ),
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
          children: [
            Icon(
              Icons.chair_outlined,
              size: 48,
              color: brand.textSecondary,
            ),
            const SizedBox(height: 12),
            Text(
              strings.compatibilityEmpty,
              textAlign: TextAlign.center,
              style: TextStyle(color: brand.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
