[Setup]
AppId={{APP_ID}}
AppVersion={{APP_VERSION}}
AppName={{DISPLAY_NAME}}
AppPublisher={{PUBLISHER_NAME}}
AppPublisherURL={{PUBLISHER_URL}}
AppSupportURL={{PUBLISHER_URL}}
AppUpdatesURL={{PUBLISHER_URL}}
DefaultDirName={{INSTALL_DIR_NAME}}
DisableProgramGroupPage=yes
OutputDir=.
OutputBaseFilename={{OUTPUT_BASE_FILENAME}}
Compression=lzma
SolidCompression=yes
SetupIconFile={{SETUP_ICON_FILE}}
WizardStyle=modern
PrivilegesRequired=admin
ArchitecturesAllowed={{ARCH}}
ArchitecturesInstallIn64BitMode={{ARCH}}

[Code]
const
  SYNCHRONIZE = $00100000;

function OpenProcess(dwDesiredAccess: DWORD; bInheritHandle: BOOL; dwProcessId: DWORD): THandle;
  external 'OpenProcess@kernel32.dll stdcall';
function WaitForSingleObject(hHandle: THandle; dwMilliseconds: DWORD): DWORD;
  external 'WaitForSingleObject@kernel32.dll stdcall';
function CloseHandle(hObject: THandle): BOOL;
  external 'CloseHandle@kernel32.dll stdcall';

// The app passes /updatefrom=<pid> (windowsUpdateArguments in lib/common)
// and exits on its own, stopping the Core and clearing the system proxy.
function UpdatingAppPid: Integer;
begin
  Result := StrToIntDef(ExpandConstant('{param:updatefrom|0}'), 0);
end;

function IsAppUpdate: Boolean;
begin
  Result := UpdatingAppPid > 0;
end;

procedure WaitForUpdatingApp;
var
  Handle: THandle;
begin
  if not IsAppUpdate then
    Exit;
  Handle := OpenProcess(SYNCHRONIZE, False, UpdatingAppPid);
  if Handle <> 0 then
  begin
    WaitForSingleObject(Handle, 15000);
    CloseHandle(Handle);
  end;
end;

// FlClash and FlClash RS ship Core and Helper processes of the same names, so a
// name alone would also end the other installation's. FlClash is also what this
// installation's executable was called before it became FlClash-RS.
procedure KillProcesses;
var
  AppDir: String;
  ResultCode: Integer;
begin
  AppDir := AddBackslash(ExpandConstant('{app}'));
  StringChangeEx(AppDir, '''', '''''', True);
  Exec('powershell.exe',
    '-NoProfile -NonInteractive -Command "Get-Process -Name FlClash,FlClash-RS,FlClashCore,FlClashHelperService -ErrorAction SilentlyContinue | ' +
    'Where-Object { $_.Path -and $_.Path.StartsWith(''' + AppDir + ''', [StringComparison]::OrdinalIgnoreCase) } | Stop-Process -Force"',
    '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
end;

procedure UnregisterHelperService;
var
  HelperPath: String;
  ResultCode: Integer;
begin
  HelperPath := ExpandConstant('{app}\\FlClashHelperService.exe');
  if FileExists(HelperPath) then
  begin
    Exec(HelperPath, 'uninstall', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
  end;
end;

procedure ClearStaleProxy;
var
  AppPath: String;
  ResultCode: Integer;
begin
  AppPath := ExpandConstant('{app}\\{{EXECUTABLE_NAME}}');
  if FileExists(AppPath) then
  begin
    Exec(AppPath, '--clear-stale-proxy', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
  end;
end;

function PointsIntoApp(Value: String): Boolean;
begin
  Result := Pos(Lowercase(AddBackslash(ExpandConstant('{app}'))), Lowercase(Value)) > 0;
end;

// The Run value name is sideBySideName, which DISPLAY_NAME matches in any
// case, and the schemes are protocolSchemes, both in lib/common.
function ProtocolSchemes: TArrayOfString;
begin
  Result := ['clash', 'clashmeta', 'flclash'];
end;

// Formats match run_value and url_command in plugins/rust_api; the app rewrites
// both on its next start, this covers a reboot before that.
procedure RepointUserRegistrations;
var
  AppPath: String;
  Schemes: TArrayOfString;
  Value: String;
  i: Integer;
begin
  AppPath := ExpandConstant('{app}\{{EXECUTABLE_NAME}}');
  if RegQueryStringValue(HKCU, 'Software\Microsoft\Windows\CurrentVersion\Run', '{{DISPLAY_NAME}}', Value) and PointsIntoApp(Value) then
  begin
    RegWriteStringValue(HKCU, 'Software\Microsoft\Windows\CurrentVersion\Run', '{{DISPLAY_NAME}}', AppPath);
  end;

  Schemes := ProtocolSchemes;
  for i := 0 to GetArrayLength(Schemes)-1 do
  begin
    if RegQueryStringValue(HKCU, 'Software\Classes\' + Schemes[i] + '\shell\open\command', '', Value) and PointsIntoApp(Value) then
    begin
      RegWriteStringValue(HKCU, 'Software\Classes\' + Schemes[i] + '\shell\open\command', '', '"' + AppPath + '" "%1"');
    end;
  end;
end;

procedure RemoveUserRegistrations;
var
  Schemes: TArrayOfString;
  Value: String;
  i: Integer;
begin
  if RegQueryStringValue(HKCU, 'Software\Microsoft\Windows\CurrentVersion\Run', '{{DISPLAY_NAME}}', Value) and PointsIntoApp(Value) then
  begin
    RegDeleteValue(HKCU, 'Software\Microsoft\Windows\CurrentVersion\Run', '{{DISPLAY_NAME}}');
    RegDeleteValue(HKCU, 'Software\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run', '{{DISPLAY_NAME}}');
  end;

  Schemes := ProtocolSchemes;
  for i := 0 to GetArrayLength(Schemes)-1 do
  begin
    if RegQueryStringValue(HKCU, 'Software\Classes\' + Schemes[i] + '\shell\open\command', '', Value) and PointsIntoApp(Value) then
    begin
      RegDeleteKeyIncludingSubkeys(HKCU, 'Software\Classes\' + Schemes[i]);
    end;
  end;
end;

function PrepareToInstall(var NeedsRestart: Boolean): String;
begin
  WaitForUpdatingApp;
  UnregisterHelperService;
  KillProcesses;
  Result := '';
end;

procedure CurStepChanged(CurStep: TSetupStep);
begin
  if CurStep = ssPostInstall then
  begin
    ClearStaleProxy;
    RepointUserRegistrations;
  end;
end;

function InitializeUninstall(): Boolean;
begin
  UnregisterHelperService;
  KillProcesses;
  ClearStaleProxy;
  Result := True;
end;

// path_provider names these folders after CompanyName and ProductName in
// windows/runner/Runner.rc.
procedure RemoveUserData;
begin
  DelTree(ExpandConstant('{userappdata}\com.follow\clash.rs'), True, True, True);
  DelTree(ExpandConstant('{localappdata}\com.follow\clash.rs'), True, True, True);
  RemoveDir(ExpandConstant('{userappdata}\com.follow'));
  RemoveDir(ExpandConstant('{localappdata}\com.follow'));
end;

procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
begin
  if CurUninstallStep = usPostUninstall then
  begin
    RemoveUserRegistrations;
    if not UninstallSilent and (MsgBox(CustomMessage('RemoveUserData'), mbConfirmation, MB_YESNO or MB_DEFBUTTON2) = IDYES) then
    begin
      RemoveUserData;
    end;
  end;
end;

[Languages]
Name: "chineseSimplified"; MessagesFile: "{{CHINESE_SIMPLIFIED_MESSAGES}}"
Name: "english"; MessagesFile: "compiler:Default.isl"

[CustomMessages]
english.RemoveUserData=Also delete your profiles and settings?

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked
[InstallDelete]
; The executable before the rename to FlClash-RS.exe.
Type: files; Name: "{app}\\FlClash.exe"

[Files]
Source: "{{SOURCE_DIR}}\\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
; NOTE: Don't use "Flags: ignoreversion" on any shared system files

[Icons]
Name: "{autoprograms}\\{{DISPLAY_NAME}}"; Filename: "{app}\\{{EXECUTABLE_NAME}}"
Name: "{autodesktop}\\{{DISPLAY_NAME}}"; Filename: "{app}\\{{EXECUTABLE_NAME}}"; Tasks: desktopicon
[Run]
Filename: "{app}\\{{EXECUTABLE_NAME}}"; Description: "{cm:LaunchProgram,{{DISPLAY_NAME}}}"; Flags: runascurrentuser nowait postinstall skipifsilent
Filename: "{app}\\{{EXECUTABLE_NAME}}"; Flags: runascurrentuser nowait; Check: IsAppUpdate
