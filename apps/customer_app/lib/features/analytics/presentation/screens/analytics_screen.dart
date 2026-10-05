import 'package:customer_app/features/analytics/presentation/cubit/analytics_cubit.dart';
import 'package:customer_app/features/analytics/presentation/cubit/analytics_state.dart';
import 'package:customer_app/features/analytics/presentation/widgets/weekly_activity_chart.dart';
import 'package:customer_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:customer_app/features/auth/presentation/cubit/auth_state.dart';
import 'package:decoze_core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// شاشة التحليلات —
/// نشاط المستخدم وأداء
/// التوصيات.
class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    final uid = authState is AuthAuthenticated ? authState.user.uid : '';

    return Scaffold(
      appBar: AppBar(title: Text(context.strings.analyticsTitle)),
      body: BlocProvider(
        create: (_) => AnalyticsCubit(
          repository: AnalyticsRepositoryImpl(),
          uid: uid,
        )..load(),
        child: const _AnalyticsBody(),
      ),
    );
  }
}

class _AnalyticsBody extends StatelessWidget {
  const _AnalyticsBody();

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;

    return BlocBuilder<AnalyticsCubit, AnalyticsState>(
      builder: (context, state) {
        if (state is! AnalyticsLoaded) {
          return const Center(child: CircularProgressIndicator());
        }

        final user = state.userAnalytics;
        final rec = state.recommendationAnalytics;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // نشاط المستخدم.
              Text(
                strings.analyticsYourActivity,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              _StatsGrid(user: user),
              const SizedBox(height: 20),

              // النشاط الأسبوعي.
              Text(
                strings.analyticsWeeklyActivity,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: BrandConfig.decoze.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: WeeklyActivityChart(
                  activityByDay: user.activityByDay,
                ),
              ),
              const SizedBox(height: 20),

              // اهتمامات الفئات.
              if (user.topCategories.isNotEmpty) ...[
                Text(
                  strings.analyticsTopCategories,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                _TopCategories(categories: user.topCategories),
                const SizedBox(height: 20),
              ],

              // أداء التوصيات.
              Text(
                strings.analyticsRecommendations,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              _RecommendationStats(rec: rec),
            ],
          ),
        );
      },
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final UserAnalytics user;

  const _StatsGrid({required this.user});

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    const brand = BrandConfig.decoze;

    final stats = <(String, String, IconData)>[
      (
        strings.analyticsSearches,
        '${user.totalSearches}',
        Icons.search,
      ),
      (
        strings.analyticsViews,
        '${user.totalViews}',
        Icons.visibility,
      ),
      (
        strings.analyticsComparisons,
        '${user.totalComparisons}',
        Icons.compare,
      ),
      (
        strings.analyticsPurchases,
        '${user.totalPurchases}',
        Icons.shopping_bag,
      ),
      (
        strings.analyticsRedirects,
        '${user.totalRedirects}',
        Icons.open_in_new,
      ),
      (
        strings.analyticsAlertsTriggered,
        '${user.priceAlertsTriggered}',
        Icons.notifications,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 2.2,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final (label, value, icon) = stats[index];
        return Container(
          decoration: BoxDecoration(
            color: brand.surface,
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: [
              Icon(icon, color: brand.accent, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      value,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        color: brand.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TopCategories extends StatelessWidget {
  final List<CategoryInterest> categories;

  const _TopCategories({required this.categories});

  @override
  Widget build(BuildContext context) {
    const brand = BrandConfig.decoze;
    final max = categories.first.interactions;

    return Column(
      children: [
        for (final interest in categories)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                SizedBox(
                  width: 100,
                  child: Text(
                    interest.categoryId,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: interest.interactions / max,
                      minHeight: 8,
                      backgroundColor: brand.surface,
                      valueColor: const AlwaysStoppedAnimation(
                        BrandConfig.decoze.accent,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${interest.interactions}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _RecommendationStats extends StatelessWidget {
  final RecommendationAnalytics rec;

  const _RecommendationStats({required this.rec});

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    const brand = BrandConfig.decoze;

    final metrics = <(String, String)>[
      (strings.analyticsRecShown, '${rec.shown}'),
      (strings.analyticsRecClicked, '${rec.clicked}'),
      (strings.analyticsRecPurchased, '${rec.purchased}'),
      (strings.analyticsRecPositive, '${rec.feedbackPositive}'),
      (strings.analyticsRecNegative, '${rec.feedbackNegative}'),
      (
        strings.analyticsCtr,
        strings.analyticsPercent(rec.clickThroughRate),
      ),
      (
        strings.analyticsAcceptanceRate,
        strings.analyticsPercent(rec.acceptanceRate),
      ),
      (
        strings.analyticsPositiveRate,
        strings.analyticsPercent(rec.positiveFeedbackRate),
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: brand.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          for (var i = 0; i < metrics.length; i++)
            ListTile(
              dense: true,
              title: Text(metrics[i].$1),
              trailing: Text(
                metrics[i].$2,
                style: const TextStyle(
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
