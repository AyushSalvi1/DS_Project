import 'package:customer_app/features/preferences/presentation/cubit/shopping_profile_cubit.dart';
import 'package:customer_app/features/preferences/presentation/cubit/shopping_profile_state.dart';
import 'package:decoze_core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// شاشة ملف التسوق —
/// التفضيلات اللي بتستخدم
/// في التوصية الشخصية
/// (فئات، ألوان، ميزانية،
/// أسلوب، جودة).
class ShoppingProfileScreen extends StatelessWidget {
  const ShoppingProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    final uid = authState is AuthAuthenticated ? authState.user.uid : '';

    return Scaffold(
      appBar: AppBar(title: Text(context.strings.shoppingProfileTitle)),
      body: BlocProvider(
        create: (_) => ShoppingProfileCubit(
          repository: PreferencesRepositoryImpl(),
          categoryRepository: CategoryRepositoryImpl(),
          uid: uid,
        )..load(),
        child: BlocBuilder<ShoppingProfileCubit, ShoppingProfileState>(
          builder: (context, state) {
            return switch (state) {
              ShoppingProfileInitial() || ShoppingProfileLoading() =>
                const Center(child: CircularProgressIndicator()),
              ShoppingProfileError(:final message) =>
                Center(child: Text(message)),
              ShoppingProfileLoaded(:final preferences, :final categories) =>
                _ProfileForm(
                    uid: uid,
                    preferences: preferences,
                    categories: categories,
                  ),
            };
          },
        ),
      ),
    );
  }
}

class _ProfileForm extends StatefulWidget {
  final String uid;
  final ShoppingPreferencesEntity preferences;
  final List<CategoryEntity> categories;

  const _ProfileForm({
    required this.uid,
    required this.preferences,
    required this.categories,
  });

  @override
  State<_ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends State<_ProfileForm> {
  late Set<String> _selectedCategories;
  late TextEditingController _minBudgetController;
  late TextEditingController _maxBudgetController;
  late TextEditingController _stylesController;
  late String _qualityPreference;

  @override
  void initState() {
    super.initState();
    final prefs = widget.preferences;
    _selectedCategories = {...prefs.preferredCategoryIds};
    _minBudgetController = TextEditingController(
      text: prefs.budgetMin?.toStringAsFixed(0) ?? '',
    );
    _maxBudgetController = TextEditingController(
      text: prefs.budgetMax?.toStringAsFixed(0) ?? '',
    );
    _stylesController = TextEditingController(
      text: prefs.styleKeywords.join(', '),
    );
    _qualityPreference = prefs.qualityPreference;
  }

  @override
  void dispose() {
    _minBudgetController.dispose();
    _maxBudgetController.dispose();
    _stylesController.dispose();
    super.dispose();
  }

  ShoppingPreferencesEntity _collect() {
    final prefs = widget.preferences;
    return prefs.copyWith(
      preferredCategoryIds: _selectedCategories.toList(),
      budgetMin: double.tryParse(_minBudgetController.text),
      budgetMax: double.tryParse(_maxBudgetController.text),
      styleKeywords: _stylesController.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList(),
      qualityPreference: _qualityPreference,
      updatedAt: DateTime.now(),
    );
  }

  void _save() {
    context.read<ShoppingProfileCubit>().save(_collect());
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.strings.preferencesSaved),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    const brand = BrandConfig.decoze;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // الفئات المفضلة.
          Text(
            strings.preferredCategories,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final category in widget.categories)
                ChoiceChip(
                  label: Text(category.name),
                  selected: _selectedCategories.contains(category.id),
                  selectedColor: brand.accent.withValues(alpha: 0.2),
                  labelStyle: TextStyle(
                    color: _selectedCategories.contains(category.id)
                        ? brand.accent
                        : brand.textPrimary,
                  ),
                  side: BorderSide(
                    color: _selectedCategories.contains(category.id)
                        ? brand.accent
                        : brand.textSecondary.withValues(alpha: 0.3),
                  ),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedCategories.add(category.id);
                      } else {
                        _selectedCategories.remove(category.id);
                      }
                    });
                  },
                ),
            ],
          ),
          const SizedBox(height: 20),

          // نطاق الميزانية.
          Text(
            strings.budgetRange,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _minBudgetController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: strings.budgetMin,
                    prefixText: '${brand.currencySymbol} ',
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.arrow_forward, size: 18),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _maxBudgetController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: strings.budgetMax,
                    prefixText: '${brand.currencySymbol} ',
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // كلمات الأسلوب.
          Text(
            strings.styleKeywords,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            strings.styleKeywordsHint,
            style: TextStyle(
              fontSize: 12,
              color: brand.textSecondary,
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _stylesController,
            decoration: InputDecoration(
              hintText: 'modern, minimalist, rustic',
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),

          // تفضيل الجودة.
          Text(
            strings.qualityPreference,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 10),
          SegmentedButton<String>(
            segments: [
              ButtonSegment(
                value: 'value',
                label: Text(strings.qualityValue),
              ),
              ButtonSegment(
                value: 'balanced',
                label: Text(strings.qualityBalanced),
              ),
              ButtonSegment(
                value: 'premium',
                label: Text(strings.qualityPremium),
              ),
            ],
            selected: {_qualityPreference},
            onSelectionChanged: (set) {
              setState(() => _qualityPreference = set.first);
            },
          ),
          const SizedBox(height: 24),

          // حفظ.
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _save,
              child: Text(strings.savePreferences),
            ),
          ),
        ],
      ),
    );
  }
}
