@echo off
setlocal EnableExtensions

cd /d "%~dp0.." || exit /b 1

set "COMMIT_MESSAGE=%~1"
if not defined COMMIT_MESSAGE set "COMMIT_MESSAGE=chore: update FlClashPlus source"

git diff --check
if errorlevel 1 exit /b %errorlevel%

pwsh.exe -NoLogo -NoProfile -Command ^
  "$ErrorActionPreference = 'Stop';" ^
  "$paths = @(git diff --name-only --diff-filter=ACMRTUXB);" ^
  "$paths = @($paths | Where-Object { $_ -ne 'plugins/flutter_distributor' });" ^
  "if (Test-Path -LiteralPath 'command/gitpush.cmd') { $paths += 'command/gitpush.cmd' };" ^
  "$paths = @($paths | Sort-Object -Unique);" ^
  "if ($paths.Count -gt 0) { & git add -- $paths; if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE } }"
if errorlevel 1 exit /b %errorlevel%

git diff --cached --quiet
if not errorlevel 1 (
  echo No source changes to commit.
  exit /b 0
)

git diff --cached --check
if errorlevel 1 exit /b %errorlevel%

git commit -m "%COMMIT_MESSAGE%"
exit /b %errorlevel%
