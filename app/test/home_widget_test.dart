import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muscale/domain/energy.dart';
import 'package:muscale/domain/nutrients.dart';
import 'package:muscale/domain/targets.dart';
import 'package:muscale/services/home_widget_sync.dart';
import 'package:muscale/theme.dart';

void main() {
  final targets = computeTargets(
    sex: Sex.male,
    birthYear: 1996,
    heightCm: 180,
    activity: ActivityLevel.moderate,
    pacePercent: 0,
    proteinPerKg: 2,
    weightKg: 85,
    currentYear: 2026,
  );

  test('Widget bekommt gerundete Tageswerte, Ziele und die App-Farbe', () {
    final totals = NutrientTotals.of([const Nutrients(kcal: 1234.6, protein: 91.4)]);
    final s = widgetSnapshot(
      day: DateTime.utc(2026, 10, 18),
      totals: totals,
      targets: targets,
      palette: AppPalette.standard,
    );
    expect(s.day, '2026-10-18');
    expect(s.kcalEaten, 1235);
    expect(s.kcalTarget, targets.calorieTarget);
    expect(s.proteinEaten, 91);
    expect(s.proteinTarget, 170);
    // Vorzeichenbehaftet, damit Android sie als Int (nicht Long) speichert.
    expect(s.primaryLight, inInclusiveRange(-0x80000000, 0x7FFFFFFF));
    expect(Color(s.primaryLight.toUnsigned(32)), buildColorScheme(Brightness.light, AppPalette.standard).primary);
  });

  test('Gleiche Werte → gleicher Stand (kein unnötiges Aktualisieren)', () {
    WidgetSnapshot make() => widgetSnapshot(
      day: DateTime.utc(2026, 10, 18),
      totals: NutrientTotals.of([const Nutrients(kcal: 500, protein: 30)]),
      targets: targets,
      palette: AppPalette.standard,
    );
    expect(make(), make());
  });

  test('Scan-Link erkennen', () {
    expect(isScanLink(Uri.parse('muscale://scan')), isTrue);
    expect(isScanLink(Uri.parse('muscale://today')), isFalse);
    expect(isScanLink(null), isFalse);
  });
}
