#requires -Version 7.0
[CmdletBinding()]
param(
    [ValidateSet('Plan', 'Build', 'Source', 'Publish', 'Verify', 'Clean', 'All')]
    [string]$Action = 'Plan',

    [ValidatePattern('^v[0-9]+\.[0-9]+\.[0-9]+(?:-[0-9A-Za-z][0-9A-Za-z.-]*)?$')]
    [string]$Tag = 'v0.8.93-plus.1',

    [ValidatePattern('^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$')]
    [string]$Repository = 'nekobyran/flclashplus',

    [switch]$Apply
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$ProjectRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$Version = $Tag.Substring(1)
$ReleaseRoot = [IO.Path]::GetFullPath(
    (Join-Path $ProjectRoot "release/flclashplus_publish/$Tag")
)
$ArtifactsRoot = Join-Path $ReleaseRoot 'artifacts'
$LogsRoot = Join-Path $ReleaseRoot 'logs'
$PackageOutputRoot = Join-Path $ReleaseRoot 'package-output'
$RepositoryStage = Join-Path $ReleaseRoot 'repository'
$BackupRoot = Join-Path $ReleaseRoot 'backup-manifest'
$SiteRoot = Join-Path $ProjectRoot 'release-site'
$SdkRoot = [IO.Path]::GetFullPath('D:\vibecoding\sdk')
$TaskTempRoot = Join-Path $SdkRoot "cache/temp/flclashplus-release-$Version"
$TaskCargoTarget = Join-Path $SdkRoot "cargo-target/flclashplus-release-$Version"
$SigningRoot = Join-Path $SdkRoot 'signing'
$SigningKeyStore = Join-Path $SigningRoot 'flclashplus-release.jks'
$SigningCredential = Join-Path $SigningRoot 'flclashplus-release.credential.dpapi'
$SigningAlias = 'flclashplus'
$ExpectedAndroidPackage = 'cc.nkbr.flclashplusplus'
$GitExecutable = $null
$GhExecutable = $null

function Get-GitExecutable {
    if (-not [string]::IsNullOrWhiteSpace($script:GitExecutable)) {
        return $script:GitExecutable
    }

    $candidates = @()
    $programFiles = [Environment]::GetFolderPath(
        [Environment+SpecialFolder]::ProgramFiles
    )
    if (-not [string]::IsNullOrWhiteSpace($programFiles)) {
        $candidates += @(
            (Join-Path $programFiles 'Git\cmd\git.exe'),
            (Join-Path $programFiles 'Git\bin\git.exe')
        )
    }
    $localAppData = [Environment]::GetFolderPath('LocalApplicationData')
    if (-not [string]::IsNullOrWhiteSpace($localAppData)) {
        $candidates += (Join-Path $localAppData 'Programs\Git\cmd\git.exe')
    }
    $command = Get-Command git -ErrorAction SilentlyContinue
    if ($null -ne $command) {
        $candidates += $command.Source
    }

    $resolved = @(
        $candidates |
            Where-Object { -not [string]::IsNullOrWhiteSpace($_) } |
            Where-Object { Test-Path -LiteralPath $_ -PathType Leaf } |
            Select-Object -First 1
    )
    if ($resolved.Count -ne 1) {
        throw 'Git for Windows was not found.'
    }

    $script:GitExecutable = [IO.Path]::GetFullPath($resolved[0])
    $gitDirectory = Split-Path -Parent $script:GitExecutable
    $pathEntries = @($env:PATH -split ';')
    if ($gitDirectory -notin $pathEntries) {
        $env:PATH = $gitDirectory + ';' + $env:PATH
    }
    $pathExtensions = @($env:PATHEXT -split ';')
    if ('.EXE' -notin $pathExtensions) {
        $env:PATHEXT = '.COM;.EXE;.BAT;.CMD;.VBS;.VBE;.JS;.JSE;.WSF;.WSH;.MSC;.CPL'
    }
    if ([string]::IsNullOrWhiteSpace($env:ComSpec)) {
        $env:ComSpec = Join-Path $env:SystemRoot 'System32\cmd.exe'
    }
    return $script:GitExecutable
}

function Get-GitHubCliExecutable {
    [void](Get-GitExecutable)
    if (-not [string]::IsNullOrWhiteSpace($script:GhExecutable)) {
        return $script:GhExecutable
    }

    if ([string]::IsNullOrWhiteSpace($env:GH_CONFIG_DIR)) {
        $roaming = [Environment]::GetFolderPath('ApplicationData')
        if (-not [string]::IsNullOrWhiteSpace($roaming)) {
            $configDir = Join-Path $roaming 'GitHub CLI'
            if (Test-Path -LiteralPath (Join-Path $configDir 'hosts.yml') -PathType Leaf) {
                $env:GH_CONFIG_DIR = $configDir
            }
        }
    }

    $command = Get-Command gh -ErrorAction SilentlyContinue
    if ($null -ne $command) {
        $script:GhExecutable = $command.Source
        return $script:GhExecutable
    }

    $localAppData = [Environment]::GetFolderPath('LocalApplicationData')
    if (-not [string]::IsNullOrWhiteSpace($localAppData)) {
        $packageRoot = Join-Path $localAppData 'Microsoft\WinGet\Packages'
        $candidate = @(
            Get-Item -Path (Join-Path $packageRoot 'GitHub.cli_*\bin\gh.exe') `
                -ErrorAction SilentlyContinue |
                Sort-Object FullName |
                Select-Object -First 1
        )
        if ($candidate.Count -eq 1) {
            $script:GhExecutable = $candidate[0].FullName
            return $script:GhExecutable
        }
    }

    throw 'GitHub CLI was not found. Install GitHub CLI or add gh to PATH.'
}

function Assert-DescendantPath {
    param(
        [Parameter(Mandatory)][string]$Parent,
        [Parameter(Mandatory)][string]$Child,
        [switch]$AllowEqual
    )

    $parentFull = [IO.Path]::GetFullPath($Parent).TrimEnd('\', '/')
    $childFull = [IO.Path]::GetFullPath($Child).TrimEnd('\', '/')
    if ($AllowEqual -and $childFull.Equals(
            $parentFull,
            [StringComparison]::OrdinalIgnoreCase
        )) {
        return $childFull
    }
    $prefix = $parentFull + [IO.Path]::DirectorySeparatorChar
    if (-not $childFull.StartsWith($prefix, [StringComparison]::OrdinalIgnoreCase)) {
        throw "Path escaped its allowed root: $childFull"
    }
    return $childFull
}

function Invoke-Captured {
    param(
        [Parameter(Mandatory)][string]$FilePath,
        [Parameter(Mandatory)][string[]]$Arguments,
        [string]$WorkingDirectory = $ProjectRoot,
        [string]$LogPath,
        [switch]$AllowFailure
    )

    $startInfo = [Diagnostics.ProcessStartInfo]::new()
    $startInfo.FileName = $FilePath
    $startInfo.WorkingDirectory = $WorkingDirectory
    $startInfo.UseShellExecute = $false
    $startInfo.CreateNoWindow = $true
    $startInfo.RedirectStandardOutput = $true
    $startInfo.RedirectStandardError = $true
    foreach ($argument in $Arguments) {
        [void]$startInfo.ArgumentList.Add([string]$argument)
    }

    $process = [Diagnostics.Process]::new()
    $process.StartInfo = $startInfo
    try {
        if (-not $process.Start()) {
            throw "Failed to start $FilePath"
        }
        $stdoutTask = $process.StandardOutput.ReadToEndAsync()
        $stderrTask = $process.StandardError.ReadToEndAsync()
        $process.WaitForExit()
        $stdout = $stdoutTask.GetAwaiter().GetResult()
        $stderr = $stderrTask.GetAwaiter().GetResult()
        $combined = @($stdout, $stderr) -join ''
        if (-not [string]::IsNullOrWhiteSpace($LogPath)) {
            $logFull = Assert-DescendantPath -Parent $ReleaseRoot -Child $LogPath
            New-Item -ItemType Directory -Force -Path (Split-Path -Parent $logFull) |
                Out-Null
            [IO.File]::WriteAllText($logFull, $combined, [Text.UTF8Encoding]::new($false))
        }
        if ($process.ExitCode -ne 0 -and -not $AllowFailure) {
            $tail = @($combined -split '\r?\n' | Where-Object { $_ }) |
                Select-Object -Last 30
            throw "$FilePath failed with exit code $($process.ExitCode).`n$($tail -join "`n")"
        }
        return [pscustomobject]@{
            ExitCode = $process.ExitCode
            Stdout = $stdout
            Stderr = $stderr
            Output = $combined
        }
    }
    finally {
        $process.Dispose()
    }
}

function Initialize-ReleaseEnvironment {
    New-Item -ItemType Directory -Force -Path @(
        $ReleaseRoot,
        $ArtifactsRoot,
        $LogsRoot,
        $BackupRoot,
        $TaskTempRoot,
        $TaskCargoTarget
    ) | Out-Null

    $env:TEMP = $TaskTempRoot
    $env:TMP = $TaskTempRoot
    $env:PUB_CACHE = Join-Path $SdkRoot 'pub-cache'
    $env:GRADLE_USER_HOME = Join-Path $SdkRoot 'gradle-user-home'
    $env:CARGO_HOME = Join-Path $SdkRoot 'cargo-home'
    $env:RUSTUP_HOME = Join-Path $SdkRoot 'rust\rustup'
    $env:RUSTUP_TOOLCHAIN = 'stable'
    $env:CARGO_TARGET_DIR = $TaskCargoTarget
    $rustToolchainBin = Join-Path $SdkRoot 'rust\rustup\toolchains\stable-x86_64-pc-windows-msvc\bin'
    $rustupShimBin = Join-Path $TaskTempRoot '.cargo\bin'
    New-Item -ItemType Directory -Force -Path $rustupShimBin | Out-Null
    Copy-Item -LiteralPath (Join-Path $SdkRoot 'rust-gamelaucher\cargo\bin\rustup.exe') `
        -Destination (Join-Path $rustupShimBin 'rustup.exe') -Force
    $env:RUSTC = Join-Path $rustToolchainBin 'rustc.exe'
    $env:RUSTDOC = Join-Path $rustToolchainBin 'rustdoc.exe'
    $env:PATH = "$rustupShimBin;$rustToolchainBin;$env:PATH"
    $env:GOCACHE = Join-Path $TaskTempRoot 'go-build'
    $env:GOMODCACHE = Join-Path $SdkRoot 'go/pkg/mod'
    $env:ANDROID_HOME = Join-Path $SdkRoot 'android'
    $env:ANDROID_SDK_ROOT = $env:ANDROID_HOME
    $env:JAVA_HOME = Join-Path $SdkRoot 'jdk'
    $env:INNO_SETUP_HOME = Join-Path $SdkRoot 'inno-setup-6'
}

function Initialize-PortableWindowsToolchain {
    $visualStudioRoot = Join-Path $SdkRoot 'visual-studio-build-tools'
    $windowsSdkRoot = Join-Path $SdkRoot 'windows-sdk'
    $programFilesX86 = Join-Path $SdkRoot 'program-files-x86'

    $msvc = Get-ChildItem -LiteralPath (Join-Path $visualStudioRoot 'VC\Tools\MSVC') -Directory |
        Sort-Object { [version]$_.Name } -Descending |
        Where-Object {
            Test-Path -LiteralPath (Join-Path $_.FullName 'bin\Hostx64\x64\cl.exe') -PathType Leaf
        } |
        Select-Object -First 1
    $windowsSdk = Get-ChildItem -LiteralPath (Join-Path $windowsSdkRoot 'Include') -Directory |
        Sort-Object { [version]$_.Name } -Descending |
        Where-Object {
            Test-Path -LiteralPath (Join-Path $windowsSdkRoot "Lib\$($_.Name)\um\x64\kernel32.lib") -PathType Leaf
        } |
        Select-Object -First 1
    if ($null -eq $msvc -or $null -eq $windowsSdk) {
        throw 'The portable Windows C++ toolchain is incomplete.'
    }

    $msbuild = Join-Path $visualStudioRoot 'MSBuild\Current\Bin\MSBuild.exe'
    $cmakeBin = Join-Path $visualStudioRoot 'Common7\IDE\CommonExtensions\Microsoft\CMake\CMake\bin'
    $ninjaBin = Join-Path $visualStudioRoot 'Common7\IDE\CommonExtensions\Microsoft\CMake\Ninja'
    $nugetBin = Join-Path $SdkRoot 'nuget'
    $vswhere = Join-Path $programFilesX86 'Microsoft Visual Studio\Installer\vswhere.exe'
    foreach ($required in @($msbuild, (Join-Path $cmakeBin 'cmake.exe'), (Join-Path $ninjaBin 'ninja.exe'), (Join-Path $nugetBin 'nuget.exe'), $vswhere)) {
        if (-not (Test-Path -LiteralPath $required -PathType Leaf)) {
            throw "Portable Windows build tool is missing: $required"
        }
    }

    $msvcRoot = $msvc.FullName
    $msvcBin = Join-Path $msvcRoot 'bin\Hostx64\x64'
    $sdkVersion = $windowsSdk.Name
    $sdkBin = Join-Path $windowsSdkRoot "bin\$sdkVersion\x64"
    $sdkIncludes = @('ucrt', 'shared', 'um', 'winrt', 'cppwinrt') |
        ForEach-Object { Join-Path $windowsSdkRoot "Include\$sdkVersion\$_" } |
        Where-Object { Test-Path -LiteralPath $_ -PathType Container }

    ${env:ProgramFiles(x86)} = $programFilesX86
    $env:VSINSTALLDIR = "$visualStudioRoot\"
    $env:VCINSTALLDIR = "$(Join-Path $visualStudioRoot 'VC')\"
    $env:VisualStudioVersion = '17.0'
    $env:NEKOSTAR_VS_BUILD_VERSION = (Get-Item -LiteralPath $msbuild).VersionInfo.FileVersion
    $env:VCToolsInstallDir = "$msvcRoot\"
    $env:VCToolsVersion = $msvc.Name
    $env:WindowsSdkDir = "$windowsSdkRoot\"
    $env:WindowsSDKVersion = "$sdkVersion\"
    $env:WindowsTargetPlatformVersion = $sdkVersion
    $env:UniversalCRTSdkDir = "$windowsSdkRoot\"
    $env:UCRTVersion = $sdkVersion
    $env:CC = Join-Path $msvcBin 'cl.exe'
    $env:CXX = $env:CC
    $env:RC = Join-Path $sdkBin 'rc.exe'
    $env:INCLUDE = (@((Join-Path $msvcRoot 'include')) + $sdkIncludes) -join ';'
    $env:LIB = @(
        (Join-Path $msvcRoot 'lib\x64'),
        (Join-Path $windowsSdkRoot "Lib\$sdkVersion\ucrt\x64"),
        (Join-Path $windowsSdkRoot "Lib\$sdkVersion\um\x64")
    ) -join ';'
    $env:CMAKE_GENERATOR = 'Visual Studio 17 2022'
    $env:CMAKE_GENERATOR_INSTANCE = "$visualStudioRoot,version=$($env:NEKOSTAR_VS_BUILD_VERSION)"
    $env:CMAKE_SYSTEM_VERSION = $sdkVersion
    $env:PATH = @(
        $msvcBin,
        $sdkBin,
        (Join-Path $visualStudioRoot 'MSBuild\Current\Bin'),
        $cmakeBin,
        $ninjaBin,
        $nugetBin,
        $env:PATH
    ) -join ';'

    $probe = Invoke-Captured -FilePath $vswhere -Arguments @(
        '-format', 'json', '-products', '*', '-utf8', '-latest'
    )
    if ($probe.Stdout -notmatch 'portable-vs-build-tools') {
        throw 'Portable Visual Studio discovery probe failed.'
    }
}

function Assert-DiskBudget {
    $cDrive = Get-PSDrive -Name C -ErrorAction Stop
    $dDrive = Get-PSDrive -Name D -ErrorAction Stop
    $cFree = [math]::Round($cDrive.Free / 1GB, 2)
    $dFree = [math]::Round($dDrive.Free / 1GB, 2)
    if ($cFree -lt 16) {
        throw "C drive free space is below 16 GiB ($cFree GiB)."
    }
    if ($dFree -lt 64) {
        throw "D drive free space is below 64 GiB ($dFree GiB)."
    }
    return [pscustomobject]@{ CFreeGiB = $cFree; DFreeGiB = $dFree }
}

function Get-AppVersion {
    $pubspec = Get-Content -LiteralPath (Join-Path $ProjectRoot 'pubspec.yaml') -Raw
    $match = [regex]::Match($pubspec, '(?m)^version:\s*([^\s]+)\s*$')
    if (-not $match.Success) {
        throw 'Unable to read pubspec version.'
    }
    return $match.Groups[1].Value
}

function Write-ProvenanceBackup {
    New-Item -ItemType Directory -Force -Path $BackupRoot | Out-Null
    $status = Invoke-Captured -FilePath (Get-GitExecutable) -Arguments @(
        'status', '--porcelain=v1', '-uall'
    ) -AllowFailure
    [IO.File]::WriteAllText(
        (Join-Path $BackupRoot 'git-status-before.txt'),
        $status.Output,
        [Text.UTF8Encoding]::new($false)
    )

    $head = Invoke-Captured -FilePath (Get-GitExecutable) -Arguments @('rev-parse', 'HEAD')
    [IO.File]::WriteAllText(
        (Join-Path $BackupRoot 'base-commit.txt'),
        $head.Stdout.Trim() + "`n",
        [Text.UTF8Encoding]::new($false)
    )

    $diff = Invoke-Captured -FilePath (Get-GitExecutable) -Arguments @(
        'diff', '--binary', '--no-ext-diff', 'HEAD'
    ) -AllowFailure
    $superPatch = Join-Path $BackupRoot 'superproject-working.patch'
    [IO.File]::WriteAllText(
        $superPatch,
        $diff.Output,
        [Text.UTF8Encoding]::new($false)
    )

    $nestedPatch = Join-Path $BackupRoot 'flutter-distributor-working.patch'
    $nestedRoot = Join-Path $ProjectRoot 'plugins/flutter_distributor'
    if (Test-Path -LiteralPath (Join-Path $nestedRoot '.git')) {
        $nested = Invoke-Captured -FilePath (Get-GitExecutable) -WorkingDirectory $nestedRoot `
            -Arguments @('diff', '--binary', '--no-ext-diff', 'HEAD') -AllowFailure
        [IO.File]::WriteAllText(
            $nestedPatch,
            $nested.Output,
            [Text.UTF8Encoding]::new($false)
        )
    }
    else {
        [IO.File]::WriteAllText(
            $nestedPatch,
            '',
            [Text.UTF8Encoding]::new($false)
        )
    }

    $records = @(
        foreach ($path in @(
                (Join-Path $BackupRoot 'git-status-before.txt'),
                (Join-Path $BackupRoot 'base-commit.txt'),
                $superPatch,
                $nestedPatch
            )) {
            $item = Get-Item -LiteralPath $path
            [ordered]@{
                file = $item.Name
                sizeBytes = $item.Length
                sha256 = (Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash.ToLowerInvariant()
            }
        }
    )
    [ordered]@{
        schemaVersion = 1
        capturedAt = [DateTimeOffset]::UtcNow.ToString('o')
        tag = $Tag
        appVersion = Get-AppVersion
        files = $records
    } | ConvertTo-Json -Depth 8 |
        Set-Content -LiteralPath (Join-Path $BackupRoot 'provenance.json') -Encoding utf8
}

function New-RandomPassword {
    $bytes = [byte[]]::new(36)
    [Security.Cryptography.RandomNumberGenerator]::Fill($bytes)
    return [Convert]::ToBase64String($bytes).TrimEnd('=').Replace('+', 'A').Replace('/', 'B')
}

function Protect-SigningCredential {
    param(
        [Parameter(Mandatory)][string]$Password
    )

    $payload = [ordered]@{
        schemaVersion = 1
        alias = $SigningAlias
        storePassword = $Password
        keyPassword = $Password
    } | ConvertTo-Json -Compress
    $secure = ConvertTo-SecureString -String $payload -AsPlainText -Force
    try {
        ConvertFrom-SecureString -SecureString $secure |
            Set-Content -LiteralPath $SigningCredential -Encoding ascii
    }
    finally {
        $secure.Dispose()
        $payload = $null
    }
}

function New-AndroidSigningIdentity {
    New-Item -ItemType Directory -Force -Path $SigningRoot | Out-Null
    $keyExists = Test-Path -LiteralPath $SigningKeyStore -PathType Leaf
    $credentialExists = Test-Path -LiteralPath $SigningCredential -PathType Leaf
    if ($keyExists -xor $credentialExists) {
        throw 'Android signing identity is incomplete; refusing to replace it.'
    }
    if ($keyExists -and $credentialExists) {
        return
    }

    $keytool = Join-Path $env:JAVA_HOME 'bin/keytool.exe'
    if (-not (Test-Path -LiteralPath $keytool -PathType Leaf)) {
        throw 'keytool.exe was not found in the D drive JDK.'
    }

    $password = New-RandomPassword
    try {
        Invoke-Captured -FilePath $keytool -Arguments @(
            '-genkeypair',
            '-keystore', $SigningKeyStore,
            '-storepass', $password,
            '-keypass', $password,
            '-alias', $SigningAlias,
            '-keyalg', 'RSA',
            '-keysize', '4096',
            '-validity', '10000',
            '-dname', 'CN=FlClashPlus Private Release,OU=Release,O=Nekobyran,L=Singapore,ST=Singapore,C=SG'
        ) -LogPath (Join-Path $LogsRoot 'android-signing-key-create.log') | Out-Null
        Protect-SigningCredential -Password $password
    }
    catch {
        if (Test-Path -LiteralPath $SigningKeyStore) {
            Remove-Item -LiteralPath $SigningKeyStore -Force
        }
        if (Test-Path -LiteralPath $SigningCredential) {
            Remove-Item -LiteralPath $SigningCredential -Force
        }
        throw
    }
    finally {
        $password = $null
    }
}

function Read-SigningCredential {
    $protected = Get-Content -LiteralPath $SigningCredential -Raw -Encoding ascii
    $secure = ConvertTo-SecureString -String $protected.Trim()
    $bstr = [IntPtr]::Zero
    try {
        $bstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure)
        $json = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr)
        $value = $json | ConvertFrom-Json
        if (
            $value.schemaVersion -ne 1 -or
            $value.alias -ne $SigningAlias -or
            [string]::IsNullOrWhiteSpace($value.storePassword) -or
            [string]::IsNullOrWhiteSpace($value.keyPassword)
        ) {
            throw 'Android signing credential is invalid.'
        }
        return $value
    }
    finally {
        if ($bstr -ne [IntPtr]::Zero) {
            [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr)
        }
        $secure.Dispose()
        $protected = $null
        $json = $null
    }
}

function Save-FileState {
    param([Parameter(Mandatory)][string]$Path)
    if (Test-Path -LiteralPath $Path -PathType Leaf) {
        return [pscustomobject]@{
            Path = $Path
            Existed = $true
            Bytes = [IO.File]::ReadAllBytes($Path)
        }
    }
    return [pscustomobject]@{ Path = $Path; Existed = $false; Bytes = $null }
}

function Restore-FileState {
    param([Parameter(Mandatory)][pscustomobject]$State)
    if ($State.Existed) {
        [IO.File]::WriteAllBytes($State.Path, [byte[]]$State.Bytes)
    }
    elseif (Test-Path -LiteralPath $State.Path -PathType Leaf) {
        Remove-Item -LiteralPath $State.Path -Force
    }
}

function Get-LatestBuildTool {
    param([Parameter(Mandatory)][string]$Name)
    $root = Join-Path $env:ANDROID_SDK_ROOT 'build-tools'
    $candidates = @(
        Get-ChildItem -LiteralPath $root -Directory -ErrorAction Stop |
            ForEach-Object {
                $tool = Join-Path $_.FullName $Name
                if (Test-Path -LiteralPath $tool -PathType Leaf) {
                    $version = $null
                    if ([version]::TryParse($_.Name, [ref]$version)) {
                        [pscustomobject]@{ Path = $tool; Version = $version }
                    }
                }
            }
    )
    $selected = $candidates | Sort-Object Version -Descending | Select-Object -First 1
    if ($null -eq $selected) {
        throw "Android build tool was not found: $Name"
    }
    return $selected.Path
}

function Test-AndroidArtifact {
    param([Parameter(Mandatory)][string]$ApkPath)

    $aapt = Get-LatestBuildTool -Name 'aapt.exe'
    $apksigner = Get-LatestBuildTool -Name 'apksigner.bat'
    $badging = Invoke-Captured -FilePath $aapt -Arguments @(
        'dump', 'badging', $ApkPath
    ) -LogPath (Join-Path $LogsRoot 'android-aapt-badging.log')
    if ($badging.Output -notmatch "package: name='$([regex]::Escape($ExpectedAndroidPackage))'") {
        throw 'Android package name does not match the release contract.'
    }
    if ($badging.Output -notmatch "native-code:.*'arm64-v8a'") {
        throw 'Android artifact does not contain the arm64-v8a ABI.'
    }

    $signature = Invoke-Captured -FilePath $apksigner -Arguments @(
        'verify', '--verbose', '--print-certs', $ApkPath
    ) -LogPath (Join-Path $LogsRoot 'android-apksigner-verify.log')
    if ($signature.Output -notmatch 'Verified using v[23] scheme.*true') {
        throw 'Android APK signature verification did not report a valid modern scheme.'
    }
}

function Test-WindowsZipArtifact {
    param([Parameter(Mandatory)][string]$ZipPath)

    Add-Type -AssemblyName System.IO.Compression
    $archive = [IO.Compression.ZipFile]::OpenRead($ZipPath)
    try {
        $names = @($archive.Entries | ForEach-Object FullName)
        if (-not ($names | Where-Object { $_ -match '(^|/)flclashplusplus\.exe$' })) {
            throw 'Windows portable ZIP is missing flclashplusplus.exe.'
        }
        if (-not ($names | Where-Object { $_ -match '(^|/)flutter_windows\.dll$' })) {
            throw 'Windows portable ZIP is missing flutter_windows.dll.'
        }
        $names | Sort-Object |
            Set-Content -LiteralPath (Join-Path $LogsRoot 'windows-zip-entries.txt') -Encoding utf8
    }
    finally {
        $archive.Dispose()
    }
}

function Write-Checksums {
    $files = @(
        Get-ChildItem -LiteralPath $ArtifactsRoot -File |
            Where-Object { $_.Name -ne 'SHA256SUMS' } |
            Sort-Object Name
    )
    if ($files.Count -lt 3) {
        throw 'Expected Android APK, Windows setup, and Windows portable artifacts.'
    }
    $lines = foreach ($file in $files) {
        $hash = (Get-FileHash -LiteralPath $file.FullName -Algorithm SHA256).Hash.ToLowerInvariant()
        "$hash  $($file.Name)"
    }
    $checksumPath = Join-Path $ArtifactsRoot 'SHA256SUMS'
    [IO.File]::WriteAllText(
        $checksumPath,
        ($lines -join "`n") + "`n",
        [Text.UTF8Encoding]::new($false)
    )
    return $checksumPath
}

function Get-ReleaseAssets {
    $files = @(
        Get-ChildItem -LiteralPath $ArtifactsRoot -File |
            Where-Object { $_.Name -ne 'artifact-manifest.json' } |
            Sort-Object Name
    )
    if ($files.Count -lt 4) {
        throw 'Release artifact set is incomplete.'
    }
    return @(
        foreach ($file in $files) {
            $platform = if ($file.Extension -eq '.apk') {
                'android'
            }
            elseif ($file.Extension -in @('.exe', '.zip')) {
                'windows'
            }
            else {
                'verification'
            }
            $kind = switch ($file.Extension) {
                '.apk' { 'installer' }
                '.exe' { 'installer' }
                '.zip' { 'portable' }
                default { 'checksum' }
            }
            $label = switch ($file.Extension) {
                '.apk' { 'Android ARM64' }
                '.exe' { 'Windows Installer' }
                '.zip' { 'Windows Portable' }
                default { 'SHA-256 Checksums' }
            }
            [ordered]@{
                id = [IO.Path]::GetFileNameWithoutExtension($file.Name).ToLowerInvariant()
                label = $label
                platform = $platform
                arch = if ($file.Extension -eq '.apk') { 'arm64-v8a' } elseif ($platform -eq 'windows') { 'x64' } else { 'all' }
                fileName = $file.Name
                sizeBytes = $file.Length
                sha256 = (Get-FileHash -LiteralPath $file.FullName -Algorithm SHA256).Hash.ToLowerInvariant()
                url = "https://github.com/$Repository/releases/download/$Tag/$([Uri]::EscapeDataString($file.Name))"
                kind = $kind
            }
        }
    )
}

function Write-SiteManifest {
    if (-not (Test-Path -LiteralPath $SiteRoot -PathType Container)) {
        throw 'release-site is missing.'
    }
    $assets = Get-ReleaseAssets
    $manifest = [ordered]@{
        schemaVersion = 1
        product = [ordered]@{
            name = 'FlClashPlus'
            tagline = '公开源码与跨端发布，下载可验证。'
        }
        release = [ordered]@{
            tag = $Tag
            version = $Version
            appVersion = Get-AppVersion
            publishedAt = [DateTimeOffset]::UtcNow.ToString('o')
            releaseUrl = "https://github.com/$Repository/releases/tag/$Tag"
            privateAccess = $false
            notes = @(
                '公开源码与公开 Release，遵循 GNU GPL v3.0。',
                'Android 与 Windows 工件来自同一份源码快照。',
                '安装前请使用 SHA256SUMS 核验下载文件。'
            )
            assets = $assets
        }
    }
    $manifestPath = Join-Path $SiteRoot 'public/release.json'
    $manifest | ConvertTo-Json -Depth 12 |
        Set-Content -LiteralPath $manifestPath -Encoding utf8
    $assets | ConvertTo-Json -Depth 8 |
        Set-Content -LiteralPath (Join-Path $ArtifactsRoot 'artifact-manifest.json') -Encoding utf8
}

function Invoke-ReleaseBuild {
    Initialize-ReleaseEnvironment
    $disk = Assert-DiskBudget
    Write-ProvenanceBackup
    New-AndroidSigningIdentity

    New-Item -ItemType Directory -Force -Path $PackageOutputRoot | Out-Null

    $baselinePaths = @(
        (Join-Path $ProjectRoot 'build'),
        (Join-Path $ProjectRoot 'libclash'),
        (Join-Path $ProjectRoot 'services/helper/target'),
        (Join-Path $ProjectRoot 'plugins/rust_api/rust/target'),
        (Join-Path $ProjectRoot 'android/app/src/main/jniLibs')
    )
    [ordered]@{
        schemaVersion = 1
        paths = @(
            foreach ($path in $baselinePaths) {
                [ordered]@{
                    path = $path
                    existedBefore = Test-Path -LiteralPath $path
                }
            }
        )
    } | ConvertTo-Json -Depth 6 |
        Set-Content -LiteralPath (Join-Path $BackupRoot 'build-path-baseline.json') -Encoding utf8

    $localPropertiesPath = Join-Path $ProjectRoot 'android/local.properties'
    $temporaryKeyStorePath = Join-Path $ProjectRoot 'android/app/keystore.jks'
    $distributorOptionsPath = Join-Path $ProjectRoot 'distribute_options.yaml'
    $windowsMakeConfigPath = Join-Path $ProjectRoot 'windows/packaging/exe/make_config.yaml'
    $envJsonPath = Join-Path $ProjectRoot 'env.json'
    $coreHashPath = Join-Path $ProjectRoot 'core_sha256.json'
    $localState = Save-FileState -Path $localPropertiesPath
    $optionsState = Save-FileState -Path $distributorOptionsPath
    $windowsMakeConfigState = Save-FileState -Path $windowsMakeConfigPath
    $envState = Save-FileState -Path $envJsonPath
    $coreState = Save-FileState -Path $coreHashPath
    if (Test-Path -LiteralPath $temporaryKeyStorePath) {
        throw 'android/app/keystore.jks already exists; refusing to overwrite it.'
    }

    $credential = $null
    try {
        $credential = Read-SigningCredential
        Copy-Item -LiteralPath $SigningKeyStore -Destination $temporaryKeyStorePath

        $localText = if ($localState.Existed) {
            [Text.Encoding]::UTF8.GetString([byte[]]$localState.Bytes)
        }
        else {
            ''
        }
        if ($localText.Length -gt 0 -and -not $localText.EndsWith("`n")) {
            $localText += "`n"
        }
        $localText += "storePassword=$($credential.storePassword)`n"
        $localText += "keyAlias=$SigningAlias`n"
        $localText += "keyPassword=$($credential.keyPassword)`n"
        [IO.File]::WriteAllText(
            $localPropertiesPath,
            $localText,
            [Text.UTF8Encoding]::new($false)
        )

        $optionsText = [Text.Encoding]::UTF8.GetString([byte[]]$optionsState.Bytes)
        $relativeOutput = [IO.Path]::GetRelativePath(
            $ProjectRoot,
            $PackageOutputRoot
        ).Replace('\', '/').TrimEnd('/') + '/'
        $updatedOptions = [regex]::Replace(
            $optionsText,
            "(?m)^output:\s*['""]?.*?['""]?\s*$",
            "output: '$relativeOutput'"
        )
        if ($updatedOptions -eq $optionsText) {
            throw 'Unable to redirect flutter_distributor output safely.'
        }
        [IO.File]::WriteAllText(
            $distributorOptionsPath,
            $updatedOptions,
            [Text.UTF8Encoding]::new($false)
        )

        $windowsMakeConfigText = [Text.Encoding]::UTF8.GetString(
            [byte[]]$windowsMakeConfigState.Bytes
        )
        $setupIconPath = (Join-Path $ProjectRoot 'windows/runner/resources/app_icon.ico').Replace('\', '/')
        $localePath = (Join-Path $ProjectRoot 'windows/packaging/exe/ChineseSimplified.isl').Replace('\', '/')
        $windowsMakeConfigText = [regex]::Replace(
            $windowsMakeConfigText,
            '(?m)^setup_icon_file:\s*.*$',
            "setup_icon_file: '$setupIconPath'"
        )
        $windowsMakeConfigText = [regex]::Replace(
            $windowsMakeConfigText,
            '(?m)^(\s*file:\s*).*$',
            "    file: '$localePath'"
        )
        [IO.File]::WriteAllText(
            $windowsMakeConfigPath,
            $windowsMakeConfigText,
            [Text.UTF8Encoding]::new($false)
        )

        Invoke-Captured -FilePath 'dart' -Arguments @(
            'pub', 'get'
        ) -LogPath (Join-Path $LogsRoot 'dart-pub-get.log') | Out-Null

        $existingApks = @(Get-ChildItem -LiteralPath $PackageOutputRoot -Recurse -File -Filter '*.apk')
        if ($existingApks.Count -gt 1) {
            throw 'Multiple Android package outputs exist; refusing an ambiguous resume.'
        }
        if ($existingApks.Count -eq 0) {
            Invoke-Captured -FilePath 'dart' -Arguments @(
                'setup.dart', 'android', '--env', 'stable', '--targets', 'apk',
                '--arch', 'arm64'
            ) -LogPath (Join-Path $LogsRoot 'build-android-release.log') | Out-Null
        }

        $existingExes = @(Get-ChildItem -LiteralPath $PackageOutputRoot -File -Filter '*.exe')
        $existingZips = @(Get-ChildItem -LiteralPath $PackageOutputRoot -File -Filter '*.zip')
        if ($existingExes.Count -gt 1 -or $existingZips.Count -gt 1) {
            throw 'Multiple Windows package outputs exist; refusing an ambiguous resume.'
        }
        if ($existingExes.Count -eq 0 -or $existingZips.Count -eq 0) {
            $env:CARGO_TARGET_DIR = $null
            Initialize-PortableWindowsToolchain
            Invoke-Captured -FilePath $env:ComSpec -Arguments @(
                '/d', '/s', '/c', 'flutter doctor -v'
            ) -LogPath (Join-Path $LogsRoot 'flutter-doctor-windows.log') | Out-Null
            Invoke-Captured -FilePath 'dart' -Arguments @(
                'setup.dart', 'windows', '--env', 'stable', '--targets', 'exe,zip'
            ) -LogPath (Join-Path $LogsRoot 'build-windows-release.log') | Out-Null
        }
    }
    finally {
        $credential = $null
        if (Test-Path -LiteralPath $temporaryKeyStorePath -PathType Leaf) {
            Remove-Item -LiteralPath $temporaryKeyStorePath -Force
        }
        Restore-FileState -State $localState
        Restore-FileState -State $optionsState
        Restore-FileState -State $windowsMakeConfigState
        Restore-FileState -State $envState
        Restore-FileState -State $coreState
    }

    $apk = Get-ChildItem -LiteralPath $PackageOutputRoot -Recurse -File -Filter '*.apk' |
        Sort-Object LastWriteTime -Descending | Select-Object -First 1
    $setup = Get-ChildItem -LiteralPath $PackageOutputRoot -File -Filter '*.exe' |
        Sort-Object LastWriteTime -Descending | Select-Object -First 1
    $portable = Get-ChildItem -LiteralPath $PackageOutputRoot -File -Filter '*.zip' |
        Sort-Object LastWriteTime -Descending | Select-Object -First 1
    if ($null -eq $apk -or $null -eq $setup -or $null -eq $portable) {
        throw 'One or more expected package outputs are missing.'
    }

    $artifactPaths = [ordered]@{
        Android = Join-Path $ArtifactsRoot "FlClashPlus-$Version-android-arm64-v8a.apk"
        WindowsSetup = Join-Path $ArtifactsRoot "FlClashPlus-$Version-windows-x64-setup.exe"
        WindowsPortable = Join-Path $ArtifactsRoot "FlClashPlus-$Version-windows-x64-portable.zip"
    }
    foreach ($destination in $artifactPaths.Values) {
        if (Test-Path -LiteralPath $destination) {
            throw "Artifact already exists: $destination"
        }
    }
    Copy-Item -LiteralPath $apk.FullName -Destination $artifactPaths.Android
    Copy-Item -LiteralPath $setup.FullName -Destination $artifactPaths.WindowsSetup
    Copy-Item -LiteralPath $portable.FullName -Destination $artifactPaths.WindowsPortable

    Test-AndroidArtifact -ApkPath $artifactPaths.Android
    Test-WindowsZipArtifact -ZipPath $artifactPaths.WindowsPortable
    $signature = Get-AuthenticodeSignature -LiteralPath $artifactPaths.WindowsSetup
    [ordered]@{
        status = [string]$signature.Status
        statusMessage = [string]$signature.StatusMessage
        signerSubject = if ($signature.SignerCertificate) {
            $signature.SignerCertificate.Subject
        }
        else {
            $null
        }
    } | ConvertTo-Json |
        Set-Content -LiteralPath (Join-Path $LogsRoot 'windows-setup-authenticode.json') -Encoding utf8

    [void](Write-Checksums)
    Write-SiteManifest
    $siteCheckSource = Join-Path $SiteRoot 'scripts\check.mjs'
    $siteCheckScript = Join-Path $TaskTempRoot 'release-site-check.mjs'
    $siteCheckText = Get-Content -LiteralPath $siteCheckSource -Raw
    $siteRootMarker = 'const siteRoot = join(scriptDirectory, "..");'
    $projectRootMarker = 'const projectRoot = join(siteRoot, "..");'
    if (-not $siteCheckText.Contains($siteRootMarker) -or -not $siteCheckText.Contains($projectRootMarker)) {
        throw 'release-site checker root markers are missing.'
    }
    $siteRootJson = $SiteRoot | ConvertTo-Json -Compress
    $projectRootJson = $ProjectRoot | ConvertTo-Json -Compress
    $siteCheckText = $siteCheckText.Replace($siteRootMarker, "const siteRoot = $siteRootJson;")
    $siteCheckText = $siteCheckText.Replace($projectRootMarker, "const projectRoot = $projectRootJson;")
    [IO.File]::WriteAllText($siteCheckScript, $siteCheckText, [Text.UTF8Encoding]::new($false))
    Invoke-Captured -FilePath 'node' -WorkingDirectory $ProjectRoot -Arguments @($siteCheckScript) -LogPath (Join-Path $LogsRoot 'release-site-check.log') | Out-Null
    [ordered]@{
        result = 'built'
        tag = $Tag
        appVersion = Get-AppVersion
        cFreeGiBAtStart = $disk.CFreeGiB
        dFreeGiBAtStart = $disk.DFreeGiB
        artifacts = Get-ReleaseAssets
    } | ConvertTo-Json -Depth 12
}

function Test-SensitiveStagingContent {
    param([Parameter(Mandatory)][string]$Root)

    $forbiddenNames = @(
        '.env',
        'local.properties',
        'keystore.jks',
        'google-services.json'
    )
    $forbidden = @(
        Get-ChildItem -LiteralPath $Root -Recurse -File -Force |
            Where-Object { $_.Name -in $forbiddenNames }
    )
    if ($forbidden.Count -gt 0) {
        throw "Sensitive or machine-local file entered the source mirror: $($forbidden[0].FullName)"
    }

    $tokenPattern = '(?:gh[pousr]_[A-Za-z0-9]{20,}|github_pat_[A-Za-z0-9_]{20,}|CLOUDFLARE_API_TOKEN\s*=\s*["'']?[A-Za-z0-9_-]{16,})'
    $passwordPattern = '(?<name>storePassword|keyPassword)\s*=\s*["''](?<value>[^"''\r\n]{4,})["'']'
    $allowedPasswordPlaceholders = @(
        'your_key_password',
        'your_store_password'
    )
    $allowedLiteralPasswordFileHashes = @(
        'ca95c420ea323afb9209b44206037ec6f5bb761c8b2924fd9c74b1c63cf78b34'
    )
    $textFiles = @(
        Get-ChildItem -LiteralPath $Root -Recurse -File -Force |
            Where-Object {
                $_.Length -lt 2MB -and
                $_.FullName -notmatch '[\\/]\.git[\\/]' -and
                $_.Extension -notin @(
                    '.png', '.jpg', '.jpeg', '.gif', '.ico', '.ttf', '.dat',
                    '.mmdb', '.metadb', '.jar', '.zip', '.apk', '.exe', '.dll',
                    '.so', '.dylib', '.a', '.lib'
                )
            }
    )
    foreach ($file in $textFiles) {
        if (Select-String -LiteralPath $file.FullName -Pattern $tokenPattern -Quiet) {
            throw "Potential token pattern found in source mirror: $($file.FullName)"
        }
        $passwordHits = @(Select-String -LiteralPath $file.FullName `
                -Pattern $passwordPattern -AllMatches)
        foreach ($hit in $passwordHits) {
            foreach ($match in $hit.Matches) {
                $value = $match.Groups['value'].Value.ToLowerInvariant()
                if ($value -notin $allowedPasswordPlaceholders) {
                    $fileHash = (Get-FileHash -LiteralPath $file.FullName `
                            -Algorithm SHA256).Hash.ToLowerInvariant()
                    if ($fileHash -notin $allowedLiteralPasswordFileHashes) {
                        throw "Potential literal password found in source mirror: $($file.FullName)"
                    }
                }
            }
        }
    }
}

function Copy-SourceTree {
    param(
        [Parameter(Mandatory)][string]$Source,
        [Parameter(Mandatory)][string]$Destination
    )

    $excludedSegments = @(
        '.git', '.dart_tool', '.flutter', '.visual-qa', '.wrangler', '.npm', '=',
        'npm-cache', 'build', 'coverage', 'target', '.gradle', '.kotlin',
        '.idea', '.vs', '.cxx', 'Pods', '.plugin_symlinks', 'node_modules',
        'jniLibs'
    )
    $excludedFiles = @(
        'local.properties', 'keystore.jks', 'google-services.json',
        'env.json', 'core_sha256.json', '.flutter_tool_state'
    )
    if (Test-Path -LiteralPath $Source -PathType Leaf) {
        New-Item -ItemType Directory -Force -Path (Split-Path -Parent $Destination) |
            Out-Null
        Copy-Item -LiteralPath $Source -Destination $Destination
        return
    }

    foreach ($file in Get-ChildItem -LiteralPath $Source -Recurse -File -Force) {
        $relative = [IO.Path]::GetRelativePath($Source, $file.FullName)
        $segments = @($relative -split '[\\/]')
        if (@($segments | Where-Object { $_ -in $excludedSegments -or $_ -match '^vibecodingsdktoolswrangler(?:-|$)' }).Count -gt 0) {
            continue
        }
        if ($file.Name -in $excludedFiles -or
            $file.Name -match '^(?:hs_err_pid|replay_pid).+\.log$') {
            continue
        }
        $target = Join-Path $Destination $relative
        New-Item -ItemType Directory -Force -Path (Split-Path -Parent $target) |
            Out-Null
        Copy-Item -LiteralPath $file.FullName -Destination $target
    }
}

function New-SourceManifest {
    param([Parameter(Mandatory)][string]$Root)
    $manifestPath = Join-Path $Root 'SOURCE_MANIFEST.sha256'
    $lines = @(
        Get-ChildItem -LiteralPath $Root -Recurse -File -Force |
            Where-Object {
                $_.FullName -notmatch '[\\/]\.git[\\/]' -and
                $_.FullName -ne $manifestPath
            } |
            ForEach-Object {
                $relative = [IO.Path]::GetRelativePath($Root, $_.FullName).Replace('\', '/')
                $hash = (Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash.ToLowerInvariant()
                "$hash  $relative"
            } |
            Sort-Object
    )
    [IO.File]::WriteAllText(
        $manifestPath,
        ($lines -join "`n") + "`n",
        [Text.UTF8Encoding]::new($false)
    )
}

function Assert-PublicRepository {
    $result = Invoke-Captured -FilePath (Get-GitHubCliExecutable) -Arguments @(
        'repo', 'view', $Repository, '--json', 'isPrivate,nameWithOwner,visibility,url'
    )
    $repo = $result.Stdout | ConvertFrom-Json
    if ($repo.isPrivate -ne $false -or
        $repo.visibility -ne 'PUBLIC' -or
        $repo.nameWithOwner -ne $Repository) {
        throw 'Refusing to publish to a repository that is not the expected public repository.'
    }
    return $repo
}

function Initialize-PublicRepository {
    $probe = Invoke-Captured -FilePath (Get-GitHubCliExecutable) -Arguments @(
        'repo', 'view', $Repository, '--json', 'isPrivate'
    ) -AllowFailure
    if ($probe.ExitCode -ne 0) {
        Invoke-Captured -FilePath (Get-GitHubCliExecutable) -Arguments @(
            'repo', 'create', $Repository, '--public',
            '--description', 'FlClashPlus public source and release channel',
            '--disable-issues', '--disable-wiki'
        ) | Out-Null
    }
    return Assert-PublicRepository
}

function Initialize-SourceMirror {
    if (Test-Path -LiteralPath $RepositoryStage) {
        if (-not (Test-Path -LiteralPath (Join-Path $RepositoryStage '.git'))) {
            throw 'Repository staging directory exists but is not a Git repository.'
        }
        $origin = Invoke-Captured -FilePath (Get-GitExecutable) `
            -WorkingDirectory $RepositoryStage `
            -Arguments @('remote', 'get-url', 'origin')
        $repositoryPattern = [regex]::Escape($Repository) + '(?:\.git)?$'
        if ($origin.Stdout.Trim() -notmatch $repositoryPattern) {
            throw 'Repository staging origin does not match the release repository.'
        }
        $status = Invoke-Captured -FilePath (Get-GitExecutable) `
            -WorkingDirectory $RepositoryStage `
            -Arguments @('status', '--porcelain=v1')
        if (-not [string]::IsNullOrWhiteSpace($status.Stdout)) {
            throw 'Repository staging directory contains uncommitted changes.'
        }
    }
    else {
        New-Item -ItemType Directory -Force -Path (Split-Path -Parent $RepositoryStage) |
            Out-Null
        Invoke-Captured -FilePath (Get-GitHubCliExecutable) -Arguments @(
            'repo', 'clone', $Repository, $RepositoryStage
        ) -WorkingDirectory $ReleaseRoot `
            -LogPath (Join-Path $LogsRoot 'github-clone.log') | Out-Null
    }

    $sourceDirectories = @(
        'android', 'arb', 'assets', 'core', 'lib', 'linux', 'macos', 'plugins',
        'services', 'test', 'windows', 'release-site'
    )
    foreach ($relative in $sourceDirectories) {
        $source = Join-Path $ProjectRoot $relative
        if (-not (Test-Path -LiteralPath $source)) {
            throw "Required source directory is missing: $relative"
        }
        Copy-SourceTree -Source $source -Destination (Join-Path $RepositoryStage $relative)
    }

    $rootFiles = @(
        '.gitignore', '.metadata', 'analysis_options.yaml', 'build.yaml',
        'build_config.yaml', 'CHANGELOG.md', 'LICENSE', 'NOTICE.md', 'pubspec.lock',
        'pubspec.yaml', 'README.md', 'README_zh_CN.md', 'setup.dart',
        'distribute_options.yaml'
    )
    foreach ($relative in $rootFiles) {
        $source = Join-Path $ProjectRoot $relative
        if (Test-Path -LiteralPath $source -PathType Leaf) {
            Copy-SourceTree -Source $source -Destination (Join-Path $RepositoryStage $relative)
        }
    }
    foreach ($relative in @(
            'command/Publish-FlClashPlusRelease.ps1',
            'command/Deploy-FlClashPlusSite.ps1',
            'command/gitpush.cmd'
        )) {
        $source = Join-Path $ProjectRoot $relative
        if (-not (Test-Path -LiteralPath $source -PathType Leaf)) {
            throw "Required release command is missing: $relative"
        }
        Copy-SourceTree -Source $source -Destination (Join-Path $RepositoryStage $relative)
    }

    @"
# FlClashPlus

Public source mirror and release channel for FlClashPlus.

- Release tag: $Tag
- Application version: $(Get-AppVersion)
- Release page: https://flclashplus.nkbr.cc/
- Source and release downloads are publicly accessible.
- License: GNU GPL v3.0; see `LICENSE` and `NOTICE.md`.

Machine-local Android signing material, `android/local.properties`, and Firebase
configuration are intentionally excluded. The vendored plugin working trees are
captured as ordinary source directories so this snapshot includes local changes.
"@ | Set-Content -LiteralPath (Join-Path $RepositoryStage 'RELEASE_CHANNEL.md') -Encoding utf8

    @"
.dart_tool/
build/
target/
.gradle/
.cxx/
node_modules/
android/local.properties
android/app/keystore.jks
android/app/google-services.json
env.json
core_sha256.json
"@ | Set-Content -LiteralPath (Join-Path $RepositoryStage '.gitignore') -Encoding utf8

    $checksumsPath = Join-Path $ArtifactsRoot 'SHA256SUMS'
    if (Test-Path -LiteralPath $checksumsPath -PathType Leaf) {
        Copy-Item -LiteralPath $checksumsPath `
            -Destination (Join-Path $RepositoryStage 'SHA256SUMS')
    }
    New-SourceManifest -Root $RepositoryStage
    Test-SensitiveStagingContent -Root $RepositoryStage
}

function Write-ReleaseNotes {
    $assetRows = Get-ReleaseAssets
    $lines = @(
        "# FlClashPlus $Version",
        '',
        'FlClashPlus 公开发布版本。',
        '',
        ('Application version: `{0}`' -f (Get-AppVersion)),
        '',
        '## Artifacts',
        ''
    )
    foreach ($asset in $assetRows) {
        $lines += ('- **{0}** — `{1}` — SHA-256 `{2}`' -f `
                $asset.label, $asset.fileName, $asset.sha256)
    }
    $lines += @(
        '',
        '## Notes',
        '',
        '- Android 使用 FlClashPlus 专用发布签名身份。',
        '- Windows 安装器未进行 Authenticode 签名，系统可能显示 SmartScreen 提示。',
        '- 安装前请使用 `SHA256SUMS` 核验下载文件。',
        '- 对应公开源码快照保存在同名 Release 标签。',
        '- 公共发布页不包含 GitHub 或 Cloudflare 凭据。'
    )
    $notesPath = Join-Path $ReleaseRoot 'release-notes.md'
    [IO.File]::WriteAllText(
        $notesPath,
        ($lines -join "`n") + "`n",
        [Text.UTF8Encoding]::new($false)
    )
    return $notesPath
}

function Push-SourceMirror {
    param(
        [Parameter(Mandatory)][string]$CommitMessage
    )

    Invoke-Captured -FilePath (Get-GitExecutable) -WorkingDirectory $RepositoryStage -Arguments @(
        'config', 'user.name', 'FlClashPlus Release Bot'
    ) | Out-Null
    Invoke-Captured -FilePath (Get-GitExecutable) -WorkingDirectory $RepositoryStage -Arguments @(
        'config', 'user.email', 'actions@users.noreply.github.com'
    ) | Out-Null
    Invoke-Captured -FilePath (Get-GitExecutable) -WorkingDirectory $RepositoryStage -Arguments @(
        'add', '--all'
    ) | Out-Null

    $diffCheck = Invoke-Captured -FilePath (Get-GitExecutable) -WorkingDirectory $RepositoryStage `
        -Arguments @(
            'diff', '--cached', '--check', '--',
            'README.md', 'README_zh_CN.md', 'NOTICE.md', 'RELEASE_CHANNEL.md',
            '.gitignore', 'command/Publish-FlClashPlusRelease.ps1',
            'command/Deploy-FlClashPlusSite.ps1', 'command/gitpush.cmd'
        ) -AllowFailure `
        -LogPath (Join-Path $LogsRoot 'source-mirror-diff-check.log')
    if ($diffCheck.ExitCode -ne 0) {
        throw 'Source mirror contains whitespace errors; see source-mirror-diff-check.log.'
    }

    $pending = Invoke-Captured -FilePath (Get-GitExecutable) -WorkingDirectory $RepositoryStage `
        -Arguments @('diff', '--cached', '--quiet') -AllowFailure
    if ($pending.ExitCode -eq 1) {
        Invoke-Captured -FilePath (Get-GitExecutable) -WorkingDirectory $RepositoryStage -Arguments @(
            'commit', '-m', $CommitMessage
        ) -LogPath (Join-Path $LogsRoot 'github-commit.log') | Out-Null
    }
    elseif ($pending.ExitCode -ne 0) {
        throw "Unable to inspect staged source changes; git exited $($pending.ExitCode)."
    }

    Invoke-Captured -FilePath (Get-GitExecutable) -WorkingDirectory $RepositoryStage -Arguments @(
        'push', '-u', 'origin', 'HEAD:main'
    ) -LogPath (Join-Path $LogsRoot 'github-push-main.log') | Out-Null

    $head = Invoke-Captured -FilePath (Get-GitExecutable) -WorkingDirectory $RepositoryStage -Arguments @(
        'rev-parse', 'HEAD'
    )
    return $head.Stdout.Trim()
}

function Invoke-SourceVerification {
    Initialize-ReleaseEnvironment
    $repo = Assert-PublicRepository

    $notice = Invoke-Captured -FilePath (Get-GitHubCliExecutable) -Arguments @(
        'api', "repos/$Repository/contents/NOTICE.md", '--silent'
    ) -AllowFailure
    if ($notice.ExitCode -ne 0) {
        throw 'Published repository is missing NOTICE.md.'
    }

    $metadata = $null
    $acceptedLicenses = @('GPL-3.0', 'GPL-3.0-only', 'GPL-3.0-or-later')
    foreach ($attempt in 1..15) {
        $metadataResult = Invoke-Captured -FilePath (Get-GitHubCliExecutable) -Arguments @(
            'api', "repos/$Repository", '--jq',
            '{fullName:.full_name,visibility:.visibility,private:.private,defaultBranch:.default_branch,license:.license.spdx_id,url:.html_url}'
        )
        $metadata = $metadataResult.Stdout | ConvertFrom-Json
        if ($metadata.defaultBranch -eq 'main' -and
            $metadata.visibility -eq 'public' -and
            $metadata.private -eq $false -and
            $metadata.license -in $acceptedLicenses) {
            break
        }
        Start-Sleep -Seconds 2
    }

    if ($metadata.defaultBranch -ne 'main') {
        throw "Unexpected default branch: $($metadata.defaultBranch)"
    }
    if ($metadata.visibility -ne 'public' -or $metadata.private -ne $false) {
        throw 'Repository readback did not confirm public visibility.'
    }
    if ($metadata.license -notin $acceptedLicenses) {
        throw "GitHub did not recognize the expected GPL-3.0 license: $($metadata.license)"
    }

    $commitResult = Invoke-Captured -FilePath (Get-GitHubCliExecutable) -Arguments @(
        'api', "repos/$Repository/commits/main", '--jq', '.sha'
    )
    return [ordered]@{
        result = 'source-verified'
        repository = $repo.nameWithOwner
        visibility = $metadata.visibility
        private = $metadata.private
        defaultBranch = $metadata.defaultBranch
        license = $metadata.license
        notice = $true
        commit = $commitResult.Stdout.Trim()
        url = $metadata.url
    }
}

function Invoke-SourcePublish {
    if (-not $Apply) {
        throw 'Source publishing requires the explicit -Apply switch.'
    }
    Initialize-ReleaseEnvironment
    [void](Initialize-PublicRepository)
    Initialize-SourceMirror
    [void](Push-SourceMirror -CommitMessage 'Publish FlClashPlus public source')
    return Invoke-SourceVerification
}

function Invoke-GitHubPublish {
    if (-not $Apply) {
        throw 'Publish requires the explicit -Apply switch.'
    }
    Initialize-ReleaseEnvironment
    Write-SiteManifest
    $notesPath = Write-ReleaseNotes
    [void](Initialize-PublicRepository)
    Initialize-SourceMirror
    [void](Push-SourceMirror -CommitMessage "FlClashPlus $Tag public release")

    Invoke-Captured -FilePath (Get-GitExecutable) -WorkingDirectory $RepositoryStage -Arguments @(
        'tag', '-a', $Tag, '-m', "FlClashPlus $Version"
    ) | Out-Null
    Invoke-Captured -FilePath (Get-GitExecutable) -WorkingDirectory $RepositoryStage -Arguments @(
        'push', 'origin', $Tag
    ) -LogPath (Join-Path $LogsRoot 'github-push-tag.log') | Out-Null

    $uploadPaths = @(
        Get-ChildItem -LiteralPath $ArtifactsRoot -File |
            Where-Object { $_.Name -ne 'artifact-manifest.json' } |
            Sort-Object Name |
            ForEach-Object FullName
    )
    $releaseArgs = @(
        'release', 'create', $Tag,
        '--repo', $Repository,
        '--verify-tag',
        '--draft',
        '--title', "FlClashPlus $Version",
        '--notes-file', $notesPath
    ) + $uploadPaths
    Invoke-Captured -FilePath (Get-GitHubCliExecutable) -Arguments $releaseArgs `
        -LogPath (Join-Path $LogsRoot 'github-release-create.log') | Out-Null

    $draftResult = Invoke-Captured -FilePath (Get-GitHubCliExecutable) -Arguments @(
        'release', 'view', $Tag, '--repo', $Repository,
        '--json', 'tagName,isDraft,isPrerelease,url,assets'
    )
    $draft = $draftResult.Stdout | ConvertFrom-Json
    if ($draft.isDraft -ne $true -or $draft.tagName -ne $Tag) {
        throw 'GitHub draft release readback failed.'
    }
    $expectedNames = @($uploadPaths | ForEach-Object { [IO.Path]::GetFileName($_) })
    $actualNames = @($draft.assets | ForEach-Object name)
    foreach ($expected in $expectedNames) {
        if ($expected -notin $actualNames) {
            throw "GitHub draft release is missing asset: $expected"
        }
    }

    Invoke-Captured -FilePath (Get-GitHubCliExecutable) -Arguments @(
        'release', 'edit', $Tag, '--repo', $Repository, '--draft=false'
    ) -LogPath (Join-Path $LogsRoot 'github-release-publish.log') | Out-Null
    return Invoke-ReleaseVerification
}

function Invoke-ReleaseVerification {
    Initialize-ReleaseEnvironment
    $repo = Assert-PublicRepository
    $releaseResult = Invoke-Captured -FilePath (Get-GitHubCliExecutable) -Arguments @(
        'release', 'view', $Tag, '--repo', $Repository,
        '--json', 'tagName,isDraft,isPrerelease,url,assets,publishedAt'
    )
    $release = $releaseResult.Stdout | ConvertFrom-Json
    if ($release.tagName -ne $Tag -or $release.isDraft -ne $false) {
        throw 'GitHub release is not published as expected.'
    }
    $localAssets = Get-ReleaseAssets
    $remoteNames = @($release.assets | ForEach-Object name)
    foreach ($asset in $localAssets) {
        if ($asset.fileName -notin $remoteNames) {
            throw "Published release is missing asset: $($asset.fileName)"
        }
    }
    return [ordered]@{
        result = 'verified'
        repository = $repo.nameWithOwner
        private = $repo.isPrivate
        tag = $release.tagName
        draft = $release.isDraft
        prerelease = $release.isPrerelease
        publishedAt = $release.publishedAt
        releaseUrl = $release.url
        assetCount = @($release.assets).Count
    }
}

function Remove-OwnedPath {
    param(
        [Parameter(Mandatory)][string]$Path,
        [Parameter(Mandatory)][string[]]$AllowedRoots
    )
    if (-not (Test-Path -LiteralPath $Path)) {
        return
    }
    $full = [IO.Path]::GetFullPath($Path)
    $allowed = $false
    foreach ($root in $AllowedRoots) {
        $rootFull = [IO.Path]::GetFullPath($root).TrimEnd('\', '/')
        if ($full.StartsWith(
                $rootFull + [IO.Path]::DirectorySeparatorChar,
                [StringComparison]::OrdinalIgnoreCase
            )) {
            $allowed = $true
            break
        }
    }
    if (-not $allowed) {
        throw "Cleanup path is outside the explicit roots: $full"
    }
    Remove-Item -LiteralPath $full -Recurse -Force
}

function Invoke-ReleaseCleanup {
    Initialize-ReleaseEnvironment
    $allowedRoots = @($ProjectRoot, $SdkRoot, $ReleaseRoot)
    Remove-OwnedPath -Path $TaskTempRoot -AllowedRoots $allowedRoots
    Remove-OwnedPath -Path $TaskCargoTarget -AllowedRoots $allowedRoots
    Remove-OwnedPath -Path $PackageOutputRoot -AllowedRoots $allowedRoots

    $baselinePath = Join-Path $BackupRoot 'build-path-baseline.json'
    $removed = [Collections.Generic.List[string]]::new()
    if (Test-Path -LiteralPath $baselinePath -PathType Leaf) {
        $baseline = Get-Content -LiteralPath $baselinePath -Raw | ConvertFrom-Json
        foreach ($record in $baseline.paths) {
            if ($record.existedBefore -eq $false -and (Test-Path -LiteralPath $record.path)) {
                Remove-OwnedPath -Path $record.path -AllowedRoots $allowedRoots
                $removed.Add([string]$record.path)
            }
        }
    }
    return [ordered]@{
        result = 'cleaned'
        removedBuildPaths = @($removed)
        preserved = @($ArtifactsRoot, $LogsRoot, $RepositoryStage, $BackupRoot)
    }
}

Initialize-ReleaseEnvironment

switch ($Action) {
    'Plan' {
        [ordered]@{
            action = 'Plan'
            tag = $Tag
            appVersion = Get-AppVersion
            repository = $Repository
            repositoryMustBePublic = $true
            license = 'GPL-3.0'
            releaseRoot = $ReleaseRoot
            artifacts = @(
                "FlClashPlus-$Version-android-arm64-v8a.apk",
                "FlClashPlus-$Version-windows-x64-setup.exe",
                "FlClashPlus-$Version-windows-x64-portable.zip",
                'SHA256SUMS'
            )
            externalWriteRequiresApply = $true
        } | ConvertTo-Json -Depth 8
    }
    'Build' {
        Invoke-ReleaseBuild
    }
    'Source' {
        Invoke-SourcePublish | ConvertTo-Json -Depth 8
    }
    'Publish' {
        Invoke-GitHubPublish
    }
    'Verify' {
        Invoke-ReleaseVerification | ConvertTo-Json -Depth 8
    }
    'Clean' {
        Invoke-ReleaseCleanup | ConvertTo-Json -Depth 8
    }
    'All' {
        if (-not $Apply) {
            throw 'All requires the explicit -Apply switch.'
        }
        Invoke-ReleaseBuild | Out-Host
        Invoke-GitHubPublish | ConvertTo-Json -Depth 8
    }
}
