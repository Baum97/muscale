import 'dart:math';

/// Tagesziele für Makronährstoffe in Gramm.
class MacroTargets {
  const MacroTargets({required this.protein, required this.fat, required this.carbs});

  final double protein;
  final double fat;
  final double carbs;

  /// Richtwert, kein hartes Ziel.
  static const fiberGuide = 30.0;

  /// Gesättigte Fette sollen unter 10 % der Kalorien bleiben.
  static double saturatedFatLimit(double kcal) => kcal * 0.10 / 9;
}

const defaultProteinPerKg = 2.0;
const fatPerKg = 0.8;
const minFatShare = 0.20;

/// Kraftsport-Standard: Eiweiß pro kg, Fett mindestens 0,8 g/kg bzw. 20 % der Kalorien, Rest Kohlenhydrate.
MacroTargets macroTargets({required double kcal, required double weightKg, double proteinPerKg = defaultProteinPerKg}) {
  final protein = weightKg * proteinPerKg;
  final fat = max(weightKg * fatPerKg, kcal * minFatShare / 9);
  final carbs = max(0.0, (kcal - protein * 4 - fat * 9) / 4);
  return MacroTargets(protein: protein, fat: fat, carbs: carbs);
}
