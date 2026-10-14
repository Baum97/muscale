import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/database.dart';
import 'data/open_food_facts.dart';
import 'domain/days.dart';
import 'domain/targets.dart';
import 'domain/trend.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final openFoodFactsProvider = Provider<OpenFoodFacts>((ref) => OpenFoodFacts());

final profileProvider = StreamProvider<Profile?>((ref) => ref.watch(databaseProvider).watchProfile());

final weightsProvider = StreamProvider<List<WeightEntry>>((ref) => ref.watch(databaseProvider).watchWeights());

final weightTrendProvider = Provider<List<TrendPoint>>((ref) {
  final weights = ref.watch(weightsProvider).value ?? const [];
  return weightTrend([for (final w in weights) WeightPoint(parseDayKey(w.day), w.kg)]);
});

/// Ziele aus Profil und aktuellem Trendgewicht; null, solange kein Profil oder Gewicht da ist.
final targetsProvider = Provider<Targets?>((ref) {
  final profile = ref.watch(profileProvider).value;
  final trend = ref.watch(weightTrendProvider);
  if (profile == null || trend.isEmpty) return null;
  return computeTargets(
    sex: profile.sex,
    birthYear: profile.birthYear,
    heightCm: profile.heightCm,
    activity: profile.activity,
    pacePercent: profile.pacePercent,
    proteinPerKg: profile.proteinPerKg,
    weightKg: trend.last.trendKg,
    currentYear: DateTime.now().year,
    calorieTargetOverride: profile.calorieTargetOverride,
  );
});

/// Der im Tagebuch angezeigte Tag.
final selectedDayProvider = NotifierProvider<SelectedDay, DateTime>(SelectedDay.new);

class SelectedDay extends Notifier<DateTime> {
  @override
  DateTime build() => today();

  void shift(int days) {
    final next = state.add(Duration(days: days));
    if (!next.isAfter(today())) state = next;
  }
}

final dayEntriesProvider = StreamProvider.family<List<EntryWithFood>, String>(
  (ref, day) => ref.watch(databaseProvider).watchDay(day),
);

final dayCompleteProvider = StreamProvider.family<bool, String>(
  (ref, day) => ref.watch(databaseProvider).watchDayComplete(day),
);

final recentFoodsProvider = StreamProvider<List<Food>>((ref) => ref.watch(databaseProvider).watchRecentFoods());

final recipesProvider = StreamProvider<List<Food>>((ref) => ref.watch(databaseProvider).watchRecipes());

final completedDaysProvider = StreamProvider<List<CompletedDay>>(
  (ref) => ref.watch(databaseProvider).watchCompletedDays(),
);

class CheckIn {
  const CheckIn(this.evaluation, this.recommendation);
  final EnergyEvaluation evaluation;
  final Recommendation recommendation;
}

/// Auswertung der letzten 14 Tage bis gestern (heute ist meist noch nicht fertig getrackt).
final checkInProvider = FutureProvider<CheckIn?>((ref) async {
  final db = ref.watch(databaseProvider);
  final profile = ref.watch(profileProvider).value;
  final targets = ref.watch(targetsProvider);
  final weights = ref.watch(weightsProvider).value ?? const [];
  final completed = ref.watch(completedDaysProvider).value ?? const [];
  if (profile == null || targets == null) return null;

  final end = today().subtract(const Duration(days: 1));
  final start = end.subtract(const Duration(days: evaluationWindowDays - 1));
  final entries = await db.entriesBetween(dayKey(start), dayKey(end));
  final kcalByDay = <String, double>{};
  for (final e in entries) {
    kcalByDay[e.entry.day] = (kcalByDay[e.entry.day] ?? 0) + (e.nutrients.kcal ?? 0);
  }
  final completeDays = {for (final c in completed) c.day};

  final evaluation = evaluateEnergy(
    end: end,
    intakes: [for (final day in completeDays) DayIntake(parseDayKey(day), kcalByDay[day] ?? 0, complete: true)],
    weights: [for (final w in weights) WeightPoint(parseDayKey(w.day), w.kg)],
  );
  final recommendation = recommend(
    evaluation: evaluation,
    currentTarget: targets.calorieTarget,
    desiredPaceKgPerWeek: targets.paceKgPerWeek,
    bmr: targets.bmr,
  );
  return CheckIn(evaluation, recommendation);
});

// Darstellung

final themeModeProvider = NotifierProvider<ThemeModeSetting, ThemeMode>(ThemeModeSetting.new);

class ThemeModeSetting extends Notifier<ThemeMode> {
  static const _key = 'theme_mode';

  @override
  ThemeMode build() {
    _load();
    return ThemeMode.system;
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final name = prefs.getString(_key);
      state = ThemeMode.values.firstWhere((m) => m.name == name, orElse: () => ThemeMode.system);
    } catch (_) {
      // Ohne gespeicherte Einstellung bleibt es bei „System“.
    }
  }

  Future<void> set(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, mode.name);
  }
}
