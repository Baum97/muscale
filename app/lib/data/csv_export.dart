import 'package:intl/intl.dart';

import '../domain/days.dart';
import '../domain/trend.dart';
import 'database.dart';

/// CSV für Excel/LibreOffice in deutscher Einstellung: Semikolon, Dezimalkomma, UTF-8 mit BOM.
const _bom = '\uFEFF';
final _decimal = NumberFormat('0.##', 'de');

String _cell(Object? value) {
  final text = switch (value) {
    null => '',
    double v => _decimal.format(v),
    _ => value.toString(),
  };
  return text.contains(RegExp(r'[;"\n\r]')) ? '"${text.replaceAll('"', '""')}"' : text;
}

String _csv(List<String> header, Iterable<List<Object?>> rows) {
  final lines = [header.map(_cell).join(';'), for (final r in rows) r.map(_cell).join(';')];
  return '$_bom${lines.join('\r\n')}\r\n';
}

/// Alle Tagebuch-Einträge, eine Zeile pro Eintrag, Nährwerte für die gegessene Menge.
Future<String> diaryCsv(AppDatabase db) async {
  final entries = await db.entriesBetween('0000-01-01', '9999-12-31');
  entries.sort((a, b) {
    final byDay = a.entry.day.compareTo(b.entry.day);
    if (byDay != 0) return byDay;
    final byMeal = a.entry.meal.index.compareTo(b.entry.meal.index);
    return byMeal != 0 ? byMeal : a.entry.createdAt.compareTo(b.entry.createdAt);
  });
  return _csv(
    [
      'Datum',
      'Mahlzeit',
      'Lebensmittel',
      'Marke',
      'Menge',
      'Einheit',
      'kcal',
      'Eiweiß (g)',
      'Kohlenhydrate (g)',
      'Zucker (g)',
      'Stärke ≈ (g)',
      'Ballaststoffe (g)',
      'Fett (g)',
      'Gesättigte Fettsäuren (g)',
      'Ungesättigte Fettsäuren ≈ (g)',
      'Salz (g)',
    ],
    [
      for (final e in entries)
        [
          e.entry.day,
          e.entry.meal.label,
          e.food.name,
          e.food.brand,
          e.entry.amount,
          e.food.isLiquid ? 'ml' : 'g',
          e.nutrients.kcal,
          e.nutrients.protein,
          e.nutrients.carbs,
          e.nutrients.sugar,
          e.nutrients.starch,
          e.nutrients.fiber,
          e.nutrients.fat,
          e.nutrients.saturatedFat,
          e.nutrients.unsaturatedFat,
          e.nutrients.salt,
        ],
    ],
  );
}

/// Alle Wiegungen mit geglättetem Trend.
Future<String> weightCsv(AppDatabase db) async {
  final weights = await db.select(db.weightEntries).get();
  final trend = weightTrend([for (final w in weights) WeightPoint(parseDayKey(w.day), w.kg)]);
  return _csv(
    ['Datum', 'Gewicht (kg)', 'Trend (kg)'],
    [
      for (final p in trend) [dayKey(p.day), p.kg, double.parse(p.trendKg.toStringAsFixed(2))],
    ],
  );
}
