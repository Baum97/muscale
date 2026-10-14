import 'package:health/health.dart';

import '../domain/days.dart';
import '../domain/trend.dart';
import 'database.dart';

enum ScaleStatus { available, notInstalled, updateRequired }

/// Liest Gewichtsmessungen smarter Waagen aus Health Connect (Withings, Garmin, Renpho, Zepp, …). Nur lesend.
class HealthConnectScale {
  final _health = Health();
  bool _configured = false;

  static const _types = [HealthDataType.WEIGHT];

  Future<void> _configure() async {
    if (_configured) return;
    await _health.configure();
    _configured = true;
  }

  Future<ScaleStatus> status() async {
    await _configure();
    return switch (await _health.getHealthConnectSdkStatus()) {
      HealthConnectSdkStatus.sdkAvailable => ScaleStatus.available,
      HealthConnectSdkStatus.sdkUnavailableProviderUpdateRequired => ScaleStatus.updateRequired,
      _ => ScaleStatus.notInstalled,
    };
  }

  /// Öffnet die Store-Seite von Health Connect.
  Future<void> install() async {
    await _configure();
    await _health.installHealthConnect();
  }

  /// Fragt die Leseberechtigung an. True, wenn erteilt.
  Future<bool> connect() async {
    await _configure();
    if (await _health.hasPermissions(_types, permissions: [HealthDataAccess.READ]) == true) return true;
    return _health.requestAuthorization(_types, permissions: [HealthDataAccess.READ]);
  }

  /// Übernimmt Messungen der letzten [days] Tage (Health Connect erlaubt standardmäßig 30) in die Datenbank.
  /// Liefert die Anzahl neu übernommener Tage.
  Future<int> importInto(AppDatabase db, {int days = 30}) async {
    await _configure();
    final now = DateTime.now();
    final points = await _health.getHealthDataFromTypes(
      types: _types,
      startTime: now.subtract(Duration(days: days)),
      endTime: now,
    );
    final readings = [
      for (final p in points)
        if (p.value case NumericHealthValue(:final numericValue)) (p.dateFrom.toLocal(), numericValue.toDouble()),
    ];
    final existing = {for (final w in await db.select(db.weightEntries).get()) parseDayKey(w.day)};
    final toImport = weightsToImport(readings, existing).where((w) => w.kg >= 30 && w.kg <= 300).toList();
    for (final w in toImport) {
      await db.saveWeight(dayKey(w.day), double.parse(w.kg.toStringAsFixed(1)));
    }
    return toImport.length;
  }
}
