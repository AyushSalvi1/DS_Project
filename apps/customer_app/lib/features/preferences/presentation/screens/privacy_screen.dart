import 'package:customer_app/features/preferences/presentation/cubit/privacy_cubit.dart';
import 'package:customer_app/features/preferences/presentation/cubit/privacy_state.dart';
import 'package:decoze_core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// شاشة الخصوصية —
/// تحكم في البيانات
/// والتخصيص.
class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    final uid = authState is AuthAuthenticated ? authState.user.uid : '';

    return Scaffold(
      appBar: AppBar(title: Text(context.strings.privacyTitle)),
      body: BlocProvider(
        create: (_) => PrivacyCubit(
          repository: PreferencesRepositoryImpl(),
          uid: uid,
        )..load(),
        child: BlocBuilder<PrivacyCubit, PrivacyState>(
          builder: (context, state) {
            if (state is! PrivacyLoaded) {
              return const Center(child: CircularProgressIndicator());
            }

            return _PrivacyContent(settings: state.settings);
          },
        ),
      ),
    );
  }
}

class _PrivacyContent extends StatelessWidget {
  final PrivacySettingsEntity settings;

  const _PrivacyContent({required this.settings});

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // الوصف.
        Text(
          strings.privacySubtitle,
          style: TextStyle(
            color: BrandConfig.decoze.textSecondary,
          ),
        ),
        const SizedBox(height: 20),

        _PrivacySwitch(
          title: strings.privacyPersonalization,
          description: strings.privacyPersonalizationDesc,
          icon: Icons.auto_awesome,
          value: settings.personalizationEnabled,
          onChanged: (v) =>
              context.read<PrivacyCubit>().setPersonalization(v),
        ),
        const SizedBox(height: 12),

        _PrivacySwitch(
          title: strings.privacyActivity,
          description: strings.privacyActivityDesc,
          icon: Icons.history,
          value: settings.activityTrackingEnabled,
          onChanged: (v) =>
              context.read<PrivacyCubit>().setActivityTracking(v),
        ),
        const SizedBox(height: 12),

        _PrivacySwitch(
          title: strings.privacyAnalytics,
          description: strings.privacyAnalyticsDesc,
          icon: Icons.bar_chart,
          value: settings.analyticsSharingEnabled,
          onChanged: (v) =>
              context.read<PrivacyCubit>().setAnalyticsSharing(v),
        ),
        const SizedBox(height: 24),

        // مسح البيانات.
        OutlinedButton.icon(
          onPressed: () => _confirmClear(context),
          icon: const Icon(Icons.delete_forever_outlined),
          label: Text(strings.privacyClearData),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.red,
            side: const BorderSide(color: Colors.red),
          ),
        ),
        const SizedBox(height: 16),

        TextButton(
          onPressed: () {},
          child: Text(
            strings.privacyLearnMore,
            style: TextStyle(
              color: BrandConfig.decoze.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  void _confirmClear(BuildContext context) {
    final strings = context.strings;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(strings.privacyClearData),
        content: Text(strings.privacyClearDataConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(strings.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<PrivacyCubit>().clearPersonalData();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(strings.privacyDataCleared),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Text(
              strings.privacyClearData,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrivacySwitch extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _PrivacySwitch({
    required this.title,
    required this.description,
    required this.icon,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    const brand = BrandConfig.decoze;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: brand.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: brand.accent),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: brand.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: brand.accent,
          ),
        ],
      ),
    );
  }
}
