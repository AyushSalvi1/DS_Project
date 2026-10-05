import 'package:cached_network_image/cached_network_image.dart';
import 'package:customer_app/features/alternatives/presentation/cubit/alternatives_cubit.dart';
import 'package:customer_app/features/alternatives/presentation/cubit/alternatives_state.dart';
import 'package:customer_app/features/product/presentation/screens/product_detail_screen.dart';
import 'package:decoze_core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// شاشة البدائل — أرخص /
/// أفضل / مشابه / أحدث
/// مع السبب والوفورات.
class AlternativesScreen extends StatelessWidget {
  final String productId;

  const AlternativesScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.strings.alternativesTitle)),
      body: BlocProvider(
        create: (_) => AlternativesCubit()..find(productId),
        child: BlocBuilder<AlternativesCubit, AlternativesState>(
          builder: (context, state) {
            return switch (state) {
              AlternativesInitial() || AlternativesLoading() =>
                const Center(child: CircularProgressIndicator()),
              AlternativesError(:final message) =>
                Center(child: Text(message)),
              AlternativesLoaded(:final original, :final alternatives) =>
                _AlternativesContent(
                    original: original,
                    alternatives: alternatives,
                  ),
            };
          },
        ),
      ),
    );
  }
}

class _AlternativesContent extends StatelessWidget {
  final ProductEntity original;
  final List<AlternativeProduct> alternatives;

  const _AlternativesContent({
    required this.original,
    required this.alternatives,
  });

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // المنتج الأصلي.
        _OriginalCard(product: original),
        const SizedBox(height: 20),

        // فلاتر النوع.
        Text(
          '${strings.alternativesTitle} (${alternatives.length})',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),

        if (alternatives.isEmpty)
          _EmptyState(strings: strings)
        else
          for (final alt in alternatives)
            _AlternativeCard(alternative: alt),
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: brand.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: brand.accent.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: CachedNetworkImage(
              imageUrl: product.thumbnail,
              width: 64,
              height: 64,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(
                width: 64,
                height: 64,
                color: brand.primaryBackground,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  '${brand.currencySymbol} ${product.price.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: brand.accent,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward,
            color: brand.textSecondary,
          ),
        ],
      ),
    );
  }
}

class _AlternativeCard extends StatelessWidget {
  final AlternativeProduct alternative;

  const _AlternativeCard({required this.alternative});

  @override
  Widget build(BuildContext context) {
    const brand = BrandConfig.decoze;
    final strings = context.strings;
    final product = alternative.product;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ProductDetailScreen(productId: product.id),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CachedNetworkImage(
                  imageUrl: product.thumbnail,
                  width: 70,
                  height: 70,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    width: 70,
                    height: 70,
                    color: brand.primaryBackground,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // النوع + التوفير.
                    Row(
                      children: [
                        _TypeChip(
                          type: alternative.type,
                        ),
                        if (alternative.savings != null) ...[
                          const SizedBox(width: 8),
                          _SavingsChip(
                            savings: alternative.savings!,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          '${brand.currencySymbol} ${product.price.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: brand.accent,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Icon(Icons.star, size: 14, color: Colors.amber),
                        Text(product.rating.toStringAsFixed(1)),
                        const SizedBox(width: 10),
                        // درجة الملاءمة.
                        Icon(
                          Icons.verified_user,
                          size: 14,
                          color: brand.textSecondary,
                        ),
                        Text(
                          '${alternative.score.toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontSize: 12,
                            color: brand.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // السبب.
                    Text(
                      alternative.reason,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: brand.textSecondary,
                      ),
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

class _TypeChip extends StatelessWidget {
  final AlternativeType type;

  const _TypeChip({required this.type});

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    const brand = BrandConfig.decoze;

    final (label, icon) = switch (type) {
      AlternativeType.cheaper => (
          strings.alternativesCheaper,
          Icons.savings_outlined,
        ),
      AlternativeType.better => (
          strings.alternativesBetter,
          Icons.thumb_up_outlined,
        ),
      AlternativeType.similar => (
          strings.alternativesSimilar,
          Icons.similar_outlined,
        ),
      AlternativeType.newer => (
          strings.alternativesNewer,
          Icons.new_releases_outlined,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: brand.accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: brand.accent),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: brand.accent,
            ),
          ),
        ],
      ),
    );
  }
}

class _SavingsChip extends StatelessWidget {
  final double savings;

  const _SavingsChip({required this.savings});

  @override
  Widget build(BuildContext context) {
    const brand = BrandConfig.decoze;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '${context.strings.alternativesSavings}: ${brand.currencySymbol} ${savings.toStringAsFixed(2)}',
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.green,
        ),
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
              Icons.change_circle_outlined,
              size: 48,
              color: brand.textSecondary,
            ),
            const SizedBox(height: 12),
            Text(
              strings.alternativesEmpty,
              textAlign: TextAlign.center,
              style: TextStyle(color: brand.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
