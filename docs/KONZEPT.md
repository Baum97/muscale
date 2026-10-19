# MuScale – Konzept

Kostenloser Kalorien- und Makrozähler für Kraftsportler, der den **tatsächlichen**
Kalorienbedarf aus Essen und Gewichtsverlauf misst. Kein Abo, kein Konto, keine Werbung,
kein Tracking. Open Source. Finanziert nur über Spenden.

Stand: Konzeptphase · Plattform: Android zuerst

---

## 1. Grundsätze

| Grundsatz | Bedeutung |
|---|---|
| Kostenlos | Alle Funktionen frei. Keine Paywall, kein Abo, kein „Premium“. |
| Ohne Konto | Alle Daten bleiben auf dem Gerät. Kein Login, kein eigener Server. |
| Ohne Google | Kein Google-Code in der App (kein ML Kit, kein Firebase, keine Play Services). |
| Ohne Tracking | Keine Analyse- oder Werbe-SDKs. |
| Ehrlich | Berechnete Werte werden als berechnet („≈“) gekennzeichnet. |
| Open Source | Quellcode öffentlich (GPL-3.0); wer MuScale geschlossen kommerziell nutzen will, braucht eine kostenpflichtige Lizenz (Kapitel 11). |

## 2. Zielgruppe

**Kraftsportler** – Aufbau, Diät, Erhalt; Fokus auf Eiweiß und Makros.
Zusätzlich allgemeine Infos für alle: Zucker vs. Stärke, Ballaststoffe, Fettqualität.

## 3. Nährwerte

Pro Lebensmittel und als Tagessumme:

| Gruppe | Werte |
|---|---|
| Energie | kcal |
| Eiweiß | g |
| Kohlenhydrate | gesamt · kurzkettig (Zucker) · langkettig (Stärke) · Ballaststoffe |
| Fett | gesamt · gesättigt · ungesättigt (wenn vorhanden: einfach / mehrfach ungesättigt) |
| Sonstiges | Salz |

### Was auf EU-Etiketten Pflicht ist – und was berechnet wird

Pflicht: Energie, Fett, davon gesättigte Fettsäuren, Kohlenhydrate, davon Zucker, Eiweiß, Salz.

| Wert | Herkunft | Kennzeichnung |
|---|---|---|
| Zucker (kurzkettig) | Etikett „davon Zucker“ | exakt |
| Stärke (langkettig) | Kohlenhydrate − Zucker | ≈ (kann Polyole enthalten) |
| Ballaststoffe | freiwillige Angabe | fehlt oft → „k. A.“ |
| Gesättigte Fette | Etikett | exakt |
| Ungesättigte Fette | Fett − gesättigte | ≈ (Rest inkl. Spuren Trans-Fett) |
| Einfach / mehrfach ungesättigt | freiwillige Angabe bzw. Lebensmitteldatenbank | nur wenn vorhanden |

## 4. Datenquellen

| Quelle | Wofür | Lizenz / Hinweis |
|---|---|---|
| Open Food Facts | Barcode-Produkte | ODbL; App fragt die API direkt ab (eigener User-Agent) |
| USDA FoodData Central | Grundnahrungsmittel mit Stärke & Fettsäuren | gemeinfrei |
| BLS 4.0 (Bundeslebensmittelschlüssel, Max Rubner-Institut) | deutsche Grundnahrungsmittel: ~7.100 Lebensmittel, 138 Nährstoffe inkl. Stärke und Fettsäuren | seit 16.12.2025 kostenfrei, CC BY 4.0 (Quellenangabe in der App) |
| Eigene Einträge | unbekannte Produkte, Rezepte | lokal; optional an Open Food Facts melden |

Gescannte und gesuchte Produkte werden lokal zwischengespeichert → zweiter Zugriff offline.

## 5. Scannen

- Barcodes: EAN-13, EAN-8, UPC-A, UPC-E.
- Bibliothek: `flutter_zxing` (zxing-cpp). **Nicht** `mobile_scanner` – nutzt auf Android Google ML Kit.
- Unbekanntes Produkt → Eingabeformular, aufgebaut wie die Nährwerttabelle (pro 100 g / 100 ml).
  Danach optional Upload zu Open Food Facts.
- Texterkennung der Nährwerttabelle: vorerst nicht (ohne Google nur Tesseract, zu schwach für Tabellen).

### Mengenauswahl nach dem Scan

| Feste Lebensmittel | Getränke |
|---|---|
| 1 Portion (nur wenn Portionsgröße bekannt) | 200 ml (Glas) |
| 50 g | 250 ml (Tasse/Glas) |
| 100 g | 330 ml (Dose) |
| 150 g | 500 ml (Flasche) |
| eigene Menge | eigene Menge |

Getränk wird erkannt an: Nährwerte pro 100 ml oder Packungsgröße in ml/l. Manuell umstellbar.
Zuletzt verwendete Menge pro Produkt wird vorausgewählt.

## 6. Profil und Startschätzung

Eingaben beim ersten Start:

- Größe (cm), Alter (Jahre), Geschlecht, aktuelles Gewicht (kg)
- Aktivitätslevel (Alltag + Training)
- Ziel: **Aufbau**, **Erhalt** oder **Diät** – mit Tempo

### Grundumsatz (Mifflin-St Jeor)

```
Männer:  10 × Gewicht + 6,25 × Größe − 5 × Alter + 5
Frauen:  10 × Gewicht + 6,25 × Größe − 5 × Alter − 161
Divers:  Mittelwert beider Formeln (Nutzer kann eine Formel wählen)
```

Gesamtbedarf = Grundumsatz × Aktivitätsfaktor:

| Level | Faktor |
|---|---|
| Sitzend, wenig Training | 1,2 |
| 1–3 Trainings/Woche | 1,375 |
| 3–5 Trainings/Woche | 1,55 |
| 6–7 Trainings/Woche | 1,725 |
| Täglich hart + körperliche Arbeit | 1,9 |

Diese Schätzung ist nur der Startwert. Nach 14 Tagen ersetzt der **gemessene** Bedarf sie (Kapitel 7).

### Zieltempo

| Ziel | Vorgeschlagenes Tempo | Grenze |
|---|---|---|
| Diät | −0,5 % Körpergewicht / Woche | max. −1 % / Woche |
| Erhalt | ±0 | – |
| Aufbau | +0,25 % Körpergewicht / Woche | max. +0,5 % / Woche |

Kalorienziel = Bedarf + (Tempo in kg/Woche × 7700 / 7).

### Makro-Ziele (Kraftsport-Standard, anpassbar)

| Makro | Standard |
|---|---|
| Eiweiß | 2,0 g/kg Körpergewicht (Bereich 1,6–2,2) |
| Fett | 0,8 g/kg, mindestens 20 % der Kalorien |
| Kohlenhydrate | Rest |
| Ballaststoffe | ≥ 30 g (Info, kein hartes Ziel) |
| Gesättigte Fette | < 10 % der Kalorien (Info) |
| Zucker | Info-Anzeige, kein Ziel |

## 7. Gewichtsmanagement – gemessener Bedarf

Kernfunktion. Die App lernt aus Essen und Gewichtsverlauf, wie viel der Nutzer wirklich verbraucht.

### Ablauf

1. Nutzer trackt Essen und hakt jeden vollständigen Tag abends als **„vollständig“** ab.
2. Nutzer wiegt sich – **täglich empfohlen**, jeden 2. Tag reicht.
3. Einmal pro Woche wertet die App die letzten 14 Tage aus.

### Gültiger Zeitraum

Ein 14-Tage-Zeitraum zählt nur, wenn

- **mindestens 7 Tage** als vollständig abgehakt sind (mindestens jeder 2. Tag), und
- **mindestens 7 Wiegungen** vorliegen (mindestens jeder 2. Tag).

Tage ohne Eintrag oder nicht abgehakt → zählen mit dem Durchschnitt der vollständigen Tage.
Ist der Zeitraum ungültig, zeigt die App, was fehlt („noch 2 vollständige Tage, 1 Wiegung“).

### Rechnung

1. **Anzeige – Gewichtstrend** statt Rohwerte: exponentiell geglätteter Durchschnitt (Glättung 10 %/Tag;
   Lücken zählen wie Tage mit gleichem Gewicht). Wasser, Salz, Kohlenhydrate und Zyklus lassen die Waage
   täglich um 1–2 kg schwanken.
2. **Auswertung – Ausgleichsgerade** durch alle Wiegungen der 14 Tage. Anders als der geglättete Trend hinkt
   sie nicht hinterher (wichtig in den ersten 14 Tagen), einzelne Ausreißer wiegen trotzdem wenig.
3. **Bedarf = Ø kcal − tägliche Gewichtsänderung (Steigung) × 7700**

Beispiel: Ø 2600 kcal, Gewicht sinkt gleichmäßig um 0,6 kg in 14 Tagen
→ 0,6 × 7700 / 14 = 330 kcal Defizit/Tag → gemessener Bedarf ≈ **2930 kcal**.

### Reaktion der App

| Ergebnis | Reaktion |
|---|---|
| Ist-Tempo ≈ Ziel (± Toleranz) | Bestärken: „Läuft – du nimmst 0,3 kg/Woche ab. Weiter so.“ Ziel bleibt. |
| Langsamer als gewünscht | Vorschlag: „Für 0,5 kg/Woche: 2400 statt 2600 kcal?“ (ideal wären 2380, max. −200 pro Schritt) |
| Schneller als gewünscht / falsche Richtung | Vorschlag in die Gegenrichtung |
| Zeitraum ungültig | Keine Anpassung, Hinweis was fehlt |

### Leitplanken

- Ziel wird **nie automatisch** geändert – Nutzer bestätigt immer.
- Max. ±200 kcal pro Anpassung.
- Tempo-Grenzen aus Kapitel 6.
- Untere Kaloriengrenze: Grundumsatz. Darunter nur mit Warnhinweis.
- Erste Woche einer Diät (oder nach Kohlenhydrat-Umstellung) wird markiert:
  schneller Verlust ist großteils Wasser/Glykogen.
- Optionaler „Nur Makros“-Modus blendet Kalorienzahlen aus (Schutz bei Essstörungs-Neigung).

## 8. Smarte Waagen

Ziel: Gewicht automatisch übernehmen, ohne eigenen Server und ohne Google-Pflicht.

| Weg | Wie | Vorteil | Nachteil |
|---|---|---|---|
| **Health Connect** | Android-Gesundheitsschnittstelle; Withings, Garmin, Fitbit, Renpho, Zepp u. a. schreiben dort Gewicht hinein | deckt die meisten Waagen ab, ein Weg für alle | auf älteren Android-Versionen eigene App nötig; F-Droid-Tauglichkeit prüfen |
| **openScale** | Freie App (F-Droid), liest viele Bluetooth-Waagen direkt; Daten-Schnittstelle für andere Apps | komplett ohne Google | Nutzer braucht openScale zusätzlich |
| Herstellerkonten (Withings-API etc.) | OAuth über Cloud | – | braucht Server/Geheimschlüssel → **nicht geplant** |
| Bluetooth direkt | eigene Waagen-Protokolle | keine Zusatz-App | hoher Aufwand pro Waagenmodell → **nicht geplant** |

Umgesetzt: Health Connect (nur `READ_WEIGHT`). Pro Tag zählt die erste Messung; Tage mit vorhandener Wiegung
bleiben unberührt. Abgleich beim Start, beim Zurückkehren in die App und per Knopf. openScale folgt.
Import nur lesend (Gewicht, optional später Körperfett).
Manuelle Eingabe und CSV-Import bleiben immer möglich.

## 9. Funktionen

### Version 1.0

Stand: ✅ umgesetzt · ⬜ offen

- ✅ Onboarding mit Profil, Ziel, Startschätzung
- ✅ Tagebuch nach Mahlzeiten: Frühstück, Mittag, Abend, Snacks
- ✅ Scanner, Suche nach Namen (gespeichert + Open Food Facts), Zuletzt gegessen
- ✅ Eigene Lebensmittel und Rezepte (mehrere Zutaten, Portionen, Gewicht nach dem Kochen)
- ✅ Tagesansicht: Kalorien-Ring, Balken für Eiweiß / Kohlenhydrate / Fett, aufklappbar
  (Zucker/Stärke/Ballaststoffe, gesättigt/ungesättigt)
- ✅ „Tag vollständig“ abhaken
- ✅ Gewicht eintragen, Trend-Grafik (30 / 90 Tage / alles)
- ✅ Check-in mit gemessenem Bedarf (Kapitel 7)
- ✅ Export/Import (JSON) als Datensicherung
- ✅ Waage über Health Connect (Kapitel 8)
- ✅ Farbwahl (Haupt- + Akzentfarbe) und neues Design
- ✅ Homescreen-Widget mit Kalorien/Eiweiß und Scan-Knopf
- ⬜ Grundnahrungsmittel aus dem BLS 4.0 (Datei muss noch ins Repo, siehe Kapitel 13)
- ✅ Favoriten
- ✅ CSV-Export (Tagebuch, Gewicht; Excel-tauglich)
- ✅ Lokale Erinnerungen (Wiegen, Tag abschließen) – ohne Firebase
- ⬜ Spenden: Link (F-Droid) steht vorbereitet, Trinkgeld über Play Billing fehlt
- ✅ Info-Seiten („Wissen“): Eiweiß im Kraftsport, Zucker vs. Stärke, Fettqualität, Bedarfsmessung, Wiegen

### Später

- openScale (Kapitel 8)
- Trainingstage vs. Ruhetage mit unterschiedlichen Zielen
- Wasser
- Mikronährstoffe, sofern Daten vorhanden
- iOS
- Geräte-Synchronisation (nur optional, dann mit Konto)

## 10. Technik

| Bereich | Wahl |
|---|---|
| App | Flutter (Dart), Android zuerst |
| Lokale Datenbank | SQLite über `drift` |
| Barcode | `flutter_zxing` |
| Netzwerk | nur Open Food Facts API; BLS-Daten als Paket in der App |
| Waage | Health Connect über das Paket `health` (nur lesend) |
| Dateien | `file_picker` (Speichern/Öffnen über den Android-Dateidialog) |
| Zustand | Riverpod |
| Benachrichtigungen | lokal (`flutter_local_notifications`), kein FCM |
| Backend | keins |
| Vertrieb | Google Play (Dev-Account vorhanden) + F-Droid, zwei Build-Varianten (Kapitel 11) |
| Design | Hell/Dunkel/System; Hauptfarbe (Waldgrün = Standard passend zum Logo, Dunkelrot, Oliv, Schwarz, Blau, Weiß) + je 4 passende Akzentfarben; Schrift Manrope (OFL, eingebettet) |
| Homescreen-Widget | `home_widget`: kcal übrig, kcal und Eiweiß gegessen/Ziel, Scan-Knopf (öffnet direkt den Scanner) |
| Lizenz | GPL-3.0 + kommerzielle Lizenz (Dual Licensing, Kapitel 11) |

## 11. Finanzierung

- **Jetzt:** nur Spenden.
- **Laufende Kosten:** nahe null (kein Server).

### Spenden je Vertriebsweg

Spenden gibt es **nur in der App**. Google Play erlaubt externe Spendenlinks nur für steuerbefreite
Organisationen (Sperren: WireGuard 2019, StreetComplete 2022, AnkiDroid 2026). Seit 30.06.2026 sind
externe Links in EU/UK/USA zwar erlaubt, Google verlangt aber auch dafür Gebühren (laut Gebührentabelle ~20 %)
und Meldepflichten. Deshalb zwei Build-Varianten aus demselben Code:

| Variante | Spenden in der App | Google-Anteil |
|---|---|---|
| F-Droid / GitHub | Link zu GitHub Sponsors / Ko-fi in den Einstellungen | keiner |
| Google Play | Trinkgeld über Google Play Billing (feste Beträge, z. B. 2 € / 5 € / 10 €) | ca. 10–15 % |

Die F-Droid-Variante darf keinen Play-Billing-Code enthalten. Flutter-Pakete lassen sich aber nicht je
Gradle-Flavor ein- und ausschalten – das Paket `in_app_purchase` landet sonst in beiden Varianten.
Geplante Umsetzung: Trinkgeld als eigenes Dart-Paket (`packages/tip_jar_play`), das nur die Play-Variante
einbindet (eigene `pubspec`-Überschreibung im Play-Build). F-Droid baut ohne dieses Paket.
Aktuelle Gebühren vor dem Release in der Play Console prüfen.

**Später:** Wird MuScale groß, kann ein gemeinnütziger Verein Empfänger der Spenden werden.
Dann ist auch in der Play-Variante ein externer Spendenlink ohne Google-Anteil erlaubt.

### Lizenz: GPL-3.0 + kommerzielle Lizenz (Dual Licensing)

Ziel: Wer mit MuScale Geld verdient, zahlt Lizenzgebühren an den Urheber.

Wichtig: Eine reine Open-Source-Lizenz (auch GPL) **darf keine Lizenzgebühren verlangen** –
das widerspräche der Open-Source-Definition, und F-Droid nimmt nur echte Open-Source-Apps auf.
Deshalb zwei Lizenzen nebeneinander:

| Wer | Lizenz | Bedingung |
|---|---|---|
| Alle (Nutzer, F-Droid, Hobby-Forks) | GPL-3.0 | Jeder Ableger muss ebenfalls unter GPL-3.0 mit vollständigem Quellcode veröffentlicht werden. |
| Firmen, die MuScale in ein geschlossenes / eigenes kommerzielles Produkt einbauen wollen | kommerzielle Lizenz vom Urheber | Lizenzgebühr bzw. Umsatzbeteiligung, frei verhandelbar |

Wirkung: Wer kopiert und Geld verdienen will, muss entweder seinen gesamten Code offenlegen
(macht ein Bezahlprodukt unattraktiv) oder eine kommerzielle Lizenz kaufen.

Voraussetzung: Der Urheber muss alle Rechte am Code halten. Fremde Beiträge (Pull Requests) nur mit
**Contributor License Agreement (CLA)**, das die Rechte für die kommerzielle Lizenz einräumt.

Grenzen: Eine Umsatzbeteiligung lässt sich bei GPL-Ablegern rechtlich nicht erzwingen – wer seinen Code
offenlegt, darf ihn auch verkaufen. Die Vorlage der kommerziellen Lizenz sollte ein Anwalt prüfen.
Die Daten von Open Food Facts (ODbL) gehören nicht dazu; die darf jeder auch kommerziell nutzen.
### Werbung – vorerst nicht umgesetzt, Regeln für später

Falls Werbung jemals kommt, gilt ohne Ausnahme:

- **Nicht disruptiv:** kein Vollbild, kein Video, kein Pop-up, keine Werbung zwischen Aktionen.
  Höchstens ein kleiner statischer Banner.
- **Nicht auf Gesundheitsbildschirmen:** nie im Tagebuch, beim Gewicht oder im Check-in.
- **Kein Tracking:** keine personalisierte Werbung, kein Werbe-SDK mit Profilbildung.
  Ernährungs- und Gewichtsdaten sind Gesundheitsdaten (Art. 9 DSGVO).
- Bevorzugt: selbst verkaufter Sponsor-Platz (statisches Bild + Link), passend zum Thema.
- Abschaltbar für Spender wäre denkbar – aber ohne Funktionen hinter einer Paywall.

## 12. Datenschutz

- Alle Daten lokal auf dem Gerät, kein Konto.
- Netzwerk nur für Produktsuche (Barcode/Suchbegriff an Open Food Facts).
- Kein Analyse-SDK, keine Absturzberichte ohne ausdrückliche Zustimmung.
- Datensicherung liegt in der Hand des Nutzers (Export).

## 13. Offene Punkte

- [x] BLS 4.0: CC BY 4.0 – Nutzung in der App erlaubt, Quellenangabe „Max Rubner-Institut (2025): Bundeslebensmittelschlüssel (BLS), Version 4.0“
- [ ] BLS-Datei (`BLS_4_0_Daten_2025_DE.xlsx`) ins Repo unter `data/bls/` legen → Import in die App
- [x] Datenschutzerklärung (Entwurf): `app/assets/legal/datenschutz.md` – in der App unter Einstellungen → Datenschutz
- [x] Impressum (Entwurf): `app/assets/legal/impressum.md`, Anleitung in `docs/IMPRESSUM.md`
- [ ] Datenschutzerklärung und Impressum: Name, Anschrift, E-Mail, Telefon, Aufsichtsbehörde eintragen; rechtlich prüfen lassen
- [ ] Google Play: Health-Connect-Berechtigung in der Play Console deklarieren, Datenschutz-URL hinterlegen
- [ ] Health Connect: F-Droid-Tauglichkeit des Client-Pakets prüfen
- [ ] openScale-Schnittstelle prüfen
- [ ] Play-Variante: Trinkgeld-Produkte anlegen, aktuelle Gebühren prüfen
- [ ] Text der kommerziellen Lizenz + CLA (anwaltlich prüfen lassen)
- [x] Farben (Light + Dark Mode, wählbar)
- [x] App-Icon: „Ring-M“ in Waldgrün/Gold (`docs/branding/`)
