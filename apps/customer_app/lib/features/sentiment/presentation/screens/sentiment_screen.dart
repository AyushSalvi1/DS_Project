import 'package:cached_network_image/cached_network_image.dart';
import 'package:customer_app/features/product/presentation/screens/product_detail_screen.dart';
import 'package:customer_app/features/sentiment/presentation/cubit/sentiment_cubit.dart';
import 'package:customer_app/features/sentiment/presentation/cubit/sentiment_state.dart';
import 'package:decoze_core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// شاشة تحليل المشاعر —
/// ملخص ذكي لتقييمات
/// المشترين (إيجابيات
/// وسلبيات وجوانب).
class SentimentScreen extends StatelessWidget {
  final String productId;

  const SentimentScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.strings.sentimentTitle)),
      body: BlocProvider(
        create: (_) => SentimentCubit()..analyze(productId),
        child: BlocBuilder<SentimentCubit, SentimentState>(
          builder: (context, state) {
            return switch (state) {
              SentimentInitial() || SentimentLoading() =>
                const Center(child: CircularProgressIndicator()),
              SentimentError(:final message) =>
                Center(child: Text(message)),
              SentimentLoaded(:final product, :final report) =>
                _SentimentContent(product: product, report: report),
            };
          },
        ),
      ),
    );
  }
}

class _SentimentContent extends StatelessWidget {
  final ProductEntity product;
  final SentimentReport report;

  const _SentimentContent({required this.product, required this.report});

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    const brand = BrandConfig.decoze;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // المنتج.
          _ProductHeader(product: product),
          const SizedBox(height: 16),

          // المشاعر العامة.
          _OverallGauge(report: report),
          const SizedBox(height: 16),

          // الملخص.
          if (report.summary.isNotEmpty) ...[
            _SectionLabel(label: strings.sentimentSummary),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: brand.surface,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(report.summary),
            ),
            const SizedBox(height: 16),
          ],

          // الإيجابيات.
          if (report.pros.isNotEmpty) ...[
            _SectionLabel(label: strings.sentimentPros),
            const SizedBox(height: 8),
            for (final pro in report.pros)
              _ProsConsTile(
                text: pro,
                positive: true,
              ),
            const SizedBox(height: 12),
          ],

          // السلبيات.
          if (report.cons.isNotEmpty) ...[
            _SectionLabel(label: strings.sentimentCons),
            const SizedBox(height: 8),
            for (final con in report.cons)
              _ProsConsTile(
                text: con,
                positive: false,
              ),
            const SizedBox(height: 12),
          ],

          // الجوانب.
          if (report.aspects.isNotEmpty) ...[
            _SectionLabel(label: strings.sentimentAspects),
            const SizedBox(height: 8),
            for (final aspect in report.aspects)
              _AspectRow(aspect: aspect),
          ],
        ],
      ),
    );
  }
}

class _ProductHeader extends StatelessWidget {
  final ProductEntity product;

  const _ProductHeader({required this.product});

  @override
  Widget build(BuildContext context) {
    const brand = BrandConfig.decoze;

    return Card(
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ProductDetailScreen(productId: product.id),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CachedNetworkImage(
                  imageUrl: product.thumbnail,
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    width: 56,
                    height: 56,
                    color: brand.surface,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 14, color: Colors.amber),
                        Text(product.rating.toStringAsFixed(1)),
                        const SizedBox(width: 8),
                        Text(
                          '(${product.reviewCount})',
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
            ],
          ),
        ),
      ),
    );
  }
}

/// مقياس المشاعر العامة
/// (دائري من سلبي لإيجابي).
class _OverallGauge extends StatelessWidget {
  final SentimentReport report;

  const _OverallGauge({required this.report});

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    const brand = BrandConfig.decoze;

    // overall من -1 لـ 1 → نسبة 0..1
    final fraction = (report.overall + 1) / 2;
    final label = report.sentimentLabel(
      strings.sentimentPositive,
      strings.sentimentNeutral,
      strings.sentimentNegative,
    );
    final color = report.overall >= 0.2
        ? Colors.green
        : report.overall <= -0.2
            ? Colors.red
            : Colors.orange;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: brand.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            strings.sentimentOverall,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 140,
                height: 140,
                child: CircularProgressIndicator(
                  value: fraction.clamp(0.0, 1.0),
                  strokeWidth: 12,
                  backgroundColor: brand.primaryBackground,
                  valueColor: AlwaysStoppedAnimation(color),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${(report.overall * 100).roundToDouble()}%',
                    style: TextStyle(
                      fontSize: 12,
                      color: brand.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// صف إيجابي/سلبي.
class _ProsConsTile extends StatelessWidget {
  final String text;
  final bool positive;

  const _ProsConsTile({required this.text, required this.positive});

  @override
  Widget build(BuildContext context) {
    const brand = BrandConfig.decoze;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: brand.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: positive
              ? Colors.green.withValues(alpha: 0.3)
              : Colors.red.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            positive ? Icons.thumb_up : Icons.thumb_down,
            size: 18,
            color: positive ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

/// صف جانب (aspect) مع
/// درجة المشاعر وعدد
/// الذكريات.
class _AspectRow extends StatelessWidget {
  final AspectSentiment aspect;

  const _AspectRow({required this.aspect});

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    const brand = BrandConfig.decoze;

    final fraction = (aspect.score + 1) / 2;
    final color = aspect.score >= 0.2
        ? Colors.green
        : aspect.score <= -0.2
            ? Colors.red
            : Colors.orange;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: brand.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  aspect.aspect,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '${aspect.mentions} ${strings.sentimentMentions}',
                style: TextStyle(
                  fontSize: 12,
                  color: brand.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: fraction.clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: brand.primaryBackground,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;

  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.titleMedium,
    );
  }
}
