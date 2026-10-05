import 'package:customer_app/features/ai_assistant/presentation/cubit/assistant_cubit.dart';
import 'package:customer_app/features/ai_assistant/presentation/cubit/assistant_state.dart';
import 'package:customer_app/features/ai_assistant/presentation/widgets/assistant_message_bubble.dart';
import 'package:customer_app/features/ai_assistant/presentation/widgets/assistant_suggestion_chips.dart';
import 'package:customer_app/features/ai_assistant/presentation/widgets/assistant_input_bar.dart';
import 'package:customer_app/features/product/presentation/screens/product_detail_screen.dart';
import 'package:decoze_core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// شاشة المساعد الذكي —
/// رحلة "اسأل → ابحث → حلل →
/// قارن → أوصي → وضّح → تتبّع
/// → حوّل لأفضل موقع".
///
/// الـ Cubit متسجّل في main.dart
/// (عشان يكون تاب ثابت في
/// MainShell ويتربط بالمستخدم
/// تلقائيًا)، فالشاشة هنا بتقرأه
/// بس من الـ context.
class AssistantScreen extends StatelessWidget {
  const AssistantScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.strings.aiAssistantTitle),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: context.strings.aiClearHistory,
            onPressed: () => _confirmClear(context),
          ),
        ],
      ),
      body: const _AssistantBody(),
    );
  }

  void _confirmClear(BuildContext context) {
    final strings = context.strings;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(strings.aiClearHistory),
        content: Text(strings.aiClearHistoryConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(strings.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<AssistantCubit>().clearHistory();
            },
            child: Text(strings.aiClearHistory),
          ),
        ],
      ),
    );
  }
}

class _AssistantBody extends StatelessWidget {
  const _AssistantBody();

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;

    return Column(
      children: [
        // شريط الرحلة — بيوجز
        // خطوات العملية للمستخدم.
        _FlowIndicator(strings: strings),
        const SizedBox(height: 8),

        // الرسائل.
        Expanded(
          child: BlocBuilder<AssistantCubit, AssistantState>(
            builder: (context, state) {
              if (state is AssistantCleared) {
                return _WelcomePane(strings: strings);
              }
              if (state is! AssistantLoaded) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state.messages.isEmpty) {
                return _WelcomePane(strings: strings);
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                itemCount: state.messages.length,
                itemBuilder: (context, index) {
                  final message = state.messages[index];
                  return AssistantMessageBubble(
                    message: message,
                    onProductTap: (product) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              ProductDetailScreen(productId: product.id),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),

        // اقتراحات سريعة.
        BlocBuilder<AssistantCubit, AssistantState>(
          builder: (context, state) {
            final suggestions = state is AssistantLoaded
                ? state.suggestions
                : state is AssistantCleared
                    ? state.suggestions
                    : const <String>[];
            if (suggestions.isEmpty) {
              return const SizedBox.shrink();
            }
            return AssistantSuggestionChips(
              suggestions: suggestions,
              onTap: (suggestion) =>
                  context.read<AssistantCubit>().runSuggestion(suggestion),
            );
          },
        ),

        // مؤشر التحميل أثناء
        // تفكير المساعد.
        BlocBuilder<AssistantCubit, AssistantState>(
          builder: (context, state) {
            final loading = state is AssistantLoaded && state.isLoading;
            if (!loading) return const SizedBox.shrink();
            return SizedBox(
              height: 36,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: BrandConfig.decoze.accent,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    context.strings.aiThinking,
                    style: TextStyle(
                      fontSize: 12,
                      color: BrandConfig.decoze.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          },
        ),

        // شريط الإدخال (نص + صوت).
        const AssistantInputBar(),
      ],
    );
  }
}

/// شريط بيوجز رحلة العمل
/// (Ask → Search → ... → Redirect).
class _FlowIndicator extends StatelessWidget {
  final AppStrings strings;

  const _FlowIndicator({required this.strings});

  @override
  Widget build(BuildContext context) {
    const brand = BrandConfig.decoze;
    final steps = [
      strings.aiActionSearch,
      strings.aiActionCompare,
      strings.aiActionTrack,
      strings.aiActionRedirect,
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: brand.surface,
        border: Border(
          bottom: BorderSide(color: brand.textSecondary.withValues(alpha: 0.2)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          for (var i = 0; i < steps.length; i++) ...[
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 14,
                  color: brand.accent,
                ),
                const SizedBox(width: 4),
                Text(
                  steps[i],
                  style: TextStyle(
                    fontSize: 11,
                    color: brand.textSecondary,
                  ),
                ),
              ],
            ),
            if (i < steps.length - 1)
              Icon(
                Icons.chevron_right,
                size: 14,
                color: brand.textSecondary.withValues(alpha: 0.5),
              ),
          ],
        ],
      ),
    );
  }
}

/// اللوحة الترحيبية لما
/// المحادثة فاضية.
class _WelcomePane extends StatelessWidget {
  final AppStrings strings;

  const _WelcomePane({required this.strings});

  @override
  Widget build(BuildContext context) {
    const brand = BrandConfig.decoze;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.smart_toy_outlined,
              size: 64,
              color: brand.accent,
            ),
            const SizedBox(height: 16),
            Text(
              strings.aiAssistantWelcome,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: brand.textSecondary,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              strings.aiAssistantSubtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: brand.textSecondary.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
