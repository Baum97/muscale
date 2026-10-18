import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/database.dart';
import 'data/open_food_facts.dart';
import 'data/scale_sync.dart';
import 'domain/nutrients.dart';
import 'services/home_widget_sync.dart';
import 'services/reminders.dart';
import 'theme.dart';
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

  void showToday() => state = today();
}

final dayEntriesProvider = StreamProvider.family<List<EntryWithFood>, String>(
  (ref, day) => ref.watch(databaseProvider).watchDay(day),
);

final dayCompleteProvider = StreamProvider.family<bool, String>(
  (ref, day) => ref.watch(databaseProvider).watchDayComplete(day),
);

final recentFoodsProvider = StreamProvider<List<Food>>((ref) => ref.watch(databaseProvider).watchRecentFoods());

final favoritesProvider = StreamProvider<List<Food>>((ref) => ref.watch(databaseProvider).watchFavorites());

final isFavoriteProvider = StreamProvider.family<bool, int>(
  (ref, foodId) => ref.watch(databaseProvider).watchIsFavorite(foodId),
);

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

/// Gewählte Haupt- und Akzentfarbe.
final paletteProvider = NotifierProvider<PaletteSetting, AppPalette>(PaletteSetting.new);

class PaletteSetting extends Notifier<AppPalette> {
  static const _primaryKey = 'palette_primary';
  static const _accentKey = 'palette_accent';

  @override
  AppPalette build() {
    _load();
    return AppPalette.standard;
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final primary = PrimaryChoice.values.where((p) => p.name == prefs.getString(_primaryKey)).firstOrNull;
      if (primary == null) return;
      final accent = AccentChoice.values.where((a) => a.name == prefs.getString(_accentKey)).firstOrNull;
      state = AppPalette(primary, accent ?? primary.accents.first);
    } catch (_) {
      // Ohne gespeicherte Auswahl bleibt es beim Standard.
    }
  }

  /// Neue Hauptfarbe: Akzent bleibt, wenn er dazu passt, sonst der passende Standard.
  Future<void> setPrimary(PrimaryChoice primary) =>
      _save(AppPalette(primary, primary.accents.contains(state.accent) ? state.accent : primary.accents.first));

  Future<void> setAccent(AccentChoice accent) => _save(AppPalette(state.primary, accent));

  Future<void> _save(AppPalette palette) async {
    state = palette;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_primaryKey, palette.primary.name);
    await prefs.setString(_accentKey, palette.accent.name);
  }
}

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

// Waage

final scaleProvider = Provider<HealthConnectScale>((ref) => HealthConnectScale());

/// Gewicht automatisch aus Health Connect übernehmen.
final scaleEnabledProvider = NotifierProvider<ScaleEnabledSetting, bool>(ScaleEnabledSetting.new);

class ScaleEnabledSetting extends Notifier<bool> {
  static const _key = 'scale_health_connect';

  @override
  bool build() {
    _load();
    return false;
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      state = prefs.getBool(_key) ?? false;
    } catch (_) {
      // Ohne gespeicherte Einstellung bleibt die Waage aus.
    }
  }

  Future<void> set(bool enabled) async {
    state = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, enabled);
  }
}

// Erinnerungen

final reminderSchedulerProvider = Provider<ReminderScheduler>((ref) => LocalReminderScheduler());

class ReminderSetting {
  const ReminderSetting({required this.enabled, required this.time});
  final bool enabled;
  final TimeOfDay time;
}

/// Tägliche Erinnerungen; gespeichert in den Einstellungen und beim Start neu eingeplant.
final remindersProvider = NotifierProvider<RemindersSetting, Map<ReminderKind, ReminderSetting>>(RemindersSetting.new);

class RemindersSetting extends Notifier<Map<ReminderKind, ReminderSetting>> {
  @override
  Map<ReminderKind, ReminderSetting> build() {
    _load();
    return {for (final k in ReminderKind.values) k: ReminderSetting(enabled: false, time: k.defaultTime)};
  }

  static String _enabledKey(ReminderKind k) => 'reminder_${k.name}_enabled';
  static String _minutesKey(ReminderKind k) => 'reminder_${k.name}_minutes';

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final loaded = {
        for (final k in ReminderKind.values)
          k: ReminderSetting(
            enabled: prefs.getBool(_enabledKey(k)) ?? false,
            time: _fromMinutes(prefs.getInt(_minutesKey(k))) ?? k.defaultTime,
          ),
      };
      state = loaded;
      // Neu einplanen, falls das System die Erinnerungen verworfen hat (z. B. nach einem Update).
      for (final e in loaded.entries) {
        if (e.value.enabled) await ref.read(reminderSchedulerProvider).scheduleDaily(e.key, e.value.time);
      }
    } catch (_) {
      // Ohne gespeicherte Einstellungen bleiben die Erinnerungen aus.
    }
  }

  static TimeOfDay? _fromMinutes(int? m) => m == null ? null : TimeOfDay(hour: m ~/ 60, minute: m % 60);

  /// Schaltet eine Erinnerung ein/aus oder ändert die Uhrzeit. False, wenn die Berechtigung fehlt.
  Future<bool> set(ReminderKind kind, {bool? enabled, TimeOfDay? time}) async {
    final scheduler = ref.read(reminderSchedulerProvider);
    final current = state[kind]!;
    final next = ReminderSetting(enabled: enabled ?? current.enabled, time: time ?? current.time);
    if (next.enabled && !current.enabled && !await scheduler.requestPermission()) return false;

    state = {...state, kind: next};
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey(kind), next.enabled);
    await prefs.setInt(_minutesKey(kind), next.time.hour * 60 + next.time.minute);
    if (next.enabled) {
      await scheduler.scheduleDaily(kind, next.time);
    } else {
      await scheduler.cancel(kind);
    }
    return true;
  }
}

// Homescreen-Widget

final homeWidgetProvider = Provider<HomeWidgetBridge>((ref) => AndroidHomeWidget());

/// Stand fürs Widget: immer der heutige Tag, unabhängig vom angezeigten Tag im Tagebuch.
final widgetSnapshotProvider = Provider<WidgetSnapshot?>((ref) {
  final day = today();
  final entries = ref.watch(dayEntriesProvider(dayKey(day))).value;
  final targets = ref.watch(targetsProvider);
  if (entries == null || targets == null) return null;
  return widgetSnapshot(
    day: day,
    totals: NutrientTotals.of(entries.map((e) => e.nutrients)),
    targets: targets,
    palette: ref.watch(paletteProvider),
  );
});
