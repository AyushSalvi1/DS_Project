import 'dart:async';

import 'package:customer_app/features/web_search/presentation/cubit/web_search_cubit.dart';
import 'package:customer_app/features/web_search/presentation/cubit/web_search_state.dart';
import 'package:customer_app/features/web_search/presentation/widgets/listing_tile.dart';
import 'package:customer_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:customer_app/features/auth/presentation/cubit/auth_state.dart';
import 'package:decoze_core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// شاشة البحث عبر المواقع —
/// نتايج عروض التجار
/// الخارجيين مع تحويل
/// لأفضل موقع.
class WebSearchScreen extends StatelessWidget {
  final String initialQuery;

  const WebSearchScreen({super.key, this.initialQuery = ''});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    final uid = authState is AuthAuthenticated ? authState.user.uid : '';

    return Scaffold(
      appBar: AppBar(title: Text(context.strings.webSearchTitle)),
      body: BlocProvider(
        create: (_) => WebSearchCubit()
          ..search(initialQuery),
        child: BlocListener<WebSearchCubit, WebSearchState>(
          listener: (context, state) {
            // لما تظهر نتايج،
            // بنسجل نشاط بحث
            // في ذاكرة التسوق.
            if (state is WebSearchLoaded) {
              unawaited(
                ActivityRepositoryImpl().recordActivity(
                  UserActivityEntity(
                    id: 'activity-${DateTime.now().millisecondsSinceEpoch}',
                    uid: uid,
                    type: ActivityType.search,
                    query: state.query,
                    timestamp: DateTime.now(),
                  ),
                ),
              );
            }
          },
          child: _WebSearchBody(uid: uid, initialQuery: initialQuery),
        ),
      ),
    );
  }
}

class _WebSearchBody extends StatelessWidget {
  final String uid;
  final String initialQuery;

  const _WebSearchBody({required this.uid, required this.initialQuery});

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;

    return Column(
      children: [
        // حقل البحث.
        Padding(
          padding: const EdgeInsets.all(16),
          child: _SearchField(
            initialQuery: initialQuery,
            onSubmitted: (query) =>
                context.read<WebSearchCubit>().search(query),
          ),
        ),

        // النتايج.
        Expanded(
          child: BlocBuilder<WebSearchCubit, WebSearchState>(
            builder: (context, state) {
              return switch (state) {
                WebSearchInitial() => _HintPane(strings: strings),
                WebSearchLoading() =>
                  const Center(child: CircularProgressIndicator()),
                WebSearchError(:final message) =>
                  Center(child: Text(message)),
                WebSearchLoaded(:final query, :final results) =>
                  _ResultsPane(uid: uid, query: query, results: results),
              };
            },
          ),
        ),
      ],
    );
  }
}

/// حقل البحث — StatefulWidget
/// عشان نتحكم في الـ
/// TextEditingController
/// ونديسبوزه صح.
class _SearchField extends StatefulWidget {
  final String initialQuery;
  final ValueChanged<String> onSubmitted;

  const _SearchField({
    required this.initialQuery,
    required this.onSubmitted,
  });

  @override
  State<_SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<_SearchField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;

    return TextField(
      controller: _controller,
      onSubmitted: widget.onSubmitted,
      decoration: InputDecoration(
        hintText: strings.searchHint,
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        filled: true,
        fillColor: BrandConfig.decoze.surface,
      ),
    );
  }
}

class _HintPane extends StatelessWidget {
  final AppStrings strings;

  const _HintPane({required this.strings});

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
              Icons.public,
              size: 64,
              color: brand.accent,
            ),
            const SizedBox(height: 16),
            Text(
              strings.webSearchSubtitle,
              textAlign: TextAlign.center,
              style: TextStyle(color: brand.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultsPane extends StatelessWidget {
  final String uid;
  final String query;
  final List<ExternalListingEntity> results;

  const _ResultsPane({
    required this.uid,
    required this.query,
    required this.results,
  });

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;

    if (results.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            strings.webSearchNoResults,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: BrandConfig.decoze.textSecondary,
            ),
          ),
        ),
      );
    }

    // بنرتب النتايج: الأرخص
    // المتوفر أولاً.
    final sorted = [...results]
      ..sort((a, b) {
        if (a.isInStock != b.isInStock) {
          return a.isInStock ? -1 : 1;
        }
        return a.effectivePrice.compareTo(b.effectivePrice);
      });

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: sorted.length,
      itemBuilder: (context, index) {
        final listing = sorted[index];
        final isBestDeal = index == 0 && listing.isInStock;
        return ListingTile(
          listing: listing,
          uid: uid,
          isBestDeal: isBestDeal,
        );
      },
    );
  }
}
