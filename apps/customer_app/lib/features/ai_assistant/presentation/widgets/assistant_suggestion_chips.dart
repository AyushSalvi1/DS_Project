import 'package:decoze_core/core.dart';
import 'package:flutter/material.dart';

/// أزرار الاقتراحات السريعة
/// تحت رد المساعد.
class AssistantSuggestionChips extends StatelessWidget {
  final List<String> suggestions;
  final ValueChanged<String> onTap;

  const AssistantSuggestionChips({
    super.key,
    required this.suggestions,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const brand = BrandConfig.decoze;

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        itemCount: suggestions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          return ActionChip(
            label: Text(
              suggestions[index],
              style: TextStyle(
                fontSize: 13,
                color: brand.accent,
              ),
            ),
            backgroundColor: brand.surface,
            side: BorderSide(color: brand.accent.withValues(alpha: 0.4)),
            onPressed: () => onTap(suggestions[index]),
          );
        },
      ),
    );
  }
}
