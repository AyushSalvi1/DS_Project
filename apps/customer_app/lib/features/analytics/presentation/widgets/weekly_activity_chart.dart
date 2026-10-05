import 'package:decoze_core/core.dart';
import 'package:flutter/material.dart';

/// رسم بياني شريطي
/// لنشاط آخر 7 أيام.
class WeeklyActivityChart extends StatelessWidget {
  final List<int> activityByDay;

  const WeeklyActivityChart({super.key, required this.activityByDay});

  @override
  Widget build(BuildContext context) {
    const brand = BrandConfig.decoze;

    if (activityByDay.isEmpty) {
      return Center(
        child: Text(
          context.strings.analyticsNoData,
          style: TextStyle(color: brand.textSecondary),
        ),
      );
    }

    final max = activityByDay.reduce(
      (a, b) => a > b ? a : b,
    );
    final safeMax = max == 0 ? 1 : max;

    // أسماء الأيام (من الأقدم للأحدث).
    const dayLabels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    final now = DateTime.now();
    final startWeekday = now.weekday % 7; // 0=Sun

    return SizedBox(
      height: 140,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < activityByDay.length; i++)
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // القيمة فوق العمود.
                  if (activityByDay[i] > 0)
                    Text(
                      '${activityByDay[i]}',
                      style: TextStyle(
                        fontSize: 10,
                        color: brand.textSecondary,
                      ),
                    ),
                  const SizedBox(height: 2),
                  // العمود.
                  Container(
                    height: (100 * activityByDay[i] / safeMax)
                        .clamp(2.0, 100.0),
                    decoration: BoxDecoration(
                      color: i == activityByDay.length - 1
                          ? brand.accent
                          : brand.accent.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 4),
                  // اسم اليوم.
                  Text(
                    dayLabels[(startWeekday + i) % 7],
                    style: TextStyle(
                      fontSize: 10,
                      color: brand.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
