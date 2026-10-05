import 'package:cached_network_image/cached_network_image.dart';
import 'package:customer_app/features/merchants/presentation/cubit/merchants_cubit.dart';
import 'package:customer_app/features/merchants/presentation/cubit/merchants_state.dart';
import 'package:decoze_core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

/// شاشة التجار — التجار
/// الخارجيين مع درجات
/// الموثوقية وسياساتهم.
class MerchantsScreen extends StatelessWidget {
  const MerchantsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.strings.merchantsTitle)),
      body: BlocProvider(
        create: (_) => MerchantsCubit()..load(),
        child: BlocBuilder<MerchantsCubit, MerchantsState>(
          builder: (context, state) {
            return switch (state) {
              MerchantsInitial() || MerchantsLoading() =>
                const Center(child: CircularProgressIndicator()),
              MerchantsError(:final message) =>
                Center(child: Text(message)),
              MerchantsLoaded(:final merchants) =>
                _MerchantsList(merchants: merchants),
            };
          },
        ),
      ),
    );
  }
}

class _MerchantsList extends StatelessWidget {
  final List<MerchantEntity> merchants;

  const _MerchantsList({required this.merchants});

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;

    if (merchants.isEmpty) {
      return Center(
        child: Text(
          strings.analyticsNoData,
          style: TextStyle(
            color: BrandConfig.decoze.textSecondary,
          ),
        ),
      );
    }

    // بنرتب حسب الموثوقية.
    final sorted = [...merchants]
      ..sort(
        (a, b) => b.reliabilityScore.compareTo(a.reliabilityScore),
      );

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sorted.length,
      itemBuilder: (context, index) {
        final merchant = sorted[index];
        return _MerchantCard(merchant: merchant);
      },
    );
  }
}

class _MerchantCard extends StatelessWidget {
  final MerchantEntity merchant;

  const _MerchantCard({required this.merchant});

  @override
  Widget build(BuildContext context) {
    const brand = BrandConfig.decoze;
    final strings = context.strings;

    final (label, color) = _reliability(
      merchant.reliabilityScore,
      strings,
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // الاسم + التحقق.
            Row(
              children: [
                // لوجو التاجر.
                CircleAvatar(
                  radius: 24,
                  backgroundColor: brand.surface,
                  backgroundImage: merchant.logoUrl == null
                      ? null
                      : NetworkImage(merchant.logoUrl!),
                  child: merchant.logoUrl == null
                      ? Icon(
                          Icons.storefront,
                          color: brand.accent,
                        )
                      : null,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              merchant.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          if (merchant.isVerified)
                            Icon(
                              Icons.verified,
                              size: 18,
                              color: brand.accent,
                            ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        merchant.domain,
                        style: TextStyle(
                          fontSize: 12,
                          color: brand.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // درجة الموثوقية.
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            strings.merchantReliability,
                            style: TextStyle(
                              fontSize: 12,
                              color: brand.textSecondary,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${merchant.reliabilityScore.toStringAsFixed(0)}/100',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: merchant.reliabilityScore / 100,
                          minHeight: 6,
                          backgroundColor: brand.surface,
                          valueColor: AlwaysStoppedAnimation(color),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // التقييم والشحن والمرتجعات.
            Row(
              children: [
                _Metric(
                  icon: Icons.star,
                  value: merchant.rating.toStringAsFixed(1),
                  label: strings.merchantReviews,
                ),
                const SizedBox(width: 16),
                _Metric(
                  icon: Icons.local_shipping,
                  value: merchant.shippingEstimate,
                  label: strings.merchantShipping,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _Metric(
                    icon: Icons.assignment_return,
                    value: merchant.returnPolicy ?? '—',
                    label: strings.merchantReturns,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // زر زيارة الموقع.
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _visitSite(),
                icon: const Icon(Icons.open_in_new, size: 16),
                label: Text(strings.merchantVisitStore),
              ),
            ),
          ],
        ),
      ),
    );
  }

  (String, Color) _reliability(double score, AppStrings strings) {
    if (score >= 85) {
      return (strings.merchantExcellent, Colors.green);
    }
    if (score >= 65) {
      return (strings.merchantGood, Colors.orange);
    }
    return (strings.merchantAverage, Colors.red);
  }

  Future<void> _visitSite() async {
    final uri = Uri.tryParse('https://${merchant.domain}');
    if (uri == null) return;
    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    }
  }
}

class _Metric extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _Metric({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    const brand = BrandConfig.decoze;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: brand.textSecondary),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: brand.textSecondary,
          ),
        ),
      ],
    );
  }
}
