#!/usr/bin/env bash
# Prüft eine APK auf Code, den F-Droid nicht akzeptiert (Google Play Services, Firebase, Google-Analytics/Ads).
#   scripts/check-fdroid-apk.sh app.apk
# Verweise auf Play Core (Flutters optionale „Deferred Components“) werden nur gemeldet, nicht als Fehler gewertet –
# F-Droid entfernt diese beim eigenen Build.
set -euo pipefail
apk="$1"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
unzip -q -o "$apk" 'classes*.dex' -d "$tmp"

forbidden='Lcom/google/android/gms/|Lcom/google/firebase/|Lcom/google/android/play/core/integrity|Lcom/google/ads/|Lcom/google/android/datatransport/'
found=$(strings "$tmp"/classes*.dex | grep -Eo "(${forbidden})[A-Za-z0-9/_$]*" | sort -u || true)
playcore=$(strings "$tmp"/classes*.dex | grep -Eo 'Lcom/google/android/play/core/[A-Za-z0-9/_$]*' | grep -v integrity | sort -u || true)

if [[ -n "$playcore" ]]; then
  echo "Hinweis: Verweise auf Play Core (Flutter Deferred Components) – $(echo "$playcore" | wc -l) Klassen."
fi
if [[ -n "$found" ]]; then
  echo "Nicht F-Droid-tauglicher Code gefunden:"
  echo "$found" | head -40
  exit 1
fi
echo "OK: kein Google-Play-Services-, Firebase- oder Werbe-Code in $(basename "$apk")."
