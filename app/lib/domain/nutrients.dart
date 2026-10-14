import 'dart:math';

/// Nährwerte pro 100 g bzw. 100 ml, wie auf dem Etikett. Fehlende Angaben sind null.
class Nutrients {
  const Nutrients({
    this.kcal,
    this.protein,
    this.carbs,
    this.sugar,
    this.fiber,
    this.fat,
    this.saturatedFat,
    this.monoUnsaturatedFat,
    this.polyUnsaturatedFat,
    this.salt,
  });

  final double? kcal;
  final double? protein;
  final double? carbs;
  final double? sugar;
  final double? fiber;
  final double? fat;
  final double? saturatedFat;
  final double? monoUnsaturatedFat;
  final double? polyUnsaturatedFat;
  final double? salt;

  /// Langkettige Kohlenhydrate (v. a. Stärke) = Kohlenhydrate − Zucker. Immer berechnet.
  double? get starch => carbs == null || sugar == null ? null : max(0, carbs! - sugar!);

  /// Ungesättigte Fette: exakt, wenn einfach und mehrfach ungesättigt angegeben sind, sonst Fett − gesättigte.
  double? get unsaturatedFat {
    if (monoUnsaturatedFat != null && polyUnsaturatedFat != null) return monoUnsaturatedFat! + polyUnsaturatedFat!;
    if (fat == null || saturatedFat == null) return null;
    return max(0, fat! - saturatedFat!);
  }

  /// True, wenn [unsaturatedFat] aus Fett − gesättigte berechnet ist.
  bool get unsaturatedFatIsDerived => monoUnsaturatedFat == null || polyUnsaturatedFat == null;

  /// Nährwerte für [amount] g bzw. ml.
  Nutrients forAmount(double amount) {
    final f = amount / 100;
    double? s(double? v) => v == null ? null : v * f;
    return Nutrients(
      kcal: s(kcal),
      protein: s(protein),
      carbs: s(carbs),
      sugar: s(sugar),
      fiber: s(fiber),
      fat: s(fat),
      saturatedFat: s(saturatedFat),
      monoUnsaturatedFat: s(monoUnsaturatedFat),
      polyUnsaturatedFat: s(polyUnsaturatedFat),
      salt: s(salt),
    );
  }
}

/// Summe über mehrere Einträge. Fehlende Angaben zählen als 0; [incomplete] zeigt, ob etwas fehlte.
class NutrientTotals {
  double kcal = 0;
  double protein = 0;
  double carbs = 0;
  double sugar = 0;
  double starch = 0;
  double fiber = 0;
  double fat = 0;
  double saturatedFat = 0;
  double unsaturatedFat = 0;
  double salt = 0;
  bool incomplete = false;

  void add(Nutrients n) {
    double v(double? x) {
      if (x == null) incomplete = true;
      return x ?? 0;
    }

    kcal += v(n.kcal);
    protein += v(n.protein);
    carbs += v(n.carbs);
    sugar += v(n.sugar);
    starch += v(n.starch);
    fiber += n.fiber ?? 0;
    fat += v(n.fat);
    saturatedFat += v(n.saturatedFat);
    unsaturatedFat += v(n.unsaturatedFat);
    salt += n.salt ?? 0;
  }

  static NutrientTotals of(Iterable<Nutrients> items) {
    final totals = NutrientTotals();
    items.forEach(totals.add);
    return totals;
  }
}
