import 'energy.dart';
import 'macros.dart';

/// Alle Tagesziele für das aktuelle Profil und Gewicht.
class Targets {
  const Targets({
    required this.weightKg,
    required this.age,
    required this.bmr,
    required this.estimatedTdee,
    required this.paceKgPerWeek,
    required this.calorieTarget,
    required this.fromCheckIn,
    required this.macros,
  });

  final double weightKg;
  final int age;
  final double bmr;
  final double estimatedTdee;
  final double paceKgPerWeek;
  final int calorieTarget;

  /// Ziel stammt aus einem bestätigten Check-in statt aus der Startschätzung.
  final bool fromCheckIn;
  final MacroTargets macros;

  bool get belowBmr => calorieTarget < bmr;
}

Targets computeTargets({
  required Sex sex,
  required int birthYear,
  required double heightCm,
  required ActivityLevel activity,
  required double pacePercent,
  required double proteinPerKg,
  required double weightKg,
  required int currentYear,
  int? calorieTargetOverride,
}) {
  final age = currentYear - birthYear;
  final bmr = basalMetabolicRate(sex: sex, weightKg: weightKg, heightCm: heightCm, age: age);
  final tdee = bmr * activity.factor;
  final pace = paceKgPerWeek(pacePercent: pacePercent, weightKg: weightKg);
  final kcal = calorieTargetOverride ?? roundKcal(calorieTarget(tdee: tdee, paceKgPerWeek: pace));
  return Targets(
    weightKg: weightKg,
    age: age,
    bmr: bmr,
    estimatedTdee: tdee,
    paceKgPerWeek: pace,
    calorieTarget: kcal,
    fromCheckIn: calorieTargetOverride != null,
    macros: macroTargets(kcal: kcal.toDouble(), weightKg: weightKg, proteinPerKg: proteinPerKg),
  );
}
