/// Kalendertag ohne Uhrzeit, als UTC-Mitternacht (keine Probleme mit Sommerzeit).
DateTime dayOf(DateTime t) => DateTime.utc(t.year, t.month, t.day);

DateTime today() => dayOf(DateTime.now());

int daysBetween(DateTime from, DateTime to) => dayOf(to).difference(dayOf(from)).inDays;

/// Schlüssel für die Datenbank: „2026-10-14“.
String dayKey(DateTime day) =>
    '${day.year.toString().padLeft(4, '0')}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';

DateTime parseDayKey(String key) {
  final p = key.split('-').map(int.parse).toList();
  return DateTime.utc(p[0], p[1], p[2]);
}
