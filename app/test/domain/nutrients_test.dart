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

  group('Rezept', () {
    test('Nährwerte pro 100 g des fertigen Gerichts', () {
      // 100 g Haferflocken + 300 ml Milch, eingekocht auf 350 g
      final n = recipeNutrientsPer100([
        (const Nutrients(kcal: 372, protein: 13.5, carbs: 58.7, sugar: 0.7, fat: 7, saturatedFat: 1.3), 100),
        (const Nutrients(kcal: 64, protein: 3.4, carbs: 4.8, sugar: 4.8, fat: 3.5, saturatedFat: 2.3), 300),
      ], 350);
      expect(n.kcal, closeTo((372 + 192) / 3.5, 1e-9));
      expect(n.protein, closeTo((13.5 + 10.2) / 3.5, 1e-9));
      expect(n.saturatedFat, closeTo((1.3 + 6.9) / 3.5, 1e-9));
      expect(n.fiber, isNull);
    });

    test('Einfach/mehrfach ungesättigt nur, wenn alle Zutaten sie angeben', () {
      final n = recipeNutrientsPer100([
        (const Nutrients(fat: 10, saturatedFat: 2, monoUnsaturatedFat: 5, polyUnsaturatedFat: 3), 100),
        (const Nutrients(fat: 10, saturatedFat: 4), 100),
      ], 200);
      expect(n.monoUnsaturatedFat, isNull);
      expect(n.unsaturatedFat, 7); // (20 − 6) / 2
    });
  });
}
