import 'package:cached_network_image/cached_network_image.dart';
import 'package:customer_app/features/compare/presentation/cubit/compare_cubit.dart';
import 'package:customer_app/features/compare/presentation/cubit/compare_state.dart';
import 'package:customer_app/features/product/presentation/screens/product_detail_screen.dart';
import 'package:decoze_core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// شاشة المقارنة الذكية —
/// جدول معايير (سعر/تقييم/
/// توفر/قيمة...) مع إبراز
/// الأفضل في كل معيار + الفائز
/// + ملخص الذكاء الاصطناعي.
class CompareScreen extends StatelessWidget {
  final List<ProductEntity> products;

  const CompareScreen({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.strings.compareTitle)),
      body: BlocProvider(
        create: (_) => CompareCubit()..compare(products),
        child: BlocBuilder<CompareCubit, CompareState>(
          builder: (context, state) {
            return switch (state) {
              CompareInitial() || CompareLoading() =>
                const Center(child: CircularProgressIndicator()),
              CompareError(:final message) =>
                Center(child: Text(message)),
              CompareLoaded(:final result) =>
                _CompareContent(result: result),
            };
          },
        ),
      ),
    );
  }
}

class _CompareContent extends StatelessWidget {
  final ComparisonResult result;

  const _CompareContent({required this.result});

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final products = result.products;
    if (products.isEmpty) {
      return Center(child: Text(strings.compareEmpty));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      scrollDirection: Axis.vertical,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ملخص الذكاء الاصطناعي.
          if (result.summary.isNotEmpty) ...[
            _SummaryCard(summary: result.summary, reasons: result.reasons),
            const SizedBox(height: 16),
          ],

          // الفائز.
          if (result.winnerId != null) ...[
            _WinnerBanner(result: result),
            const SizedBox(height: 16),
          ],

          // جدول المعايير.
          Text(
            strings.compareWhy,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          _CriteriaTable(result: result),
          const SizedBox(height: 16),

          // كروت المنتجات.
          Text(
            strings.compareProducts,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 210,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: products.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final product = products[index];
                final isWinner = product.id == result.winnerId;
                return _ProductCard(product: product, isWinner: isWinner);
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// بطاقة ملخص الذكاء الاصطناعي
/// + أسباب الاختيار.
class _SummaryCard extends StatelessWidget {
  final String summary;
  final List<String> reasons;

  const _SummaryCard({required this.summary, required this.reasons});

  @override
  Widget build(BuildContext context) {
    const brand = BrandConfig.decoze;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: brand.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: brand.accent.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, size: 18, color: brand.accent),
              const SizedBox(width: 8),
              Text(
                context.strings.compareSummary,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: brand.accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(summary),
          if (reasons.isNotEmpty) ...[
            const SizedBox(height: 12),
            for (final reason in reasons)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.check_circle, size: 16, color: brand.accent),
                    const SizedBox(width: 8),
                    Expanded(child: Text(reason)),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }
}

/// لافتة الفائز بالمقارنة.
class _WinnerBanner extends StatelessWidget {
  final ComparisonResult result;

  const _WinnerBanner({required this.result});

  @override
  Widget build(BuildContext context) {
    const brand = BrandConfig.decoze;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: brand.accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: brand.accent),
      ),
      child: Row(
        children: [
          Icon(Icons.emoji_events, color: brand.accent),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '${context.strings.compareWinner}: ${_winnerName(result)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  String _winnerName(ComparisonResult result) {
    for (final p in result.products) {
      if (p.id == result.winnerId) return p.name;
    }
    return '';
  }
}

/// جدول المعايير — صف لكل
/// معيار وعمود لكل منتج، والـ
/// الأفضل بيتلون بالأخضر.
class _CriteriaTable extends StatelessWidget {
  final ComparisonResult result;

  const _CriteriaTable({required this.result});

  @override
  Widget build(BuildContext context) {
    const brand = BrandConfig.decoze;
    final products = result.products;

    return Container(
      decoration: BoxDecoration(
        color: brand.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // صف العناوين (أسماء المنتجات).
          IntrinsicHeight(
            child: Row(
              children: [
                const SizedBox(width: 96),
                for (final p in products)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        p.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1),

          // صف لكل معيار.
          for (final criterion in result.criteria)
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    width: 96,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        criterion.label,
                        style: TextStyle(
                          fontSize: 12,
                          color: brand.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  for (final p in products)
                    Expanded(
                      child: Container(
                        color: criterion.bestProductId == p.id
                            ? brand.accent.withValues(alpha: 0.12)
                            : null,
                        padding: const EdgeInsets.all(8),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Text(
                                criterion.values[p.id] ?? '—',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: criterion.bestProductId == p.id
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: criterion.bestProductId == p.id
                                      ? brand.accent
                                      : null,
                                ),
                              ),
                            ),
                            if (criterion.bestProductId == p.id) ...[
                              const SizedBox(width: 4),
                              Icon(
                                Icons.check_circle,
                                size: 14,
                                color: brand.accent,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// كارت منتج في المقارنة.
class _ProductCard extends StatelessWidget {
  final ProductEntity product;
  final bool isWinner;

  const _ProductCard({required this.product, required this.isWinner});

  @override
  Widget build(BuildContext context) {
    const brand = BrandConfig.decoze;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ProductDetailScreen(productId: product.id),
          ),
        ),
        child: Container(
          width: 150,
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Stack(
                  children: [
                    CachedNetworkImage(
                      imageUrl: product.thumbnail,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      placeholder: (_, __) => Container(
                        color: brand.surface,
                      ),
                    ),
                    if (isWinner)
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Icon(
                          Icons.emoji_events,
                          color: brand.accent,
                          size: 20,
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
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
            ],
          ),
        ),
      ),
    );
  }
}
