# Veröffentlichung – Google Play und F-Droid

Schritt für Schritt vom Repo zur App im Store. Was schon vorbereitet ist, ist mit ✅ markiert.

| Bereich | Stand |
|---|---|
| Signierung (Upload-Schlüssel, nie im Repo) | ✅ vorbereitet – Schlüssel musst du einmal erzeugen |
| Release-Build in GitHub Actions (AAB + APK) | ✅ `.github/workflows/release.yml` |
| Prüfung auf Google-Code in der F-Droid-Variante | ✅ in CI und Release (`scripts/check-fdroid-apk.sh`) |
| Store-Texte (Deutsch) | ✅ `fastlane/metadata/android/de-DE/` |
| Screenshots, Banner, Icon | ✅ `fastlane/metadata/android/de-DE/images/` |
| Datenschutzerklärung, Impressum | ✅ Entwurf – Platzhalter ausfüllen, prüfen lassen |
| Test auf echtem Gerät | ⬜ **vor allem anderen** |

---

## 0. Vorher: auf dem Handy testen

Lade die Test-APK aus dem letzten CI-Lauf ([Actions](https://github.com/Baum97/muscale/actions) → Lauf
öffnen → Artefakt `muscale-fdroid-debug-apk`), entpacke sie und installiere sie (Android fragt nach
„Installation aus unbekannten Quellen“).

Checkliste:
- [ ] Onboarding, Tagesziel plausibel
- [ ] Barcode scannen (bekanntes Produkt, unbekanntes Produkt → Eingabeformular, kein Netz)
- [ ] Suche nach Namen
- [ ] Mengen, Mahlzeiten, Löschen per Wischen, „Tag vollständig“
- [ ] Rezept anlegen und eintragen
- [ ] Gewicht eintragen, Diagramm, Check-in (nach 14 Tagen)
- [ ] Waage: Health Connect verbinden (falls du eine smarte Waage hast)
- [ ] Erinnerungen: Uhrzeit auf in 2 Minuten stellen, kommt die Benachrichtigung?
- [ ] Widget auf den Homescreen legen, Werte stimmen, Scan-Knopf öffnet den Scanner
- [ ] Export, Import, CSV in Excel öffnen
- [ ] Farben, Hell/Dunkel, Impressum, Datenschutz

Fehler bitte als [GitHub-Issue](https://github.com/Baum97/muscale/issues) oder direkt an mich.

---

## 1. Entscheidungen, die danach nicht mehr änderbar sind

- **App-Kennung:** `app.muscale.muscale` (in `app/android/app/build.gradle.kts`). Nach dem ersten Upload bei
  Google Play **für immer fest**. Wenn du eine eigene Domain hast, z. B. `de.deinname.muscale`, jetzt ändern.
- **Upload-Schlüssel:** Geht er verloren, kann Google ihn zurücksetzen (dauert einige Tage). Den eigentlichen
  App-Signaturschlüssel verwaltet Google (Play App Signing) – den kannst du nicht verlieren.

## 2. Upload-Schlüssel erzeugen (einmalig, auf deinem Rechner)

Voraussetzung: ein JDK (z. B. [Temurin 17](https://adoptium.net)).

```bash
scripts/create-upload-key.sh
```

Das Skript fragt nach einem Passwort und deinem Namen und legt an:
- `~/.muscale/muscale-upload.jks` – **sicher aufbewahren** (Passwort-Manager + Backup, z. B. USB-Stick)
- `app/android/key.properties` – damit lokale Release-Builds signiert werden (steht in `.gitignore`)

Danach auf GitHub: **Repo → Settings → Secrets and variables → Actions → New repository secret**, vier Secrets:

| Name | Wert |
|---|---|
| `MUSCALE_KEYSTORE_BASE64` | Inhalt von `~/.muscale/keystore.base64.txt` |
| `MUSCALE_KEYSTORE_PASSWORD` | dein Passwort |
| `MUSCALE_KEY_ALIAS` | `upload` |
| `MUSCALE_KEY_PASSWORD` | dein Passwort |

Dann `~/.muscale/keystore.base64.txt` löschen.

## 3. Release bauen

1. Version in `app/pubspec.yaml` erhöhen: `version: 1.0.0+1` → nächste Version z. B. `1.0.1+2`.
   **Die Zahl hinter `+` muss bei jedem Upload größer werden.**
2. Für jede Version eine Änderungsnotiz anlegen: `fastlane/metadata/android/de-DE/changelogs/<Zahl hinter +>.txt`
   (max. 500 Zeichen).
3. Commit, dann Tag setzen und pushen:
   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```
4. GitHub Actions → „Release“ läuft. Ergebnis (Artefakt `muscale-release`):
   - `muscale-1.0.0-play.aab` → für Google Play
   - `muscale-1.0.0-arm64-v8a.apk` (fast alle Handys), `…-armeabi-v7a.apk` (alte Handys), `…-x86_64.apk`
     (Emulatoren) → hängen zusätzlich am GitHub-Release (für Leute ohne Store)

Ohne die Secrets entstehen unsignierte Pakete – Google Play lehnt die ab.

---

## 4. Google Play Console

### 4.1 App anlegen
[play.google.com/console](https://play.google.com/console) → **App erstellen**
- Name: `MuScale – Kalorien & Makros`, Standardsprache: Deutsch
- App (nicht Spiel), kostenlos
- Erklärungen bestätigen

### 4.2 Store-Eintrag (Hauptseite des Store-Eintrags)
Alles liegt in `fastlane/metadata/android/de-DE/`:

| Feld | Datei |
|---|---|
| App-Name | `title.txt` |
| Kurzbeschreibung | `short_description.txt` |
| Vollständige Beschreibung | `full_description.txt` |
| App-Symbol (512 × 512) | `images/icon.png` |
| Vorstellungsgrafik (1024 × 500) | `images/featureGraphic.png` |
| Smartphone-Screenshots | `images/phoneScreenshots/1.png` … `6.png` |

Kategorie: **Gesundheit & Fitness**. Kontakt-E-Mail: dieselbe wie im Impressum.

### 4.3 App-Inhalte (Menü „Richtlinien → App-Inhalte“)

**Datenschutzerklärung:**
`https://github.com/Baum97/muscale/blob/main/app/assets/legal/datenschutz.md`

**Werbung:** Nein.

**App-Zugriff:** Alle Funktionen ohne Anmeldung verfügbar.

**Altersfreigabe (IARC-Fragebogen):** Kategorie „Alle anderen App-Typen“. Keine Gewalt, keine sexuellen
Inhalte, keine Glücksspiele, keine Nutzerinteraktion/Chats, keine Standortweitergabe, keine Käufe digitaler
Güter (solange es kein Trinkgeld gibt). Ergebnis voraussichtlich „USK ab 0 / PEGI 3“.

**Zielgruppe:** 16+ (nicht für Kinder). „Spricht die App Kinder an?“ – Nein.

**Nachrichten-App / Regierungs-App / Finanz-App:** Nein.

**Gesundheits-Apps (Erklärung):** Funktionen ankreuzen, die zutreffen – voraussichtlich
„Ernährung und Gewichtsmanagement“ sowie „Aktivitäts- und Fitness-Tracking“ (wegen Waage). MuScale ist
**kein Medizinprodukt** und stellt keine Diagnosen.

**Health-Connect-Berechtigungen:** Für `READ_WEIGHT` eine Begründung angeben, z. B.:
> MuScale liest das Körpergewicht aus Health Connect, damit Nutzer mit einer smarten Waage ihr Gewicht nicht
> von Hand eintragen müssen. Aus dem Gewichtsverlauf und dem Ernährungstagebuch berechnet die App den
> tatsächlichen Kalorienbedarf und schlägt ein Tagesziel vor. Die Daten werden nur lokal auf dem Gerät
> gespeichert, nicht übertragen und nicht für Werbung verwendet. Die App schreibt keine Daten in Health Connect.

Google verlangt dafür ggf. ein kurzes Video, das den Ablauf zeigt (Einstellungen → Waage verbinden →
Berechtigung → Gewicht erscheint).

**Datensicherheit (Formular):**

| Frage | Antwort |
|---|---|
| Erhebt oder teilt die App Nutzerdaten? | **Ja** (siehe unten – wegen Open Food Facts) |
| Werden alle Daten bei der Übertragung verschlüsselt? | Ja (HTTPS) |
| Können Nutzer das Löschen ihrer Daten anfordern? | Daten liegen nur auf dem Gerät; Löschen in der App bzw. durch Deinstallation |
| Datentyp: **App-Aktivitäten → Suchverlauf in der App** | erhoben (Barcode/Suchbegriff geht an Open Food Facts), **nicht** geteilt, Verarbeitung nicht kurzlebig garantiert, erforderlich, Zweck: **App-Funktionen** |
| Gesundheit & Fitness, Gewicht, Profil | **nicht erhoben** – bleiben auf dem Gerät (zählt laut Google nicht als „Erhebung“) |

> Grenzfall: Ob die Suchanfrage an Open Food Facts als „Erhebung“ zählt, ist Auslegungssache. Die obige
> Angabe ist die vorsichtige Variante – zu viel angeben ist erlaubt, zu wenig nicht.

### 4.4 Testen und veröffentlichen

1. **Interner Test** (bis 100 Personen, sofort verfügbar): AAB hochladen, dich selbst als Tester eintragen,
   über den Link installieren. Ideal für den allerersten Check des signierten Pakets.
2. **Geschlossener Test** – Pflicht für private Entwicklerkonten, die **nach dem 13.11.2023** angelegt wurden:
   **mindestens 12 Tester, 14 Tage am Stück**, die die App auch wirklich nutzen. Tester per E-Mail-Liste oder
   Google-Gruppe einladen (Freunde, Gym, Familie). Danach in der Console „Zugriff auf Produktion beantragen“.
3. **Produktion:** Länder wählen (z. B. Deutschland, Österreich, Schweiz), Release anlegen, AAB hochladen,
   Änderungsnotiz aus `changelogs/1.txt`. Prüfung durch Google: meist 1–7 Tage.

---

## 5. F-Droid

F-Droid baut die App selbst aus dem Quellcode und signiert sie mit eigenem Schlüssel. Wir liefern:
- Quellcode unter freier Lizenz ✅ (GPL-3.0)
- Store-Texte und Bilder im Fastlane-Format ✅ (F-Droid liest `fastlane/metadata/android/` direkt aus dem Repo)
- Build-Rezept: Entwurf in [`fdroid/app.muscale.muscale.yml`](fdroid/app.muscale.muscale.yml)

### Ablauf
1. Tag `v1.0.0` existiert (siehe oben).
2. Konto auf [gitlab.com](https://gitlab.com) anlegen, das Repo
   [fdroid/fdroiddata](https://gitlab.com/fdroid/fdroiddata) forken.
3. Die Datei `docs/fdroid/app.muscale.muscale.yml` als `metadata/app.muscale.muscale.yml` hinzufügen,
   Merge Request stellen. Die F-Droid-Pipeline baut die App testweise; die Maintainer helfen bei Anpassungen.
4. Nach dem Merge erscheint die App nach einigen Tagen im F-Droid-Katalog. Neue Versionen erkennt F-Droid
   künftig automatisch an neuen Tags.

### Bekannte offene Punkte für F-Droid
- **sqlite3:** Das Paket lädt beim Bauen standardmäßig eine fertig kompilierte SQLite-Bibliothek herunter. F-Droid
  verlangt den Bau aus dem Quellcode. Lösung im Rezept: SQLite-Quelltext (Amalgamation, gemeinfrei) als
  `srclib` einbinden und in `pubspec.yaml` per `hooks: user_defines: sqlite3: source: source` darauf verweisen.
  Muss beim ersten F-Droid-Testbuild ausprobiert werden.
- **Health Connect:** Die Bibliothek ist Open Source (Android Jetpack), auf Android 8–13 braucht sie aber die
  Google-App „Health Connect“. F-Droid vergibt dafür eventuell das Merkmal „NonFreeDep“ (nur ein Hinweis, kein
  Ausschluss). Ab Android 14 ist Health Connect Teil des Systems.
- **Flutter Deferred Components:** Flutters Grundgerüst verweist auf Google Play Core. Unsere CI meldet das als
  Hinweis; F-Droid entfernt diese Verweise üblicherweise beim Build.

---

## 6. Store-Bilder neu erzeugen

Nach Design-Änderungen:

```bash
cd app && flutter test tool/store_screenshots_test.dart --update-goldens
cd .. && node scripts/store-graphics.js   # braucht Node mit Playwright
```
