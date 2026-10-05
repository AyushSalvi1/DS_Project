import 'package:decoze_core/core.dart';
import 'package:flutter/material.dart';

/// رسم بياني بسيط لتاريخ
/// السعر (خط + نقاط) — مبني
/// بـ CustomPainter عشان
/// يشتغل من غير أي حزمة
/// خارجية إضافية.
class PriceHistoryChart extends StatelessWidget {
  final List<PricePoint> points;

  const PriceHistoryChart({super.key, required this.points});

  @override
  Widget build(BuildContext context) {
    const brand = BrandConfig.decoze;

    return CustomPaint(
      size: Size(double.infinity, 180),
      painter: _PriceChartPainter(
        points: points,
        lineColor: brand.accent,
        gridColor: brand.textSecondary.withValues(alpha: 0.15),
        textColor: brand.textSecondary,
      ),
    );
  }
}

class _PriceChartPainter extends CustomPainter {
  final List<PricePoint> points;
  final Color lineColor;
  final Color gridColor;
  final Color textColor;

  _PriceChartPainter({
    required this.points,
    required this.lineColor,
    required this.gridColor,
    required this.textColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty || size.isEmpty) return;

    final prices = points.map((p) => p.price).toList();
    final minPrice = prices.reduce((a, b) => a < b ? a : b);
    final maxPrice = prices.reduce((a, b) => a > b ? a : b);
    final priceRange = (maxPrice - minPrice).abs();
    final safeRange = priceRange == 0 ? 1.0 : priceRange;

    final padding = const EdgeInsets.only(
      left: 8,
      right: 8,
      top: 16,
      bottom: 24,
    );
    final chartWidth = size.width - padding.horizontal;
    final chartHeight = size.height - padding.vertical;

    // خطوط شبكة أفقية.
    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    for (var i = 0; i <= 3; i++) {
      final y = padding.top + (chartHeight / 3) * i;
      canvas.drawLine(Offset(padding.left, y), Offset(size.width - padding.right, y), gridPaint);
    }

    // نقاط الرسم.
    final offsets = <Offset>[];
    for (var i = 0; i < points.length; i++) {
      final x = points.length == 1
          ? padding.left + chartWidth / 2
          : padding.left + (chartWidth / (points.length - 1)) * i;
      final normalized = (points[i].price - minPrice) / safeRange;
      final y = padding.top + chartHeight * (1 - normalized);
      offsets.add(Offset(x, y));
    }

    // مساحة تحت المنحنى.
    final areaPath = Path()
      ..moveTo(offsets.first.dx, padding.top + chartHeight);
    for (final offset in offsets) {
      areaPath.lineTo(offset.dx, offset.dy);
    }
    areaPath.lineTo(offsets.last.dx, padding.top + chartHeight);
    areaPath.close();

    final areaPaint = Paint()
      ..color = lineColor.withValues(alpha: 0.12)
      ..style = PaintingStyle.fill;
    canvas.drawPath(areaPath, areaPaint);

    // الخط الرئيسي.
    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPolyline(offsets, false, linePaint);

    // نقاط البداية والنهاية.
    final dotPaint = Paint()..color = lineColor;
    canvas.drawCircle(offsets.first, 3.5, dotPaint);
    canvas.drawCircle(offsets.last, 3.5, dotPaint);

    // أقل/أعلى سعر (ليبل).
    final textStyle = TextStyle(fontSize: 10, color: textColor);
    _drawLabel(
      canvas,
      textStyle,
      '${minPrice.toStringAsFixed(0)}',
      Offset(padding.left, padding.top + chartHeight + 4),
    );
    _drawLabel(
      canvas,
      textStyle,
      '${maxPrice.toStringAsFixed(0)}',
      Offset(padding.left, padding.top - 2),
    );
  }

  void _drawLabel(Canvas canvas, TextStyle style, String text, Offset offset) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(_PriceChartPainter old) =>
      old.points != points ||
      old.lineColor != lineColor;
}
