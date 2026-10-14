import 'dart:math';

import 'days.dart';
import 'energy.dart';

class WeightPoint {
  const WeightPoint(this.day, this.kg);
  final DateTime day;
  final double kg;
}

class TrendPoint {
  const TrendPoint(this.day, this.kg, this.trendKg);
  final DateTime day;
  final double kg;
  final double trendKg;
}

/// Glättung pro Tag. 0,1 = jeder Tag fließt mit 10 % in den Trend ein.
const trendSmoothing = 0.1;

/// Geglätteter Gewichtstrend (exponentieller Durchschnitt). Lücken zwischen Wiegungen werden so gewichtet,
/// als wäre an jedem Tag dazwischen dasselbe Gewicht gemessen worden – wer nur jeden 2. Tag wiegt,
/// bekommt also denselben Trendverlauf wie bei täglichem Wiegen.
List<TrendPoint> weightTrend(Iterable<WeightPoint> weights) {
  final sorted = weights.toList()..sort((a, b) => a.day.compareTo(b.day));
  final result = <TrendPoint>[];
  for (final w in sorted) {
    if (result.isEmpty) {
      result.add(TrendPoint(w.day, w.kg, w.kg));
      continue;
    }
    final prev = result.last;
    final gap = max(1, daysBetween(prev.day, w.day));
    final alpha = 1 - pow(1 - trendSmoothing, gap);
    result.add(TrendPoint(w.day, w.kg, prev.trendKg + alpha * (w.kg - prev.trendKg)));
  }
  return result;
}

class DayIntake {
  const DayIntake(this.day, this.kcal, {required this.complete});
  final DateTime day;
  final double kcal;

  /// Vom Nutzer als „vollständig getrackt“ abgehakt.
  final bool complete;
}

const evaluationWindowDays = 14;
const minCompleteDays = 7;
const minWeighIns = 7;

/// Auswertung eines 14-Tage-Zeitraums: gemessener Bedarf aus Ø Kalorien und Gewichtsverlauf.
class EnergyEvaluation {
  const EnergyEvaluation({
    required this.windowStart,
    required this.windowEnd,
    required this.completeDays,
    required this.weighIns,
    this.averageIntake,
    this.slopeKgPerDay,
  });

  final DateTime windowStart;
  final DateTime windowEnd;
  final int completeDays;
  final int weighIns;
  final double? averageIntake;

  /// Steigung der Ausgleichsgeraden durch die Wiegungen im Zeitraum.
  final double? slopeKgPerDay;

  int get missingCompleteDays => max(0, minCompleteDays - completeDays);
  int get missingWeighIns => max(0, minWeighIns - weighIns);
  bool get isValid => missingCompleteDays == 0 && missingWeighIns == 0 && slopeKgPerDay != null;

  /// Gewichtsänderung über den ganzen Zeitraum laut Ausgleichsgerade.
  double? get changeKg => isValid ? slopeKgPerDay! * evaluationWindowDays : null;

  /// Gemessener Bedarf = Ø kcal − tägliche Gewichtsänderung × 7700.
  double? get measuredTdee => isValid ? averageIntake! - slopeKgPerDay! * kcalPerKg : null;

  /// Tatsächliches Tempo in kg pro Woche.
  double? get actualPaceKgPerWeek => isValid ? slopeKgPerDay! * 7 : null;
}

/// Wertet die 14 Tage bis einschließlich [end] aus.
///
/// Nur als vollständig abgehakte Tage gehen in den Durchschnitt ein; Tage ohne Eintrag zählen mit diesem
/// Durchschnitt. Die Gewichtsänderung kommt aus einer Ausgleichsgeraden durch alle Wiegungen im Zeitraum –
/// anders als der geglättete Trend hinkt sie nicht hinterher, einzelne Ausreißer wiegen trotzdem wenig.
EnergyEvaluation evaluateEnergy({
  required DateTime end,
  required Iterable<DayIntake> intakes,
  required Iterable<WeightPoint> weights,
}) {
  final windowEnd = dayOf(end);
  final windowStart = windowEnd.subtract(const Duration(days: evaluationWindowDays - 1));
  bool inWindow(DateTime d) => !d.isBefore(windowStart) && !d.isAfter(windowEnd);

  final complete = intakes.where((i) => i.complete && inWindow(i.day)).toList();
  final byDay = <DateTime, double>{for (final w in weights.where((w) => inWindow(w.day))) w.day: w.kg};

  return EnergyEvaluation(
    windowStart: windowStart,
    windowEnd: windowEnd,
    completeDays: complete.length,
    weighIns: byDay.length,
    averageIntake: complete.isEmpty ? null : complete.map((i) => i.kcal).reduce((a, b) => a + b) / complete.length,
    slopeKgPerDay: _slope([for (final e in byDay.entries) (daysBetween(windowStart, e.key).toDouble(), e.value)]),
  );
}

/// Steigung der Regressionsgeraden (kleinste Quadrate); null bei weniger als zwei verschiedenen Tagen.
double? _slope(List<(double, double)> points) {
  if (points.length < 2) return null;
  final n = points.length;
  final mx = points.map((p) => p.$1).reduce((a, b) => a + b) / n;
  final my = points.map((p) => p.$2).reduce((a, b) => a + b) / n;
  var sxy = 0.0, sxx = 0.0;
  for (final (x, y) in points) {
    sxy += (x - mx) * (y - my);
    sxx += (x - mx) * (x - mx);
  }
  return sxx == 0 ? null : sxy / sxx;
}

enum RecommendationKind { onTrack, lower, raise, insufficientData }

class Recommendation {
  const Recommendation(this.kind, {this.newTarget, this.belowBmr = false});
  final RecommendationKind kind;
  final int? newTarget;

  /// Neues Ziel liegt unter dem Grundumsatz → nur mit Warnhinweis.
  final bool belowBmr;
}

/// Maximale Änderung des Kalorienziels pro Anpassung.
const maxAdjustmentKcal = 200.0;

/// Vergleicht das tatsächliche mit dem gewünschten Tempo und schlägt ggf. ein neues Ziel vor.
/// Das Ziel wird nie automatisch geändert – der Nutzer bestätigt.
Recommendation recommend({
  required EnergyEvaluation evaluation,
  required int currentTarget,
  required double desiredPaceKgPerWeek,
  required double bmr,
}) {
  final tdee = evaluation.measuredTdee;
  final actual = evaluation.actualPaceKgPerWeek;
  if (tdee == null || actual == null) return const Recommendation(RecommendationKind.insufficientData);

  final tolerance = max(0.1, desiredPaceKgPerWeek.abs() * 0.25);
  if ((actual - desiredPaceKgPerWeek).abs() <= tolerance) return const Recommendation(RecommendationKind.onTrack);

  final ideal = calorieTarget(tdee: tdee, paceKgPerWeek: desiredPaceKgPerWeek);
  final step = (ideal - currentTarget).clamp(-maxAdjustmentKcal, maxAdjustmentKcal);
  final newTarget = roundKcal(currentTarget + step);
  if (newTarget == currentTarget) return const Recommendation(RecommendationKind.onTrack);
  return Recommendation(
    newTarget < currentTarget ? RecommendationKind.lower : RecommendationKind.raise,
    newTarget: newTarget,
    belowBmr: newTarget < bmr,
  );
}

/// Messungen einer Waage (Zeitpunkt in Ortszeit, kg) → höchstens eine Wiegung pro Tag: die erste des Tages
/// (morgens, nüchtern). Tage, an denen schon eine Wiegung gespeichert ist, bleiben unberührt.
List<WeightPoint> weightsToImport(Iterable<(DateTime, double)> readings, Set<DateTime> existingDays) {
  final firstOfDay = <DateTime, (DateTime, double)>{};
  for (final r in readings) {
    final day = dayOf(r.$1);
    if (existingDays.contains(day)) continue;
    final current = firstOfDay[day];
    if (current == null || r.$1.isBefore(current.$1)) firstOfDay[day] = r;
  }
  final result = [for (final e in firstOfDay.entries) WeightPoint(e.key, e.value.$2)];
  return result..sort((a, b) => a.day.compareTo(b.day));
}
