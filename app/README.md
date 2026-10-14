# MuScale – App

Flutter, Android zuerst. Alle Daten liegen lokal in SQLite (drift); ins Netz geht nur der Barcode an Open Food Facts.

## Starten

```bash
flutter pub get
flutter run --flavor fdroid      # oder: --flavor play
```

| Flavor | Spenden in der App |
|---|---|
| `fdroid` | Link zur Spendenseite (`donationUrl` in `lib/config.dart`, noch leer) |
| `play` | Trinkgeld über Google Play Billing (folgt) |

## Prüfen (wie in der CI)

```bash
dart run build_runner build --delete-conflicting-outputs   # nach Änderungen an lib/data/database.dart
dart format $(find lib test -name '*.dart' ! -name '*.g.dart')
flutter analyze
flutter test
```

## Aufbau

```
lib/domain/        Reine Rechenlogik, ohne Flutter – vollständig getestet
  energy.dart        Grundumsatz (Mifflin-St Jeor), Aktivität, Ziele, Tempo
  macros.dart        Makro-Ziele (Eiweiß pro kg, Fett-Minimum, Rest Kohlenhydrate)
  nutrients.dart     Nährwerte, abgeleitete Werte (Stärke, ungesättigte Fette), Summen
  portions.dart      Mengen-Schnellauswahl (Portion/50/100/150 g, Getränkegrößen)
  trend.dart         Gewichtstrend, 14-Tage-Auswertung, Empfehlung fürs Kalorienziel
  targets.dart       Alle Tagesziele für Profil + Gewicht
lib/data/
  database.dart      drift-Tabellen und Abfragen (database.g.dart wird generiert)
  open_food_facts.dart  Produktsuche per Barcode
lib/features/      Bildschirme: Onboarding/Profil, Tagebuch, Scanner, Lebensmittel, Gewicht, Einstellungen
lib/providers.dart Riverpod-Provider
```
