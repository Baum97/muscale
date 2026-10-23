# Erzeugt den Upload-Schlüssel für Google Play – Windows-Variante von create-upload-key.sh.
# Einmalig auf deinem eigenen Rechner ausführen (nicht in der Cloud):
#
#   powershell -ExecutionPolicy Bypass -File scripts\create-upload-key.ps1 [Zielordner]
#
# Legt an:
#   <Zielordner>\muscale-upload.jks   – der Schlüssel. SICHER AUFBEWAHREN (Passwort-Manager + Backup)!
#   app\android\key.properties        – damit lokale Release-Builds signiert werden (ist in .gitignore)
# und gibt die vier Werte für die GitHub-Secrets aus.
#
# Verlierst du den Upload-Schlüssel, kann Google ihn zurücksetzen (Play App Signing) – das dauert aber Tage.
param([string]$Target = (Join-Path $env:USERPROFILE '.muscale'))

$ErrorActionPreference = 'Stop'
$keystore = Join-Path $Target 'muscale-upload.jks'
$alias = 'upload'
$repoRoot = Split-Path -Parent $PSScriptRoot
$properties = Join-Path $repoRoot 'app\android\key.properties'
# Ohne BOM – sonst liest Gradle den ersten Eintrag (storeFile) nicht.
$utf8 = New-Object System.Text.UTF8Encoding($false)

function Fail([string]$message) {
  Write-Host $message -ForegroundColor Red
  exit 1
}

# keytool: aus PATH, JAVA_HOME oder dem JDK, das Android Studio mitbringt.
$keytool = (Get-Command keytool -ErrorAction SilentlyContinue).Source
if (-not $keytool) {
  $candidates = @()
  if ($env:JAVA_HOME) { $candidates += Join-Path $env:JAVA_HOME 'bin\keytool.exe' }
  $candidates += "$env:ProgramFiles\Android\Android Studio\jbr\bin\keytool.exe"
  $candidates += "$env:LOCALAPPDATA\Programs\Android Studio\jbr\bin\keytool.exe"
  $keytool = $candidates | Where-Object { Test-Path $_ } | Select-Object -First 1
}
if (-not $keytool) { Fail 'keytool fehlt – bitte ein JDK (z. B. Temurin 17) oder Android Studio installieren.' }
if (Test-Path $keystore) { Fail "$keystore existiert schon – nichts überschrieben." }

function Read-Secret([string]$prompt) {
  $secure = Read-Host -Prompt $prompt -AsSecureString
  $ptr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure)
  try { [Runtime.InteropServices.Marshal]::PtrToStringBSTR($ptr) }
  finally { [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($ptr) }
}

$password = Read-Secret 'Passwort für den Schlüssel (mind. 12 Zeichen)'
if ($password.Length -lt 12) { Fail 'Zu kurz.' }
# keytool (PKCS12) akzeptiert nur ASCII-Passwörter.
if ($password -notmatch '^[\x21-\x7E]+$') { Fail 'Bitte nur Buchstaben a–z/A–Z, Ziffern und Satzzeichen – keine Umlaute oder Leerzeichen.' }
if ($password -cne (Read-Secret 'Passwort wiederholen')) { Fail 'Passwörter stimmen nicht überein.' }
$name = Read-Host -Prompt 'Dein Name (steht im Zertifikat, z. B. Max Mustermann)'
if (-not $name -or $name -match '[,=+<>#;"\\]') { Fail 'Bitte einen Namen ohne Sonderzeichen wie , = ; angeben.' }

New-Item -ItemType Directory -Force -Path $Target | Out-Null
# Passwort über eine Umgebungsvariable statt als Argument – so bleiben Sonderzeichen unverändert.
$env:MUSCALE_NEW_KEY_PASSWORD = $password
try {
  & $keytool -genkeypair -v `
    -keystore $keystore -storetype PKCS12 `
    -alias $alias -keyalg RSA -keysize 4096 -validity 10000 `
    -storepass:env MUSCALE_NEW_KEY_PASSWORD -keypass:env MUSCALE_NEW_KEY_PASSWORD `
    -dname "CN=$name, O=MuScale, C=DE"
  if ($LASTEXITCODE -ne 0) { Fail 'keytool ist fehlgeschlagen.' }
} finally {
  Remove-Item Env:\MUSCALE_NEW_KEY_PASSWORD -ErrorAction SilentlyContinue
}

# In .properties-Dateien ist \ ein Escape-Zeichen: Pfad mit /, Backslashes im Passwort verdoppeln.
$escaped = $password.Replace('\', '\\')
$lines = @(
  "storeFile=$($keystore.Replace('\', '/'))",
  "storePassword=$escaped",
  "keyAlias=$alias",
  "keyPassword=$escaped"
)
[IO.File]::WriteAllText($properties, ($lines -join "`n") + "`n", $utf8)

$base64File = Join-Path $Target 'keystore.base64.txt'
[IO.File]::WriteAllText($base64File, [Convert]::ToBase64String([IO.File]::ReadAllBytes($keystore)), $utf8)

Write-Host ''
Write-Host "Fertig. Schlüssel: $keystore" -ForegroundColor Green
Write-Host "Lokale Builds nutzen ihn über $properties (nicht committen – steht in .gitignore)."
Write-Host ''
Write-Host 'Für GitHub (Repo → Settings → Secrets and variables → Actions → New repository secret):'
Write-Host "  MUSCALE_KEYSTORE_BASE64   = Inhalt der Datei $base64File"
Write-Host '  MUSCALE_KEYSTORE_PASSWORD = dein Passwort'
Write-Host "  MUSCALE_KEY_ALIAS         = $alias"
Write-Host '  MUSCALE_KEY_PASSWORD      = dein Passwort'
Write-Host ''
Write-Host "Tipp: Get-Content $base64File | Set-Clipboard  kopiert den Inhalt in die Zwischenablage."
Write-Host "Lösche $base64File, sobald das Secret angelegt ist."
