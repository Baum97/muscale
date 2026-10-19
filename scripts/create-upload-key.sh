#!/usr/bin/env bash
# Erzeugt den Upload-Schlüssel für Google Play – einmalig, auf deinem eigenen Rechner (nicht in der Cloud).
#
#   scripts/create-upload-key.sh [Zielordner]
#
# Legt an:
#   <Zielordner>/muscale-upload.jks   – der Schlüssel. SICHER AUFBEWAHREN (Passwort-Manager + Backup)!
#   app/android/key.properties        – damit lokale Release-Builds signiert werden (ist in .gitignore)
# und gibt die vier Werte für die GitHub-Secrets aus.
#
# Verlierst du den Upload-Schlüssel, kann Google ihn zurücksetzen (Play App Signing) – das dauert aber Tage.
set -euo pipefail

target="${1:-$HOME/.muscale}"
keystore="$target/muscale-upload.jks"
alias="upload"
repo_root="$(cd "$(dirname "$0")/.." && pwd)"
properties="$repo_root/app/android/key.properties"

if ! command -v keytool >/dev/null; then
  echo "keytool fehlt – bitte ein JDK (z. B. Temurin 17) installieren." >&2
  exit 1
fi
if [[ -e "$keystore" ]]; then
  echo "$keystore existiert schon – nichts überschrieben." >&2
  exit 1
fi

mkdir -p "$target"
chmod 700 "$target"
read -r -s -p "Passwort für den Schlüssel (mind. 12 Zeichen): " password
echo
if [[ ${#password} -lt 12 ]]; then
  echo "Zu kurz." >&2
  exit 1
fi
read -r -s -p "Passwort wiederholen: " again
echo
if [[ "$password" != "$again" ]]; then
  echo "Passwörter stimmen nicht überein." >&2
  exit 1
fi
read -r -p "Dein Name (steht im Zertifikat, z. B. Max Mustermann): " name

keytool -genkeypair -v \
  -keystore "$keystore" -storetype PKCS12 \
  -alias "$alias" -keyalg RSA -keysize 4096 -validity 10000 \
  -storepass "$password" -keypass "$password" \
  -dname "CN=$name, O=MuScale, C=DE"
chmod 600 "$keystore"

cat > "$properties" <<PROPS
storeFile=$keystore
storePassword=$password
keyAlias=$alias
keyPassword=$password
PROPS
chmod 600 "$properties"

echo
echo "Fertig. Schlüssel: $keystore"
echo "Lokale Builds nutzen ihn über $properties (nicht committen – steht in .gitignore)."
echo
echo "Für GitHub (Repo → Settings → Secrets and variables → Actions → New repository secret):"
echo "  MUSCALE_KEYSTORE_BASE64 = Inhalt der Datei $target/keystore.base64.txt"
echo "  MUSCALE_KEYSTORE_PASSWORD = dein Passwort"
echo "  MUSCALE_KEY_ALIAS = $alias"
echo "  MUSCALE_KEY_PASSWORD = dein Passwort"
base64 < "$keystore" | tr -d '\n' > "$target/keystore.base64.txt"
chmod 600 "$target/keystore.base64.txt"
echo
echo "Lösche $target/keystore.base64.txt, sobald das Secret angelegt ist."
