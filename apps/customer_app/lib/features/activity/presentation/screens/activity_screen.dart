import 'package:cached_network_image/cached_network_image.dart';
import 'package:customer_app/features/activity/presentation/cubit/activity_cubit.dart';
import 'package:customer_app/features/activity/presentation/cubit/activity_state.dart';
import 'package:customer_app/features/product/presentation/screens/product_detail_screen.dart';
import 'package:decoze_core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// شاشة ذاكرة التسوق —
/// آخر نشاط المستخدم
/// (بحث/مشاهدة/مقارنة/
/// شراء/تحويل).
class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    final uid = authState is AuthAuthenticated ? authState.user.uid : '';

    return Scaffold(
      appBar: AppBar(
        title: Text(context.strings.activityTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined),
            tooltip: context.strings.activityClear,
            onPressed: () => _confirmClear(context),
          ),
        ],
      ),
      body: BlocProvider(
        create: (_) => ActivityCubit(
          repository: ActivityRepositoryImpl(),
          productRepository: ProductRepositoryImpl(),
          uid: uid,
        ),
        child: const _ActivityBody(),
      ),
    );
  }

  void _confirmClear(BuildContext context) {
    final strings = context.strings;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(strings.activityClear),
        content: Text(strings.activityClearConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(strings.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<ActivityCubit>().clear();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(strings.activityCleared),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Text(strings.activityClear),
          ),
        ],
      ),
    );
  }
}

class _ActivityBody extends StatelessWidget {
  const _ActivityBody();

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;

    return BlocBuilder<ActivityCubit, ActivityState>(
      builder: (context, state) {
        final activities = state is ActivityLoaded
            ? state.activities
            : state is ActivityCleared
                ? const <UserActivityEntity>[]
                : null;
        final searches = state is ActivityLoaded
            ? state.recentSearches
            : state is ActivityCleared
                ? state.recentSearches
                : const <String>[];

        if (activities == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final isEmpty = activities.isEmpty && searches.isEmpty;

        return RefreshIndicator(
          onRefresh: () =>
              context.read<ActivityCubit>().refresh(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isEmpty)
                  _EmptyState(strings: strings)
                else ...[
                  // عمليات البحث الأخيرة.
                  if (searches.isNotEmpty) ...[
                    Text(
                      strings.activityRecentSearches,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final search in searches)
                          ActionChip(
                            avatar: const Icon(Icons.search, size: 16),
                            label: Text(search),
                            onPressed: () {},
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],

                  // آخر نشاط.
                  Text(
                    strings.activitySubtitle,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 10),
                  for (final activity in activities)
                    _ActivityTile(activity: activity, state: state),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final UserActivityEntity activity;
  final ActivityState state;

  const _ActivityTile({required this.activity, required this.state});

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    const brand = BrandConfig.decoze;

    final (icon, label, title, subtitle) = _content(strings, state);
    final timeAgo = _timeAgo(activity.timestamp, strings);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        dense: true,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: brand.accent.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: brand.accent),
        ),
        title: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        subtitle: Text(
          '$label • $timeAgo',
          style: TextStyle(
            fontSize: 12,
            color: brand.textSecondary,
          ),
        ),
        trailing: subtitle != null
            ? Icon(Icons.chevron_right, size: 18, color: brand.textSecondary)
            : null,
        onTap: subtitle != null && activity.productId != null
            ? () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        ProductDetailScreen(productId: activity.productId!),
                  ),
                )
            : null,
      ),
    );
  }

  (IconData, String, String, String?) _content(
    AppStrings strings,
    ActivityState state,
  ) {
    switch (activity.type) {
      case ActivityType.search:
        return (
          Icons.search,
          strings.activitySearchedFor,
          activity.query ?? '—',
          null,
        );
      case ActivityType.view:
        final product = _product(state);
        return (
          Icons.visibility,
          strings.activityViewedProduct,
          product?.name ?? activity.productId ?? '—',
          product?.name,
        );
      case ActivityType.compare:
        final product = _product(state);
        return (
          Icons.compare,
          strings.activityCompared,
          product?.name ?? activity.productId ?? '—',
          product?.name,
        );
      case ActivityType.purchase:
        final product = _product(state);
        return (
          Icons.shopping_bag,
          strings.activityPurchased,
          product?.name ?? activity.productId ?? '—',
          product?.name,
        );
      case ActivityType.redirect:
        return (
          Icons.open_in_new,
          strings.activityRedirected,
          activity.query ?? activity.productId ?? '—',
          activity.query,
        );
      case ActivityType.wishlist:
        final product = _product(state);
        return (
          Icons.favorite,
          strings.wishlistTitle,
          product?.name ?? activity.productId ?? '—',
          product?.name,
        );
      case ActivityType.ask:
        return (
          Icons.smart_toy,
          strings.aiAssistantTitle,
          activity.query ?? '—',
          null,
        );
    }
  }

  ProductEntity? _product(ActivityState state) {
    if (state is! ActivityLoaded) return null;
    final productId = activity.productId;
    if (productId == null) return null;
    return state.productsById[productId];
  }

  String _timeAgo(DateTime timestamp, AppStrings strings) {
    final minutes =
        DateTime.now().difference(timestamp).inMinutes;
    if (minutes < 1) return strings.activityJustNow;
    return strings.activityTimeAgo(minutes);
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
              Icons.history,
              size: 48,
              color: brand.textSecondary,
            ),
            const SizedBox(height: 12),
            Text(
              strings.activityEmpty,
              textAlign: TextAlign.center,
              style: TextStyle(color: brand.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
