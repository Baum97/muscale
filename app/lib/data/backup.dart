import 'dart:convert';

import 'package:drift/drift.dart' show TableInfo;

import 'database.dart';

const backupFormat = 'muscale-backup';
const backupVersion = 1;

class BackupException implements Exception {
  BackupException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Alle Daten als JSON – Profil, Lebensmittel, Tagebuch, abgehakte Tage, Gewicht.
Future<String> exportBackup(AppDatabase db, {DateTime? now}) async {
  final data = {
    'format': backupFormat,
    'version': backupVersion,
    'schemaVersion': db.schemaVersion,
    'exportedAt': (now ?? DateTime.now()).toUtc().toIso8601String(),
    'profiles': [for (final r in await db.select(db.profiles).get()) r.toJson()],
    'foods': [for (final r in await db.select(db.foods).get()) r.toJson()],
    'diaryEntries': [for (final r in await db.select(db.diaryEntries).get()) r.toJson()],
    'completedDays': [for (final r in await db.select(db.completedDays).get()) r.toJson()],
    'weightEntries': [for (final r in await db.select(db.weightEntries).get()) r.toJson()],
  };
  return const JsonEncoder.withIndent(' ').convert(data);
}

/// Ersetzt alle Daten durch die Sicherung. Bei einer ungültigen Datei bleibt alles unverändert.
Future<void> importBackup(AppDatabase db, String text) async {
  final Map<String, dynamic> data;
  try {
    data = jsonDecode(text) as Map<String, dynamic>;
  } catch (_) {
    throw BackupException('Die Datei ist keine MuScale-Sicherung.');
  }
  if (data['format'] != backupFormat) throw BackupException('Die Datei ist keine MuScale-Sicherung.');
  if ((data['version'] as num? ?? 0) > backupVersion) {
    throw BackupException(
      'Die Sicherung stammt aus einer neueren MuScale-Version. Bitte zuerst die App aktualisieren.',
    );
  }

  List<Map<String, dynamic>> rows(String key) => [
    for (final r in (data[key] as List? ?? const [])) r as Map<String, dynamic>,
  ];

  final List<Profile> profiles;
  final List<Food> foods;
  final List<DiaryEntry> entries;
  final List<CompletedDay> completed;
  final List<WeightEntry> weights;
  try {
    profiles = rows('profiles').map(Profile.fromJson).toList();
    foods = rows('foods').map(Food.fromJson).toList();
    entries = rows('diaryEntries').map(DiaryEntry.fromJson).toList();
    completed = rows('completedDays').map(CompletedDay.fromJson).toList();
    weights = rows('weightEntries').map(WeightEntry.fromJson).toList();
  } catch (_) {
    throw BackupException('Die Sicherung ist beschädigt.');
  }

  await db.transaction(() async {
    for (final TableInfo table in [db.diaryEntries, db.completedDays, db.weightEntries, db.foods, db.profiles]) {
      await db.delete(table).go();
    }
    await db.batch((b) {
      b.insertAll(db.profiles, profiles);
      b.insertAll(db.foods, foods);
      b.insertAll(db.diaryEntries, entries);
      b.insertAll(db.completedDays, completed);
      b.insertAll(db.weightEntries, weights);
    });
  });
}
