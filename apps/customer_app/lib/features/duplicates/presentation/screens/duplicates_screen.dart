import 'package:cached_network_image/cached_network_image.dart';
import 'package:customer_app/features/product/presentation/screens/product_detail_screen.dart';
import 'package:customer_app/features/duplicates/presentation/cubit/duplicates_cubit.dart';
import 'package:customer_app/features/duplicates/presentation/cubit/duplicates_state.dart';
import 'package:decoze_core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

/// شاشة كشف التكرار —
/// نفس المنتج متلاقي
/// في أكتر من موقع/تاجر.
class DuplicatesScreen extends StatelessWidget {
  const DuplicatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.strings.duplicatesTitle)),
      body: BlocProvider(
        create: (_) => DuplicatesCubit()..scan(),
        child: BlocBuilder<DuplicatesCubit, DuplicatesState>(
          builder: (context, state) {
            return switch (state) {
              DuplicatesInitial() || DuplicatesLoading() =>
                const Center(child: CircularProgressIndicator()),
              DuplicatesError(:final message) =>
                Center(child: Text(message)),
              DuplicatesLoaded() => _DuplicatesContent(state: state),
            };
          },
        ),
      ),
    );
  }
}

class _DuplicatesContent extends StatelessWidget {
  final DuplicatesLoaded state;

  const _DuplicatesContent({required this.state});

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final groups = state.groups;

    if (groups.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            strings.duplicatesEmpty,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: BrandConfig.decoze.textSecondary,
            ),
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // العدد.
        Row(
          children: [
            Text(
              strings.duplicatesFound,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: BrandConfig.decoze.accent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${groups.length}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: BrandConfig.decoze.onAccent,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        for (final group in groups)
          _DuplicateGroupCard(
            group: group,
            state: state,
          ),
      ],
    );
  }
}

class _DuplicateGroupCard extends StatelessWidget {
  final DuplicateGroup group;
  final DuplicatesLoaded state;

  const _DuplicateGroupCard({required this.group, required this.state});

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    const brand = BrandConfig.decoze;

    final canonical = state.productsById[group.canonicalProductId];
    final canonicalName = canonical?.name ?? group.canonicalProductId;

    // العروض الخارجية اللي
    // طابقت المنتج.
    final matchedListings = group.listingIds
        .map((id) => state.listingsById[id])
        .whereType<ExternalListingEntity>()
        .toList();

    // المنتجات المحلية المكررة.
    final matchedProducts = group.productIds
        .map((id) => state.productsById[id])
        .whereType<ProductEntity>()
        .toList();

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // المنتج المرجعي.
            Row(
              children: [
                if (canonical != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: canonical.thumbnail,
                      width: 44,
                      height: 44,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        width: 44,
                        height: 44,
                        color: brand.surface,
                      ),
                    ),
                  )
                else
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: brand.surface,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.search),
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    canonicalName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // درجة التشابه.
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      strings.duplicatesConfidence,
                      style: TextStyle(
                        fontSize: 10,
                        color: brand.textSecondary,
                      ),
                    ),
                    Text(
                      '${(group.similarity * 100).roundToDouble()}%',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: brand.accent,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),

            // العروض الخارجية.
            if (matchedListings.isNotEmpty) ...[
              Text(
                strings.duplicatesAlsoAt,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: brand.textSecondary,
                ),
              ),
              const SizedBox(height: 6),
              for (final listing in matchedListings)
                _ListingRow(listing: listing),
              const SizedBox(height: 8),
            ],

            // المنتجات المحلية المكررة.
            if (matchedProducts.isNotEmpty) ...[
              Text(
                strings.duplicatesSimilar,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: brand.textSecondary,
                ),
              ),
              const SizedBox(height: 6),
              for (final product in matchedProducts)
                _LocalProductRow(product: product),
            ],
          ],
        ),
      ),
    );
  }

  /// صف عرض خارجي مع
  /// زر فتح الموقع.
  Widget _ListingRow(ExternalListingEntity listing) {
    return Builder(
      builder: (context) {
        const brand = BrandConfig.decoze;

        return Container(
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: brand.primaryBackground,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                Icons.public,
                size: 16,
                color: brand.textSecondary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      listing.merchantId,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${BrandConfig.decoze.currencySymbol} ${listing.effectivePrice.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 11,
                        color: brand.accent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.open_in_new, size: 18),
                tooltip: context.strings.openInBrowser,
                onPressed: () async {
                  final uri = Uri.tryParse(listing.productUrl);
                  if (uri != null && await canLaunchUrl(uri)) {
                    await launchUrl(
                      uri,
                      mode: LaunchMode.externalApplication,
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// صف منتج محلي مكرر.
  Widget _LocalProductRow(ProductEntity product) {
    return Builder(
      builder: (context) {
        const brand = BrandConfig.decoze;

        return Container(
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: brand.primaryBackground,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: CachedNetworkImage(
                  imageUrl: product.thumbnail,
                  width: 32,
                  height: 32,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    width: 32,
                    height: 32,
                    color: brand.surface,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              Text(
                '${brand.currencySymbol} ${product.price.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 11,
                  color: brand.accent,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios, size: 16),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        ProductDetailScreen(productId: product.id),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
