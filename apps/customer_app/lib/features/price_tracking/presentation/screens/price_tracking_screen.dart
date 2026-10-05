import 'package:customer_app/features/price_tracking/presentation/cubit/price_tracking_cubit.dart';
import 'package:customer_app/features/price_tracking/presentation/cubit/price_tracking_state.dart';
import 'package:customer_app/features/price_tracking/presentation/widgets/price_history_chart.dart';
import 'package:customer_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:customer_app/features/auth/presentation/cubit/auth_state.dart';
import 'package:decoze_core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// شاشة تتبع الأسعار —
/// تنبيهات انخفاض السعر/التوفر
/// + رسم بياني لتاريخ السعر.
class PriceTrackingScreen extends StatelessWidget {
  const PriceTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    final uid = authState is AuthAuthenticated ? authState.user.uid : '';

    return BlocProvider(
      create: (_) => PriceTrackingCubit(
        repository: PriceTrackingRepositoryImpl(),
        uid: uid,
      ),
      // Builder عشان الـ context اللي
      // بيُستخدم في الـ AppBar والفاب
      // يكون تحت الـ BlocProvider
      // (مش فوقه) عشان read يشتغل.
      child: Builder(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text(context.strings.priceTrackingTitle),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: context.strings.track,
                onPressed: () =>
                    context.read<PriceTrackingCubit>().checkNow(),
              ),
            ],
          ),
          body: const _PriceTrackingBody(),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showAddAlertSheet(context),
            icon: const Icon(Icons.add_alert),
            label: Text(context.strings.addPriceAlert),
          ),
        ),
      ),
    );
  }

  void _showAddAlertSheet(BuildContext context) {
    final strings = context.strings;
    final cubit = context.read<PriceTrackingCubit>();
    final productIdController = TextEditingController();
    final targetController = TextEditingController();
    var selectedType = PriceAlertType.priceDrop;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
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
                strings.addPriceAlert,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),

              // نوع التنبيه.
              Text(strings.alertTypeDrop),
              const SizedBox(height: 8),
              SegmentedButton<PriceAlertType>(
                segments: [
                  ButtonSegment(
                    value: PriceAlertType.targetPrice,
                    label: Text(strings.alertTypeTarget),
                  ),
                  ButtonSegment(
                    value: PriceAlertType.priceDrop,
                    label: Text(strings.alertTypeDrop),
                  ),
                  ButtonSegment(
                    value: PriceAlertType.backInStock,
                    label: Text(strings.alertTypeAvailability),
                  ),
                ],
                selected: {selectedType},
                onSelectionChanged: (set) => setSheetState(
                  () => selectedType = set.first,
                ),
              ),
              const SizedBox(height: 16),

              // معرّف المنتج.
              TextField(
                controller: productIdController,
                decoration: InputDecoration(
                  labelText: strings.alertFor,
                  hintText: 'product-123',
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),

              // القيمة المستهدفة.
              if (selectedType != PriceAlertType.backInStock)
                TextField(
                  controller: targetController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: selectedType == PriceAlertType.targetPrice
                        ? strings.targetPriceHint
                        : strings.percentDropHint,
                    border: const OutlineInputBorder(),
                  ),
                ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    final productId = productIdController.text.trim();
                    if (productId.isEmpty) return;

                    final target = double.tryParse(targetController.text);
                    cubit.addAlert(
                          type: selectedType,
                          productId: productId,
                          targetPrice:
                              selectedType == PriceAlertType.targetPrice
                                  ? target
                                  : null,
                          percentDrop:
                              selectedType == PriceAlertType.priceDrop
                                  ? target
                                  : null,
                        );
                    Navigator.of(context).pop();
                  },
                  child: Text(strings.createAlert),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PriceTrackingBody extends StatelessWidget {
  const _PriceTrackingBody();

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;

    return BlocBuilder<PriceTrackingCubit, PriceTrackingState>(
      builder: (context, state) {
        if (state is! PriceTrackingLoaded) {
          return const Center(child: CircularProgressIndicator());
        }

        final alerts = state.alerts;
        final hasAlerts = alerts.isNotEmpty;

        return RefreshIndicator(
          onRefresh: () => context.read<PriceTrackingCubit>().checkNow(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // رسم بياني لتاريخ السعر.
                _HistorySection(state: state),
                const SizedBox(height: 20),

                // التنبيهات النشطة.
                Row(
                  children: [
                    Text(
                      strings.activeAlerts,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const Spacer(),
                    if (hasAlerts)
                      Text(
                        '${alerts.length}',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                              color: BrandConfig.decoze.accent,
                            ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),

                if (!hasAlerts)
                  _EmptyState(strings: strings)
                else
                  for (final alert in alerts)
                    _AlertTile(alert: alert),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// قسم الرسم البياني لتاريخ
/// السعر.
class _HistorySection extends StatelessWidget {
  final PriceTrackingLoaded state;

  const _HistorySection({required this.state});

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final history = state.history;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: BrandConfig.decoze.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            strings.priceHistory,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            strings.priceHistoryDays,
            style: TextStyle(
              fontSize: 12,
              color: BrandConfig.decoze.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          if (history == null || history.points.isEmpty)
            Center(
              child: Text(
                strings.analyticsNoData,
                style: TextStyle(
                  color: BrandConfig.decoze.textSecondary,
                ),
              ),
            )
          else ...[
            SizedBox(
              height: 180,
              child: PriceHistoryChart(points: history.points),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _Stat(
                  label: strings.currentPrice,
                  value: history.currentPrice,
                ),
                const SizedBox(width: 16),
                _Stat(
                  label: strings.lowestPrice,
                  value: history.lowestPrice,
                ),
                const SizedBox(width: 16),
                _Stat(
                  label: strings.highestPrice,
                  value: history.highestPrice,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final double? value;

  const _Stat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    const brand = BrandConfig.decoze;

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: brand.textSecondary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value == null
                ? '—'
                : '${brand.currencySymbol} ${value!.toStringAsFixed(2)}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
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
              Icons.notifications_none,
              size: 48,
              color: brand.textSecondary,
            ),
            const SizedBox(height: 12),
            Text(
              strings.noActiveAlerts,
              textAlign: TextAlign.center,
              style: TextStyle(color: brand.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

/// تنبيه واحد في القايمة.
class _AlertTile extends StatelessWidget {
  final PriceAlertEntity alert;

  const _AlertTile({required this.alert});

  @override
  Widget build(BuildContext context) {
    const brand = BrandConfig.decoze;
    final strings = context.strings;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(
          alert.type == PriceAlertType.backInStock
              ? Icons.inventory_2
              : alert.type == PriceAlertType.targetPrice
                  ? Icons.target
                  : Icons.trending_down,
          color: brand.accent,
        ),
        title: Text(
          alert.productId ?? alert.listingId ?? '—',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          _describe(strings),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                alert.active
                    ? Icons.notifications_active
                    : Icons.notifications_off,
                color: alert.active ? brand.accent : brand.textSecondary,
              ),
              onPressed: () =>
                  context.read<PriceTrackingCubit>().toggleAlert(alert),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _confirmDelete(context),
            ),
          ],
        ),
      ),
    );
  }

  String _describe(AppStrings strings) {
    switch (alert.type) {
      case PriceAlertType.targetPrice:
        final target = alert.targetPrice;
        return target == null
            ? strings.alertTypeTarget
            : '${strings.alertTypeTarget}: ${BrandConfig.decoze.currencySymbol} ${target.toStringAsFixed(2)}';
      case PriceAlertType.priceDrop:
        final drop = alert.percentDrop;
        return drop == null
            ? strings.alertTypeDrop
            : '${strings.alertTypeDrop}: ${drop.toStringAsFixed(0)}%';
      case PriceAlertType.backInStock:
        return strings.alertTypeAvailability;
    }
  }

  void _confirmDelete(BuildContext context) {
    final strings = context.strings;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(strings.alertDelete),
        content: Text(strings.alertDeleteConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(strings.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context
                  .read<PriceTrackingCubit>()
                  .removeAlert(alert.id);
            },
            child: Text(strings.alertDelete),
          ),
        ],
      ),
    );
  }
}
