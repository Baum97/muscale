import 'package:flutter_test/flutter_test.dart';
import 'package:muscale/domain/nutrients.dart';
import 'package:muscale/domain/portions.dart';

void main() {
  group('Abgeleitete Werte', () {
    test('Stärke = Kohlenhydrate − Zucker', () {
      expect(const Nutrients(carbs: 60, sugar: 12).starch, 48);
      expect(const Nutrients(carbs: 60).starch, isNull);
    });

    test('Ungesättigte Fette: berechnet aus Fett − gesättigte', () {
      const n = Nutrients(fat: 20, saturatedFat: 8);
      expect(n.unsaturatedFat, 12);
      expect(n.unsaturatedFatIsDerived, isTrue);
    });

    test('Ungesättigte Fette: exakt, wenn einfach und mehrfach angegeben', () {
      const n = Nutrients(fat: 20, saturatedFat: 8, monoUnsaturatedFat: 7, polyUnsaturatedFat: 4);
      expect(n.unsaturatedFat, 11);
      expect(n.unsaturatedFatIsDerived, isFalse);
    });
  });

  test('Nährwerte für eine Menge', () {
    final n = const Nutrients(kcal: 400, protein: 10, sugar: null).forAmount(150);
    expect(n.kcal, 600);
    expect(n.protein, 15);
    expect(n.sugar, isNull);
  });

  test('Summe markiert fehlende Angaben', () {
    final t = NutrientTotals.of([
      const Nutrients(kcal: 100, protein: 5, carbs: 10, sugar: 2, fat: 3, saturatedFat: 1),
      const Nutrients(kcal: 50, protein: 1),
    ]);
    expect(t.kcal, 150);
    expect(t.protein, 6);
    expect(t.starch, 8);
    expect(t.unsaturatedFat, 2);
    expect(t.incomplete, isTrue);
  });

  group('Mengenauswahl', () {
    test('Feste Lebensmittel mit Portionsangabe', () {
      expect(portionOptions(isLiquid: false, servingSize: 30).map((p) => p.amount), [30, 50, 100, 150]);
    });

    test('Feste Lebensmittel ohne Portionsangabe', () {
      expect(portionOptions(isLiquid: false).map((p) => p.amount), [50, 100, 150]);
    });

    test('Getränke: übliche Größen', () {
      expect(portionOptions(isLiquid: true, servingSize: 250).map((p) => p.amount), [200, 250, 330, 500]);
    });
  });
}
