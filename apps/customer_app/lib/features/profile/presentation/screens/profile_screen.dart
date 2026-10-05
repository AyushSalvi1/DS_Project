import 'package:decoze_core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../../settings/presentation/screens/language_screen.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_menu_grid.dart';
import '../widgets/profile_menu_tile.dart';
import '../widgets/profile_quick_actions.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.profileTitle),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          if (state is! AuthAuthenticated) return const SizedBox.shrink();
          return _ProfileBody(user: state.user);
        },
      ),
    );
  }
}

class _ProfileBody extends StatelessWidget {
  final UserEntity user;

  const _ProfileBody({required this.user});

  @override
  Widget build(BuildContext context) {
    const brand = BrandConfig.decoze;
    final strings = context.strings;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        ProfileHeader(user: user),
        const SizedBox(height: 24),
        const ProfileQuickActions(),
        const SizedBox(height: 24),
        const ProfileMenuGrid(),
        const SizedBox(height: 16),

        // ميزات الذكاء الاصطناعي
        // للتسوق.
        _SectionLabel(label: strings.aiAssistant),
        const SizedBox(height: 8),
        ProfileMenuTile(
          icon: Icons.smart_toy_outlined,
          title: strings.aiAssistantTitle,
          onTap: () => context.push('/assistant'),
        ),
        const SizedBox(height: 8),
        ProfileMenuTile(
          icon: Icons.image_search,
          title: strings.visualSearchTitle,
          onTap: () => context.push('/visual-search'),
        ),
        const SizedBox(height: 8),
        ProfileMenuTile(
          icon: Icons.public,
          title: strings.webSearchTitle,
          onTap: () => context.push('/web-search'),
        ),
        const SizedBox(height: 8),
        ProfileMenuTile(
          icon: Icons.trending_down,
          title: strings.priceTrackingTitle,
          onTap: () => context.push('/price-tracking'),
        ),
        const SizedBox(height: 8),
        ProfileMenuTile(
          icon: Icons.favorite_border,
          title: strings.wishlistTitle,
          onTap: () => context.push('/wishlist'),
        ),
        const SizedBox(height: 8),
        ProfileMenuTile(
          icon: Icons.collections_bookmark_outlined,
          title: strings.collectionsTitle,
          onTap: () => context.push('/collections'),
        ),
        const SizedBox(height: 8),
        ProfileMenuTile(
          icon: Icons.storefront_outlined,
          title: strings.merchantsTitle,
          onTap: () => context.push('/merchants'),
        ),
        const SizedBox(height: 8),
        ProfileMenuTile(
          icon: Icons.bar_chart_outlined,
          title: strings.analyticsTitle,
          onTap: () => context.push('/analytics'),
        ),
        const SizedBox(height: 8),
        ProfileMenuTile(
          icon: Icons.recommend_outlined,
          title: strings.recommendedForYou,
          onTap: () => context.push('/recommendations'),
        ),
        const SizedBox(height: 8),
        ProfileMenuTile(
          icon: Icons.find_in_page_outlined,
          title: strings.duplicatesTitle,
          onTap: () => context.push('/duplicates'),
        ),
        const SizedBox(height: 8),
        ProfileMenuTile(
          icon: Icons.person_pin_outlined,
          title: strings.shoppingProfileTitle,
          onTap: () => context.push('/shopping-profile'),
        ),
        const SizedBox(height: 8),
        ProfileMenuTile(
          icon: Icons.privacy_tip_outlined,
          title: strings.privacyTitle,
          onTap: () => context.push('/privacy'),
        ),
        const SizedBox(height: 8),
        ProfileMenuTile(
          icon: Icons.history,
          title: strings.activityTitle,
          onTap: () => context.push('/activity'),
        ),
        const SizedBox(height: 16),

        ProfileMenuTile(
          icon: Icons.language_outlined,
          title: strings.languageTitle,
          trailing: Text(
            user.language == 'en' ? strings.languageEnglish : strings.languageArabic,
            style: TextStyle(color: brand.textSecondary),
          ),
          onTap: () =>
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LanguageScreen())),
        ),
        const SizedBox(height: 8),
        ProfileMenuTile(
          icon: Icons.logout,
          title: strings.logout,
          titleColor: Colors.red,
          onTap: () => _confirmLogout(context),
        ),
      ],
    );
  }

  void _confirmLogout(BuildContext context) {
    final strings = context.strings;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(strings.confirmLogout),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(strings.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<AuthCubit>().signOut();
            },
            child: Text(strings.logout, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

/// عنوان قسم صغير في
/// البروفايل.
class _SectionLabel extends StatelessWidget {
  final String label;

  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: BrandConfig.decoze.textSecondary,
      ),
    );
  }
}
