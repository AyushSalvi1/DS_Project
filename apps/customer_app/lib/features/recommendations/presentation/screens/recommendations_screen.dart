import 'package:cached_network_image/cached_network_image.dart';
import 'package:customer_app/features/product/presentation/screens/product_detail_screen.dart';
import 'package:customer_app/features/recommendations/presentation/cubit/recommendations_cubit.dart';
import 'package:customer_app/features/recommendations/presentation/cubit/recommendations_state.dart';
import 'package:decoze_core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// شاشة التوصية التفسيرية —
/// منتجات مرشحة مع
/// درجة الملاءمة والأسباب
/// المقروضة + تقييم المستخدم.
class RecommendationsScreen extends StatelessWidget {
  const RecommendationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    final uid = authState is AuthAuthenticated ? authState.user.uid : '';

    return Scaffold(
      appBar: AppBar(title: Text(context.strings.recommendedForYou)),
      body: BlocProvider(
        create: (_) => RecommendationsCubit(uid: uid)..load(),
        child: BlocBuilder<RecommendationsCubit, RecommendationsState>(
          builder: (context, state) {
            return switch (state) {
              RecommendationsInitial() ||
              RecommendationsLoading() =>
                const Center(child: CircularProgressIndicator()),
              RecommendationsError(:final message) =>
                Center(child: Text(message)),
              RecommendationsLoaded(:final products) =>
                _RecommendationsContent(products: products),
            };
          },
        ),
      ),
    );
  }
}

class _RecommendationsContent extends StatelessWidget {
  final List<ScoredProduct> products;

  const _RecommendationsContent({required this.products});

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;

    return RefreshIndicator(
      onRefresh: () =>
          context.read<RecommendationsCubit>().load(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          // عنوان تفسيري.
          Text(
            strings.explainableWhyRecommended,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),

          if (products.isEmpty)
            const _EmptyState()
          else
            for (final scored in products)
              _RecommendationCard(scored: scored),
        ],
      ),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  final ScoredProduct scored;

  const _RecommendationCard({required this.scored});

  @override
  Widget build(BuildContext context) {
    const brand = BrandConfig.decoze;
    final strings = context.strings;
    final product = scored.product;
    final reasons = scored.topReasons;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // الصف الرئيسي: صورة + معلومات
            // (دوسيه لفتح تفاصيل المنتج).
            GestureDetector(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      ProductDetailScreen(productId: product.id),
                ),
              ),
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
                        ],
                      ),
                    ],
                  ),
                ),
                // درجة الملاءمة.
                _ScoreBadge(score: scored.score),
              ],
            ),
            ),

            // الأسباب المقروضة (Explainable AI).
            if (reasons.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: brand.accent.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.auto_awesome,
                            size: 14, color: brand.accent),
                        const SizedBox(width: 6),
                        Text(
                          strings.explainableWhyRecommended,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: brand.accent,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    for (final reason in reasons)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('• '),
                            Expanded(
                              child: Text(
                                reason,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 8),

            // أزرار التقييم (تعلم من الفيدباك).
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => context
                        .read<RecommendationsCubit>()
                        .dislike(product.id),
                    icon: const Icon(Icons.thumb_down_outlined,
                        size: 16),
                    label: Text(
                      strings.explainableFeedbackNegative,
                      style: const TextStyle(fontSize: 12),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: brand.textSecondary,
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {
                      context
                          .read<RecommendationsCubit>()
                          .like(product.id);
                      ScaffoldMessenger.of(context)
                          .showSnackBar(
                        SnackBar(
                          content:
                              Text(strings.explainableFeedbackThanks),
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    icon: const Icon(Icons.thumb_up_outlined,
                        size: 16),
                    label: Text(
                      strings.explainableFeedbackPositive,
                      style: const TextStyle(fontSize: 12),
                    ),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            ],
          ],
        ),
      ),
    );
  }
}

class _ScoreBadge extends StatelessWidget {
  final double score;

  const _ScoreBadge({required this.score});

  @override
  Widget build(BuildContext context) {
    const brand = BrandConfig.decoze;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: brand.accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            score.toStringAsFixed(0),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: brand.accent,
            ),
          ),
          Text(
            '%',
            style: TextStyle(
              fontSize: 9,
              color: brand.accent,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    const brand = BrandConfig.decoze;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Icon(
          Icons.recommend_outlined,
          size: 48,
          color: brand.textSecondary,
        ),
      ),
    );
  }
}
