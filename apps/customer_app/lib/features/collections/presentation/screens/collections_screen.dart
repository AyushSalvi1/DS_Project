import 'package:cached_network_image/cached_network_image.dart';
import 'package:customer_app/features/collections/presentation/cubit/collections_cubit.dart';
import 'package:customer_app/features/collections/presentation/cubit/collections_state.dart';
import 'package:customer_app/features/product/presentation/cubit/product_cubit.dart';
import 'package:customer_app/features/product/presentation/cubit/product_state.dart';
import 'package:customer_app/features/product/presentation/screens/product_detail_screen.dart';
import 'package:customer_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:customer_app/features/auth/presentation/cubit/auth_state.dart';
import 'package:decoze_core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// شاشة المجموعات —
/// مجموعات منتجات مبنية
/// بالذكاء الاصطناعي من
/// وصف المستخدم النصي.
class CollectionsScreen extends StatelessWidget {
  const CollectionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    final uid = authState is AuthAuthenticated ? authState.user.uid : '';

    return BlocProvider(
      create: (_) => CollectionsCubit(
        repository: CollectionRepositoryImpl(),
        productRepository: ProductRepositoryImpl(),
        uid: uid,
      ),
      // Builder عشان الـ context اللي
      // بيُستخدم في الفاب يكون تحت
      // الـ BlocProvider (مش فوقه).
      child: Builder(
        builder: (context) => Scaffold(
          appBar: AppBar(title: Text(context.strings.collectionsTitle)),
          body: const _CollectionsBody(),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showBuilderSheet(context),
            icon: const Icon(Icons.auto_awesome),
            label: Text(context.strings.collectionsNew),
          ),
        ),
      ),
    );
  }

  void _showBuilderSheet(BuildContext context) {
    final strings = context.strings;
    final cubit = context.read<CollectionsCubit>();
    final briefController = TextEditingController();
    final nameController = TextEditingController();
    final budgetController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              strings.collectionBuilderTitle,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              strings.collectionBuilderHint,
              style: TextStyle(
                color: BrandConfig.decoze.textSecondary,
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: briefController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: strings.collectionBuilderExample,
                hintText: 'modern living room under 500',
                border: const OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: strings.collectionBuilderName,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: budgetController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: strings.collectionBuilderBudget,
                border: const OutlineInputBorder(),
                prefixText: '${BrandConfig.decoze.currencySymbol} ',
              ),
            ),
            const SizedBox(height: 20),

            BlocProvider.value(
              value: cubit,
              child: BlocBuilder<CollectionsCubit, CollectionsState>(
              builder: (context, state) {
                final building = state is CollectionsLoading;
                return SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: building
                        ? null
                        : () {
                            final brief =
                                briefController.text.trim();
                            if (brief.isEmpty) return;

                            final budget =
                                double.tryParse(
                                  budgetController.text,
                                );
                            cubit.buildCollection(
                                  brief: brief,
                                  name: nameController
                                      .text
                                      .trim()
                                      .isEmpty
                                      ? null
                                      : nameController
                                          .text
                                          .trim(),
                                  budget: budget,
                                );
                            Navigator.of(context).pop();
                          },
                    child: building
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child:
                                CircularProgressIndicator(
                              strokeWidth: 2,
                              color: BrandConfig
                                  .decoze.onAccent,
                            ),
                          )
                        : Text(strings.collectionBuilderBuild),
                  ),
                );
              },
            ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CollectionsBody extends StatelessWidget {
  const _CollectionsBody();

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;

    return BlocBuilder<CollectionsCubit, CollectionsState>(
      builder: (context, state) {
        if (state is! CollectionsLoaded) {
          return const Center(child: CircularProgressIndicator());
        }

        final collections = state.collections;
        if (collections.isEmpty) {
          return _EmptyState(strings: strings);
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: collections.length,
          itemBuilder: (context, index) {
            return _CollectionCard(
              collection: collections[index],
            );
          },
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
              CollectionsIcon,
              size: 64,
              color: brand.accent,
            ),
            const SizedBox(height: 16),
            Text(
              strings.collectionsEmpty,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              strings.collectionsEmptyHint,
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

// ignore: constant_identifier_names
const IconData CollectionsIcon = Icons.collections_bookmark_outlined;

class _CollectionCard extends StatelessWidget {
  final CollectionEntity collection;

  const _CollectionCard({required this.collection});

  @override
  Widget build(BuildContext context) {
    const brand = BrandConfig.decoze;
    final strings = context.strings;

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // العنوان والبيانات.
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              collection.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          if (collection.aiGenerated)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: brand.accent
                                    .withValues(alpha: 0.15),
                                borderRadius:
                                    BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.auto_awesome,
                                    size: 12,
                                    color: brand.accent,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'AI',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: brand.accent,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      if (collection.description.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            collection.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              color: brand.textSecondary,
                            ),
                          ),
                        ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          if (collection.style != null)
                            _MetaChip(
                              label: collection.style!,
                            ),
                          if (collection.budget != null) ...[
                            const SizedBox(width: 6),
                            _MetaChip(
                              label:
                                  '${strings.collectionTotal}: ${brand.currencySymbol} ${collection.budget!.toStringAsFixed(0)}',
                            ),
                          ],
                          const Spacer(),
                          Text(
                            '${collection.productIds.length} ${strings.collectionProducts}',
                            style: TextStyle(
                              fontSize: 12,
                              color: brand.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // حذف المجموعة.
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _confirmDelete(context),
                ),
              ],
            ),
          ),

          // منتجات المجموعة.
          if (collection.productIds.isNotEmpty)
            SizedBox(
              height: 120,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                itemCount: collection.productIds.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  return _CollectionProductTile(
                    collectionId: collection.id,
                    productId: collection.productIds[index],
                  );
                },
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.all(14),
              child: Text(
                strings.collectionsEmpty,
                style: TextStyle(
                  color: brand.textSecondary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    final strings = context.strings;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(strings.collectionDelete),
        content: Text(strings.collectionDeleteConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(strings.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context
                  .read<CollectionsCubit>()
                  .deleteCollection(collection.id);
            },
            child: Text(strings.collectionDelete),
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final String label;

  const _MetaChip({required this.label});

  @override
  Widget build(BuildContext context) {
    const brand = BrandConfig.decoze;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: brand.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: brand.textSecondary,
        ),
      ),
    );
  }
}

/// منتج داخل المجموعة —
/// بيحمل المنتج بالـ ID
/// وبيعمل زرار إزالة.
class _CollectionProductTile extends StatelessWidget {
  final String collectionId;
  final String productId;

  const _CollectionProductTile({
    required this.collectionId,
    required this.productId,
  });

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
              width: 90,
              height: 120,
              decoration: BoxDecoration(
                color: brand.surface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            );
          }

          final product = state.product;

          return Stack(
            children: [
              InkWell(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        ProductDetailScreen(productId: product.id),
                  ),
                ),
                child: Container(
                  width: 90,
                  decoration: BoxDecoration(
                    color: brand.surface,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                          ),
                          child: CachedNetworkImage(
                            imageUrl: product.thumbnail,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Container(
                              color: brand.primaryBackground,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.all(6),
                          child: Text(
                            product.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 2,
                right: 2,
                child: InkWell(
                  onTap: () => context
                      .read<CollectionsCubit>()
                      .removeFromCollection(
                        collectionId,
                        productId,
                      ),
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
