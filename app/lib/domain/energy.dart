/// Kalorien pro Kilogramm Körpergewichtsänderung (Mischgewebe, übliche Näherung).
const kcalPerKg = 7700.0;

enum Sex {
  male('Männlich'),
  female('Weiblich'),
  diverse('Divers');

  const Sex(this.label);
  final String label;
}

enum ActivityLevel {
  sedentary(1.2, 'Sitzend, wenig Training'),
  light(1.375, '1–3 Trainings pro Woche'),
  moderate(1.55, '3–5 Trainings pro Woche'),
  high(1.725, '6–7 Trainings pro Woche'),
  extreme(1.9, 'Täglich hart + körperliche Arbeit');

  const ActivityLevel(this.factor, this.label);
  final double factor;
  final String label;
}

enum Goal {
  cut('Diät', defaultPacePercent: -0.5, minPacePercent: -1.0, maxPacePercent: 0),
  maintain('Erhalt', defaultPacePercent: 0, minPacePercent: 0, maxPacePercent: 0),
  bulk('Aufbau', defaultPacePercent: 0.25, minPacePercent: 0, maxPacePercent: 0.5);

  const Goal(
    this.label, {
    required this.defaultPacePercent,
    required this.minPacePercent,
    required this.maxPacePercent,
  });
  final String label;

  /// Tempo in Prozent des Körpergewichts pro Woche (negativ = abnehmen).
  final double defaultPacePercent;
  final double minPacePercent;
  final double maxPacePercent;

  double clampPace(double percent) => percent.clamp(minPacePercent, maxPacePercent).toDouble();
}

/// Grundumsatz nach Mifflin-St Jeor. Bei „divers“ der Mittelwert beider Formeln.
double basalMetabolicRate({required Sex sex, required double weightKg, required double heightCm, required int age}) {
  final base = 10 * weightKg + 6.25 * heightCm - 5 * age;
  return switch (sex) {
    Sex.male => base + 5,
    Sex.female => base - 161,
    Sex.diverse => base - 78,
  };
}

/// Geschätzter Gesamtbedarf = Grundumsatz × Aktivitätsfaktor.
double estimatedTdee({
  required Sex sex,
  required double weightKg,
  required double heightCm,
  required int age,
  required ActivityLevel activity,
}) => basalMetabolicRate(sex: sex, weightKg: weightKg, heightCm: heightCm, age: age) * activity.factor;

/// Gewichtsänderung pro Woche in kg für ein Tempo in Prozent des Körpergewichts.
double paceKgPerWeek({required double pacePercent, required double weightKg}) => weightKg * pacePercent / 100;

/// Kalorienziel für ein Tempo: Bedarf + tägliche Energie der gewünschten Gewichtsänderung.
double calorieTarget({required double tdee, required double paceKgPerWeek}) => tdee + paceKgPerWeek * kcalPerKg / 7;

/// Rundet Kalorienziele auf 10 kcal.
int roundKcal(double kcal) => (kcal / 10).round() * 10;
