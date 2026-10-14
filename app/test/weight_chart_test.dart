import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:muscale/domain/days.dart';
import 'package:muscale/domain/trend.dart';
import 'package:muscale/features/weight/weight_chart.dart';

void main() {
  setUpAll(() => initializeDateFormatting('de'));

  Widget chart(List<TrendPoint> points) => MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(child: WeightChart(points: points)),
    ),
  );

  testWidgets('Zeigt den letzten Trendwert und wechselt beim Antippen den Tag', (tester) async {
    final start = today().subtract(const Duration(days: 9));
    final points = weightTrend([for (var i = 0; i < 10; i++) WeightPoint(start.add(Duration(days: i)), 85 - i * 0.1)]);
    await tester.pumpWidget(chart(points));
    expect(
      find.textContaining('Trend ${points.last.trendKg.toStringAsFixed(1).replaceAll('.', ',')} kg'),
      findsOneWidget,
    );

    await tester.tapAt(tester.getTopLeft(find.byType(CustomPaint).last) + const Offset(42, 100));
    await tester.pump();
    expect(find.textContaining('gewogen 85,0 kg'), findsOneWidget);
  });

  testWidgets('Mit nur einer Wiegung: Hinweis statt Diagramm', (tester) async {
    await tester.pumpWidget(chart(weightTrend([WeightPoint(today(), 80)])));
    expect(find.text('Ab zwei Wiegungen erscheint hier dein Verlauf.'), findsOneWidget);
  });
}
