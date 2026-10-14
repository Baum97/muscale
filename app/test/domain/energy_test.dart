import 'package:flutter_test/flutter_test.dart';
import 'package:muscale/domain/energy.dart';
import 'package:muscale/domain/macros.dart';

void main() {
  group('Grundumsatz (Mifflin-St Jeor)', () {
    test('Mann, 85 kg, 180 cm, 30 Jahre', () {
      expect(basalMetabolicRate(sex: Sex.male, weightKg: 85, heightCm: 180, age: 30), 1830);
    });

    test('Frau, 65 kg, 168 cm, 28 Jahre', () {
      expect(basalMetabolicRate(sex: Sex.female, weightKg: 65, heightCm: 168, age: 28), 1399);
    });

    test('Divers ist der Mittelwert beider Formeln', () {
      final m = basalMetabolicRate(sex: Sex.male, weightKg: 70, heightCm: 175, age: 25);
      final f = basalMetabolicRate(sex: Sex.female, weightKg: 70, heightCm: 175, age: 25);
      expect(basalMetabolicRate(sex: Sex.diverse, weightKg: 70, heightCm: 175, age: 25), (m + f) / 2);
    });
  });

  test('Gesamtbedarf = Grundumsatz × Aktivitätsfaktor', () {
    final tdee = estimatedTdee(sex: Sex.male, weightKg: 85, heightCm: 180, age: 30, activity: ActivityLevel.moderate);
    expect(tdee, closeTo(1830 * 1.55, 0.001));
  });

  test('Kalorienziel: 0,5 kg pro Woche weniger = 550 kcal pro Tag Defizit', () {
    expect(calorieTarget(tdee: 2930, paceKgPerWeek: -0.5), 2380);
  });

  test('Tempo wird auf die Grenzen des Ziels begrenzt', () {
    expect(Goal.cut.clampPace(-2), -1.0);
    expect(Goal.bulk.clampPace(1), 0.5);
    expect(Goal.maintain.clampPace(-0.5), 0);
  });

  group('Makro-Ziele', () {
    test('Eiweiß 2 g/kg, Fett 0,8 g/kg, Rest Kohlenhydrate', () {
      final t = macroTargets(kcal: 2800, weightKg: 80);
      expect(t.protein, 160);
      expect(t.fat, 64); // 0,8 g/kg > 20 % der Kalorien (62 g)
      expect(t.carbs, closeTo((2800 - 160 * 4 - t.fat * 9) / 4, 0.001));
    });

    test('Kohlenhydrate werden nie negativ', () {
      expect(macroTargets(kcal: 800, weightKg: 100).carbs, 0);
    });
  });
}
