# Fetches the SQLite amalgamation into third_party/sqlite3/ so the sqlite3
# Dart package can compile libsqlite3 from source (see hooks.user_defines.sqlite3
# in pubspec.yaml). PowerShell variant for Windows runners.
$ErrorActionPreference = 'Stop'

$version = '3460000'
$year = '2024'
$srcDir = 'third_party/sqlite3'
$zip = "$env:TEMP\sqlite-amalgamation-$version.zip"
$url = "https://www.sqlite.org/$year/sqlite-amalgamation-$version.zip"

New-Item -ItemType Directory -Force -Path $srcDir | Out-Null
Invoke-WebRequest -Uri $url -OutFile $zip
Expand-Archive -Path $zip -DestinationPath "$env:TEMP\sqlite" -Force
Move-Item -Force "$env:TEMP\sqlite\sqlite-amalgamation-$version\sqlite3.c" "$srcDir\sqlite3.c"
Move-Item -Force "$env:TEMP\sqlite\sqlite-amalgamation-$version\sqlite3.h" "$srcDir\sqlite3.h"
Remove-Item -Recurse -Force "$env:TEMP\sqlite", $zip
Write-Host "Fetched SQLite amalgamation $version into $srcDir"
