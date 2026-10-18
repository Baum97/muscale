import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';

import '../domain/days.dart';
import '../domain/nutrients.dart';
import '../domain/targets.dart';
import '../theme.dart';

/// Was das Homescreen-Widget anzeigt.
@immutable
class WidgetSnapshot {
  const WidgetSnapshot({
    required this.day,
    required this.kcalEaten,
    required this.kcalTarget,
    required this.proteinEaten,
    required this.proteinTarget,
    required this.primaryLight,
    required this.primaryDark,
  });

  final String day;
  final int kcalEaten;
  final int kcalTarget;
  final int proteinEaten;
  final int proteinTarget;

  /// ARGB als vorzeichenbehaftete 32-Bit-Zahl – so passt sie in Androids `getInt`.
  final int primaryLight;
  final int primaryDark;

  Map<String, int> get values => {
    'kcal_eaten': kcalEaten,
    'kcal_target': kcalTarget,
    'protein_eaten': proteinEaten,
    'protein_target': proteinTarget,
    'primary_light': primaryLight,
    'primary_dark': primaryDark,
  };

  @override
  bool operator ==(Object other) =>
      other is WidgetSnapshot && other.day == day && other.values.toString() == values.toString();

  @override
  int get hashCode => Object.hash(day, values.toString());
}

WidgetSnapshot widgetSnapshot({
  required DateTime day,
  required NutrientTotals totals,
  required Targets targets,
  required AppPalette palette,
}) {
  int argb(Brightness b) => buildColorScheme(b, palette).primary.toARGB32().toSigned(32);
  return WidgetSnapshot(
    day: dayKey(day),
    kcalEaten: totals.kcal.round(),
    kcalTarget: targets.calorieTarget,
    proteinEaten: totals.protein.round(),
    proteinTarget: targets.macros.protein.round(),
    primaryLight: argb(Brightness.light),
    primaryDark: argb(Brightness.dark),
  );
}

/// Verbindung zum Android-Widget. Als Schnittstelle, damit Tests ohne Plattform auskommen.
abstract class HomeWidgetBridge {
  Future<void> publish(WidgetSnapshot snapshot);

  /// Link, mit dem die App vom Widget aus gestartet wurde (z. B. muscale://scan), sonst null.
  Future<Uri?> initialLaunch();

  /// Antippen des Widgets, während die App schon läuft.
  Stream<Uri?> get clicks;
}

class AndroidHomeWidget implements HomeWidgetBridge {
  static const _provider = 'app.muscale.muscale.TodayWidgetProvider';

  @override
  Future<void> publish(WidgetSnapshot snapshot) async {
    await HomeWidget.saveWidgetData<String>('day', snapshot.day);
    for (final e in snapshot.values.entries) {
      await HomeWidget.saveWidgetData<int>(e.key, e.value);
    }
    await HomeWidget.updateWidget(qualifiedAndroidName: _provider);
  }

  @override
  Future<Uri?> initialLaunch() => HomeWidget.initiallyLaunchedFromHomeWidget();

  @override
  Stream<Uri?> get clicks => HomeWidget.widgetClicked;
}

/// Link vom Widget: soll der Scanner geöffnet werden?
bool isScanLink(Uri? uri) => uri?.scheme == 'muscale' && uri?.host == 'scan';
