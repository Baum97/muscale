import 'dart:math';

import 'package:flutter/material.dart';

import '../../domain/days.dart';
import '../../domain/trend.dart';
import '../../widgets/format.dart';

enum ChartRange {
  month('30 Tage', 30),
  quarter('90 Tage', 90),
  all('Alles', null);

  const ChartRange(this.label, this.days);
  final String label;
  final int? days;
}

/// Gewichtsverlauf: Wiegungen als Punkte, geglätteter Trend als Linie. Antippen/Ziehen zeigt den Tag.
class WeightChart extends StatefulWidget {
  const WeightChart({super.key, required this.points});

  final List<TrendPoint> points;

  @override
  State<WeightChart> createState() => _WeightChartState();
}

class _WeightChartState extends State<WeightChart> {
  ChartRange _range = ChartRange.month;
  int? _selected;

  List<TrendPoint> get _visible {
    final days = _range.days;
    if (days == null || widget.points.isEmpty) return widget.points;
    final from = today().subtract(Duration(days: days - 1));
    return widget.points.where((p) => !p.day.isBefore(from)).toList();
  }

  void _select(Offset local, Size size, List<TrendPoint> points) {
    if (points.isEmpty) return;
    final geometry = _ChartGeometry(points, size);
    var best = 0;
    for (var i = 1; i < points.length; i++) {
      if ((geometry.x(points[i].day) - local.dx).abs() < (geometry.x(points[best].day) - local.dx).abs()) best = i;
    }
    setState(() => _selected = best);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final points = _visible;
    final selected = _selected != null && _selected! < points.length ? points[_selected!] : null;
    final shown = selected ?? (points.isEmpty ? null : points.last);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SegmentedButton<ChartRange>(
          segments: [for (final r in ChartRange.values) ButtonSegment(value: r, label: Text(r.label))],
          selected: {_range},
          onSelectionChanged: (r) => setState(() {
            _range = r.single;
            _selected = null;
          }),
        ),
        const SizedBox(height: 12),
        // Kopfzeile statt Tooltip: zeigt den gewählten (oder letzten) Tag.
        ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 40),
          child: shown == null
              ? const SizedBox.shrink()
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Trend ${kg(shown.trendKg)}', style: theme.textTheme.titleMedium),
                    Text(
                      '${weekdayDate(shown.day)} · gewogen ${kg(shown.kg)}',
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
        ),
        SizedBox(
          height: 200,
          child: points.length < 2
              ? Center(
                  child: Text(
                    'Ab zwei Wiegungen erscheint hier dein Verlauf.',
                    style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                  ),
                )
              : LayoutBuilder(
                  builder: (context, constraints) {
                    final size = constraints.biggest;
                    return GestureDetector(
                      onTapDown: (d) => _select(d.localPosition, size, points),
                      onHorizontalDragUpdate: (d) => _select(d.localPosition, size, points),
                      child: CustomPaint(
                        size: size,
                        painter: _WeightChartPainter(
                          points: points,
                          selected: selected,
                          trendColor: theme.colorScheme.primary,
                          dotColor: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.55),
                          gridColor: theme.colorScheme.outlineVariant,
                          labelStyle: theme.textTheme.bodySmall!.copyWith(color: theme.colorScheme.onSurfaceVariant),
                          surface: theme.colorScheme.surface,
                        ),
                      ),
                    );
                  },
                ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _Legend(color: theme.colorScheme.primary, line: true, label: 'Trend'),
            const SizedBox(width: 16),
            _Legend(color: theme.colorScheme.onSurfaceVariant, line: false, label: 'Wiegung'),
          ],
        ),
      ],
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.line, required this.label});
  final Color color;
  final bool line;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: line ? 16 : 8,
          height: line ? 2 : 8,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(line ? 1 : 4)),
        ),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

/// Skalen des Diagramms; links Platz für die kg-Beschriftung, unten für die Daten.
class _ChartGeometry {
  _ChartGeometry(this.points, this.size) {
    final values = [
      for (final p in points) ...[p.kg, p.trendKg],
    ];
    final lo = values.reduce(min), hi = values.reduce(max);
    final pad = max(0.5, (hi - lo) * 0.1);
    minKg = ((lo - pad) * 2).floorToDouble() / 2;
    maxKg = ((hi + pad) * 2).ceilToDouble() / 2;
    first = points.first.day;
    spanDays = max(1, daysBetween(first, points.last.day));
  }

  static const left = 40.0, right = 8.0, top = 8.0, bottom = 22.0;

  final List<TrendPoint> points;
  final Size size;
  late final double minKg, maxKg;
  late final DateTime first;
  late final int spanDays;

  double x(DateTime day) => left + (size.width - left - right) * daysBetween(first, day) / spanDays;
  double y(double kg) => top + (size.height - top - bottom) * (1 - (kg - minKg) / (maxKg - minKg));
}

class _WeightChartPainter extends CustomPainter {
  _WeightChartPainter({
    required this.points,
    required this.selected,
    required this.trendColor,
    required this.dotColor,
    required this.gridColor,
    required this.labelStyle,
    required this.surface,
  });

  final List<TrendPoint> points;
  final TrendPoint? selected;
  final Color trendColor, dotColor, gridColor, surface;
  final TextStyle labelStyle;

  @override
  void paint(Canvas canvas, Size size) {
    final g = _ChartGeometry(points, size);
    final grid = Paint()
      ..color = gridColor
      ..strokeWidth = 1;

    // Drei Hilfslinien mit kg-Beschriftung.
    for (final kgValue in [g.minKg, (g.minKg + g.maxKg) / 2, g.maxKg]) {
      final y = g.y(kgValue);
      canvas.drawLine(Offset(_ChartGeometry.left, y), Offset(size.width - _ChartGeometry.right, y), grid);
      _text(canvas, number(kgValue), Offset(0, y - 7), width: _ChartGeometry.left - 6, align: TextAlign.right);
    }
    // Erstes und letztes Datum.
    final labelY = size.height - _ChartGeometry.bottom + 6;
    _text(canvas, shortDate(points.first.day), Offset(_ChartGeometry.left, labelY), width: 80);
    _text(
      canvas,
      shortDate(points.last.day),
      Offset(size.width - _ChartGeometry.right - 80, labelY),
      width: 80,
      align: TextAlign.right,
    );

    // Auswahl: senkrechte Linie.
    if (selected != null) {
      final x = g.x(selected!.day);
      canvas.drawLine(Offset(x, _ChartGeometry.top), Offset(x, size.height - _ChartGeometry.bottom), grid);
    }

    // Wiegungen als Punkte.
    final dot = Paint()..color = dotColor;
    for (final p in points) {
      canvas.drawCircle(Offset(g.x(p.day), g.y(p.kg)), 3, dot);
    }

    // Trendlinie, 2 px.
    final path = Path()..moveTo(g.x(points.first.day), g.y(points.first.trendKg));
    for (final p in points.skip(1)) {
      path.lineTo(g.x(p.day), g.y(p.trendKg));
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = trendColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round,
    );

    // Gewählter Trendpunkt mit Ring in Hintergrundfarbe.
    if (selected != null) {
      final c = Offset(g.x(selected!.day), g.y(selected!.trendKg));
      canvas.drawCircle(c, 6, Paint()..color = surface);
      canvas.drawCircle(c, 4.5, Paint()..color = trendColor);
    }
  }

  void _text(Canvas canvas, String text, Offset at, {required double width, TextAlign align = TextAlign.left}) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: labelStyle),
      textAlign: align,
      textDirection: TextDirection.ltr,
      maxLines: 1,
      ellipsis: '…',
    )..layout(minWidth: width, maxWidth: width);
    painter.paint(canvas, at);
  }

  @override
  bool shouldRepaint(_WeightChartPainter old) =>
      old.points != points || old.selected != selected || old.trendColor != trendColor || old.surface != surface;
}
