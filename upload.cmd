@echo off
setlocal
set "UPLOAD_SCRIPT=%~dp0upload"
set "FLCLASHPLUS_UPLOAD_ROOT=%~dp0"
set "UPLOAD_TEMP=%TEMP%\flclashplus-upload-%RANDOM%-%RANDOM%.ps1"
copy /Y "%UPLOAD_SCRIPT%" "%UPLOAD_TEMP%" >nul
if errorlevel 1 exit /b %ERRORLEVEL%
pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%UPLOAD_TEMP%" %*
set "UPLOAD_EXIT=%ERRORLEVEL%"
del "%UPLOAD_TEMP%" >nul 2>nul
exit /b %UPLOAD_EXIT%
