import 'package:flutter_test/flutter_test.dart';
import 'package:muscale/domain/trend.dart';

final start = DateTime.utc(2026, 10, 1);
DateTime day(int i) => start.add(Duration(days: i));

/// 14 Tage, Gewicht sinkt gleichmäßig um [perDay].
List<WeightPoint> linearWeights({double from = 85, required double perDay, int every = 1}) => [
  for (var i = 0; i < 14; i += every) WeightPoint(day(i), from + perDay * i),
];

List<DayIntake> intakes(double kcal, {int every = 1}) => [
  for (var i = 0; i < 14; i++) DayIntake(day(i), kcal, complete: i % every == 0),
];

void main() {
  group('Gewichtstrend', () {
    test('Trend startet beim ersten Gewicht und folgt geglättet', () {
      final t = weightTrend([WeightPoint(day(0), 80), WeightPoint(day(1), 81)]);
      expect(t.first.trendKg, 80);
      expect(t.last.trendKg, closeTo(80.1, 1e-9));
    });

    test('Lücke von 2 Tagen zählt wie zwei Tage mit demselben Gewicht', () {
      final gap = weightTrend([WeightPoint(day(0), 80), WeightPoint(day(2), 82)]);
      // 1 − 0,9² = 0,19
      expect(gap.last.trendKg, closeTo(80 + 0.19 * 2, 1e-9));
    });
  });

  group('Auswertung 14 Tage', () {
    test('Beispiel aus dem Konzept: Ø 2600 kcal, −0,6 kg in 14 Tagen → Bedarf ≈ 2930 kcal', () {
      final e = evaluateEnergy(
        end: day(13),
        intakes: intakes(2600),
        weights: linearWeights(perDay: -0.6 / 14),
      );
      expect(e.isValid, isTrue);
      expect(e.measuredTdee, closeTo(2930, 0.5));
      expect(e.actualPaceKgPerWeek, closeTo(-0.3, 1e-9));
    });

    test('Jeden 2. Tag tracken und wiegen reicht', () {
      final e = evaluateEnergy(
        end: day(13),
        intakes: intakes(2600, every: 2),
        weights: linearWeights(perDay: -0.05, every: 2),
      );
      expect(e.completeDays, 7);
      expect(e.weighIns, 7);
      expect(e.isValid, isTrue);
    });

    test('Zu wenig Daten: zeigt, was fehlt', () {
      final e = evaluateEnergy(
        end: day(13),
        intakes: intakes(2600, every: 3),
        weights: linearWeights(perDay: -0.05, every: 3),
      );
      expect(e.isValid, isFalse);
      expect(e.missingCompleteDays, 2); // 5 von 7
      expect(e.missingWeighIns, 2);
      expect(e.measuredTdee, isNull);
    });

    test('Nicht abgehakte Tage zählen nicht in den Durchschnitt', () {
      final days = [for (var i = 0; i < 14; i++) DayIntake(day(i), i.isEven ? 2500 : 1200, complete: i.isEven)];
      final e = evaluateEnergy(end: day(13), intakes: days, weights: linearWeights(perDay: 0));
      expect(e.averageIntake, 2500);
      expect(e.measuredTdee, closeTo(2500, 1e-6));
    });

    test('Daten außerhalb des Zeitraums werden ignoriert', () {
      final e = evaluateEnergy(
        end: day(13),
        intakes: [...intakes(2600), DayIntake(day(-1), 9000, complete: true)],
        weights: [...linearWeights(perDay: 0), WeightPoint(day(-5), 120)],
      );
      expect(e.averageIntake, 2600);
      expect(e.slopeKgPerDay, closeTo(0, 1e-9));
    });
  });

  group('Empfehlung', () {
    EnergyEvaluation eval(double perDay) => evaluateEnergy(
      end: day(13),
      intakes: intakes(2600),
      weights: linearWeights(perDay: perDay),
    );

    test('Langsamer als gewünscht → senken, max. 200 kcal pro Schritt', () {
      final r = recommend(evaluation: eval(-0.6 / 14), currentTarget: 2600, desiredPaceKgPerWeek: -0.5, bmr: 1830);
      expect(r.kind, RecommendationKind.lower);
      expect(r.newTarget, 2400);
      expect(r.belowBmr, isFalse);
    });

    test('Im Zielkorridor → bestärken', () {
      final r = recommend(evaluation: eval(-0.5 / 7), currentTarget: 2600, desiredPaceKgPerWeek: -0.5, bmr: 1830);
      expect(r.kind, RecommendationKind.onTrack);
    });

    test('Aufbau, Gewicht stagniert → erhöhen', () {
      final r = recommend(evaluation: eval(0), currentTarget: 2600, desiredPaceKgPerWeek: 0.25, bmr: 1830);
      expect(r.kind, RecommendationKind.raise);
      expect(r.newTarget, 2800);
    });

    test('Unter Grundumsatz → Warnhinweis', () {
      final r = recommend(evaluation: eval(0), currentTarget: 2000, desiredPaceKgPerWeek: -0.8, bmr: 1830);
      expect(r.newTarget, 1800);
      expect(r.belowBmr, isTrue);
    });

    test('Zu wenig Daten → keine Empfehlung', () {
      final e = evaluateEnergy(end: day(13), intakes: const [], weights: const []);
      final r = recommend(evaluation: e, currentTarget: 2600, desiredPaceKgPerWeek: -0.5, bmr: 1830);
      expect(r.kind, RecommendationKind.insufficientData);
    });
  });

  group('Waagen-Import', () {
    test('Erste Messung des Tages zählt, vorhandene Tage bleiben unberührt', () {
      final result = weightsToImport(
        [
          (DateTime(2026, 10, 1, 19, 30), 85.9),
          (DateTime(2026, 10, 1, 7, 5), 85.1),
          (DateTime(2026, 10, 2, 7, 0), 84.8),
          (DateTime(2026, 10, 3, 6, 50), 84.6),
        ],
        {DateTime.utc(2026, 10, 2)},
      );
      expect(result.map((w) => (w.day, w.kg)), [(DateTime.utc(2026, 10, 1), 85.1), (DateTime.utc(2026, 10, 3), 84.6)]);
    });
  });
}
