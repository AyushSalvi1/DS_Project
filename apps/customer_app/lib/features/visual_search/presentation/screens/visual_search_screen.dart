import 'package:decoze_core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../cubit/visual_search_cubit.dart';
import '../cubit/visual_search_state.dart';
import '../widgets/visual_search_result_card.dart';

/// شاشة البحث البصري —
/// صورة المنتج بتحللها
/// الـ AI ونطابقها على
/// الكتالوج والمواقع.
class VisualSearchScreen extends StatelessWidget {
  const VisualSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.strings.visualSearchTitle)),
      body: BlocProvider(
        create: (_) => VisualSearchCubit(
          visualSearchRepository: VisualSearchRepositoryImpl(),
          productRepository: ProductRepositoryImpl(),
          merchantRepository: MerchantRepositoryImpl(),
        ),
        child: const _VisualSearchBody(),
      ),
    );
  }
}

class _VisualSearchBody extends StatelessWidget {
  const _VisualSearchBody();

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    const brand = BrandConfig.decoze;

    return BlocBuilder<VisualSearchCubit, VisualSearchState>(
      builder: (context, state) {
        return Column(
          children: [
            // شريط اختيار الصورة.
            _ImagePickerBar(
              onPick: () => context.read<VisualSearchCubit>().pickImage(),
              onCapture: () => context.read<VisualSearchCubit>().captureImage(),
            ),

            const SizedBox(height: 12),

            // الصورة المختارة + الحالة.
            Expanded(
              child: switch (state) {
                VisualSearchInitial() => _EmptyHint(strings: strings),
                VisualSearchLoading() => const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 12),
                        _AnalyzingLabel(),
                      ],
                    ),
                  ),
                VisualSearchLoaded(:final result) => _ResultsPane(result: result),
                VisualSearchError(:final message) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        message,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: brand.textSecondary),
                      ),
                    ),
                  ),
              },
            ),
          ],
        );
      },
    );
  }
}

class _AnalyzingLabel extends StatelessWidget {
  const _AnalyzingLabel();

  @override
  Widget build(BuildContext context) {
    return Text(
      context.strings.visualSearchAnalyzing,
      style: TextStyle(color: BrandConfig.decoze.textSecondary),
    );
  }
}

/// شريط أزرار اختيار
/// مصدر الصورة.
class _ImagePickerBar extends StatelessWidget {
  final VoidCallback onPick;
  final VoidCallback onCapture;

  const _ImagePickerBar({required this.onPick, required this.onCapture});

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FilledButton.icon(
            onPressed: onPick,
            icon: const Icon(Icons.photo_library_outlined),
            label: Text(strings.visualSearchPickImage),
          ),
          const SizedBox(width: 12),
          OutlinedButton.icon(
            onPressed: onCapture,
            icon: const Icon(Icons.camera_alt_outlined),
            label: Text(strings.visualSearchTakePhoto),
          ),
        ],
      ),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  final AppStrings strings;

  const _EmptyHint({required this.strings});

  @override
  Widget build(BuildContext context) {
    const brand = BrandConfig.decoze;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_search,
              size: 64,
              color: brand.accent,
            ),
            const SizedBox(height: 16),
            Text(
              strings.visualSearchHint,
              textAlign: TextAlign.center,
              style: TextStyle(color: brand.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

/// لوحة النتايج — الوصف
/// المكتشف + كلمات البحث
/// + المنتجات المطابقة.
class _ResultsPane extends StatelessWidget {
  final VisualSearchResult result;

  const _ResultsPane({required this.result});

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    const brand = BrandConfig.decoze;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // الوصف المكتشف.
          if (result.description.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: brand.surface,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    strings.visualSearchDetected,
                    style: TextStyle(
                      fontSize: 12,
                      color: brand.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(result.description),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // كلمات البحث.
          if (result.keywords.isNotEmpty) ...[
            Text(
              strings.visualSearchKeywords,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final keyword in result.keywords)
                  Chip(
                    label: Text(keyword),
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
            const SizedBox(height: 16),
          ],

          // المنتجات المطابقة.
          Text(
            strings.visualSearchResults,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          if (result.rankedProductIds.isEmpty)
            Center(
              child: Text(
                strings.visualSearchNoResults,
                textAlign: TextAlign.center,
                style: TextStyle(color: brand.textSecondary),
              ),
            )
          else
            for (final productId in result.rankedProductIds)
              VisualSearchResultCard(productId: productId),
        ],
      ),
    );
  }
}
