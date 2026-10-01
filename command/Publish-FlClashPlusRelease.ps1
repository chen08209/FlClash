1 | #requires -Version 7.0
2 | [CmdletBinding()]
3 | param(
4 |     [ValidateSet('Plan', 'Build', 'Source', 'Publish', 'Verify', 'Clean', 'All')]
5 |     [string]$Action = 'Plan',
6 | 
7 |     [ValidatePattern('^v[0-9]+\.[0-9]+\.[0-9]+(?:-[0-9A-Za-z][0-9A-Za-z.-]*)?$')]
8 |     [string]$Tag = 'v0.8.93-plus.1',
9 | 
10 |     [ValidatePattern('^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$')]
11 |     [string]$Repository = 'nekobyran/flclashplus',
12 | 
13 |     [switch]$Apply
14 | )
15 | 
16 | Set-StrictMode -Version Latest
17 | $ErrorActionPreference = 'Stop'
18 | 
19 | $ProjectRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
20 | $Version = $Tag.Substring(1)
21 | $ReleaseRoot = [IO.Path]::GetFullPath(
22 |     (Join-Path $ProjectRoot "release/flclashplus_publish/$Tag")
23 | )
24 | $ArtifactsRoot = Join-Path $ReleaseRoot 'artifacts'
25 | $LogsRoot = Join-Path $ReleaseRoot 'logs'
26 | $PackageOutputRoot = Join-Path $ReleaseRoot 'package-output'
27 | $RepositoryStage = Join-Path $ReleaseRoot 'repository'
28 | $BackupRoot = Join-Path $ReleaseRoot 'backup-manifest'
29 | $SiteRoot = Join-Path $ProjectRoot 'release-site'
30 | $SdkRoot = [IO.Path]::GetFullPath('D:\vibecoding\sdk')
31 | $TaskTempRoot = Join-Path $SdkRoot "cache/temp/flclashplus-release-$Version"
32 | $TaskCargoTarget = Join-Path $SdkRoot "cargo-target/flclashplus-release-$Version"
33 | $SigningRoot = Join-Path $SdkRoot 'signing'
34 | $SigningKeyStore = Join-Path $SigningRoot 'flclashplus-release.jks'
35 | $SigningCredential = Join-Path $SigningRoot 'flclashplus-release.credential.dpapi'
36 | $SigningAlias = 'flclashplus'
37 | $ExpectedAndroidPackage = 'cc.nkbr.flclashplusplus'
38 | $GitExecutable = $null
39 | $GhExecutable = $null
40 | 
41 | function Get-GitExecutable {
42 |     if (-not [string]::IsNullOrWhiteSpace($script:GitExecutable)) {
43 |         return $script:GitExecutable
44 |     }
45 | 
46 |     $candidates = @()
47 |     $programFiles = [Environment]::GetFolderPath(
48 |         [Environment+SpecialFolder]::ProgramFiles
49 |     )
50 |     if (-not [string]::IsNullOrWhiteSpace($programFiles)) {
51 |         $candidates += @(
52 |             (Join-Path $programFiles 'Git\cmd\git.exe'),
53 |             (Join-Path $programFiles 'Git\bin\git.exe')
54 |         )
55 |     }
56 |     $localAppData = [Environment]::GetFolderPath('LocalApplicationData')
57 |     if (-not [string]::IsNullOrWhiteSpace($localAppData)) {
58 |         $candidates += (Join-Path $localAppData 'Programs\Git\cmd\git.exe')
59 |     }
60 |     $command = Get-Command git -ErrorAction SilentlyContinue
61 |     if ($null -ne $command) {
62 |         $candidates += $command.Source
63 |     }
64 | 
65 |     $resolved = @(
66 |         $candidates |
67 |             Where-Object { -not [string]::IsNullOrWhiteSpace($_) } |
68 |             Where-Object { Test-Path -LiteralPath $_ -PathType Leaf } |
69 |             Select-Object -First 1
70 |     )
71 |     if ($resolved.Count -ne 1) {
72 |         throw 'Git for Windows was not found.'
73 |     }
74 | 
75 |     $script:GitExecutable = [IO.Path]::GetFullPath($resolved[0])
76 |     $gitDirectory = Split-Path -Parent $script:GitExecutable
77 |     $pathEntries = @($env:PATH -split ';')
78 |     if ($gitDirectory -notin $pathEntries) {
79 |         $env:PATH = $gitDirectory + ';' + $env:PATH
80 |     }
81 |     $pathExtensions = @($env:PATHEXT -split ';')
82 |     if ('.EXE' -notin $pathExtensions) {
83 |         $env:PATHEXT = '.COM;.EXE;.BAT;.CMD;.VBS;.VBE;.JS;.JSE;.WSF;.WSH;.MSC;.CPL'
84 |     }
85 |     if ([string]::IsNullOrWhiteSpace($env:ComSpec)) {
86 |         $env:ComSpec = Join-Path $env:SystemRoot 'System32\cmd.exe'
87 |     }
88 |     return $script:GitExecutable
89 | }
90 | 
91 | function Get-GitHubCliExecutable {
92 |     [void](Get-GitExecutable)
93 |     if (-not [string]::IsNullOrWhiteSpace($script:GhExecutable)) {
94 |         return $script:GhExecutable
95 |     }
96 | 
97 |     if ([string]::IsNullOrWhiteSpace($env:GH_CONFIG_DIR)) {
98 |         $roaming = [Environment]::GetFolderPath('ApplicationData')
99 |         if (-not [string]::IsNullOrWhiteSpace($roaming)) {
100 |             $configDir = Join-Path $roaming 'GitHub CLI'
101 |             if (Test-Path -LiteralPath (Join-Path $configDir 'hosts.yml') -PathType Leaf) {
102 |                 $env:GH_CONFIG_DIR = $configDir
103 |             }
104 |         }
105 |     }
106 | 
107 |     $command = Get-Command gh -ErrorAction SilentlyContinue
108 |     if ($null -ne $command) {
109 |         $script:GhExecutable = $command.Source
110 |         return $script:GhExecutable
111 |     }
112 | 
113 |     $localAppData = [Environment]::GetFolderPath('LocalApplicationData')
114 |     if (-not [string]::IsNullOrWhiteSpace($localAppData)) {
115 |         $packageRoot = Join-Path $localAppData 'Microsoft\WinGet\Packages'
116 |         $candidate = @(
117 |             Get-Item -Path (Join-Path $packageRoot 'GitHub.cli_*\bin\gh.exe') `
118 |                 -ErrorAction SilentlyContinue |
119 |                 Sort-Object FullName |
120 |                 Select-Object -First 1
121 |         )
122 |         if ($candidate.Count -eq 1) {
123 |             $script:GhExecutable = $candidate[0].FullName
124 |             return $script:GhExecutable
125 |         }
126 |     }
127 | 
128 |     throw 'GitHub CLI was not found. Install GitHub CLI or add gh to PATH.'
129 | }
130 | 
131 | function Assert-DescendantPath {
132 |     param(
133 |         [Parameter(Mandatory)][string]$Parent,
134 |         [Parameter(Mandatory)][string]$Child,
135 |         [switch]$AllowEqual
136 |     )
137 | 
138 |     $parentFull = [IO.Path]::GetFullPath($Parent).TrimEnd('\', '/')
139 |     $childFull = [IO.Path]::GetFullPath($Child).TrimEnd('\', '/')
140 |     if ($AllowEqual -and $childFull.Equals(
141 |             $parentFull,
142 |             [StringComparison]::OrdinalIgnoreCase
143 |         )) {
144 |         return $childFull
145 |     }
146 |     $prefix = $parentFull + [IO.Path]::DirectorySeparatorChar
147 |     if (-not $childFull.StartsWith($prefix, [StringComparison]::OrdinalIgnoreCase)) {
148 |         throw "Path escaped its allowed root: $childFull"
149 |     }
150 |     return $childFull
151 | }
152 | 
153 | function Invoke-Captured {
154 |     param(
155 |         [Parameter(Mandatory)][string]$FilePath,
156 |         [Parameter(Mandatory)][string[]]$Arguments,
157 |         [string]$WorkingDirectory = $ProjectRoot,
158 |         [string]$LogPath,
159 |         [switch]$AllowFailure
160 |     )
161 | 
162 |     $startInfo = [Diagnostics.ProcessStartInfo]::new()
163 |     $startInfo.FileName = $FilePath
164 |     $startInfo.WorkingDirectory = $WorkingDirectory
165 |     $startInfo.UseShellExecute = $false
166 |     $startInfo.CreateNoWindow = $true
167 |     $startInfo.RedirectStandardOutput = $true
168 |     $startInfo.RedirectStandardError = $true
169 |     foreach ($argument in $Arguments) {
170 |         [void]$startInfo.ArgumentList.Add([string]$argument)
171 |     }
172 | 
173 |     $process = [Diagnostics.Process]::new()
174 |     $process.StartInfo = $startInfo
175 |     try {
176 |         if (-not $process.Start()) {
177 |             throw "Failed to start $FilePath"
178 |         }
179 |         $stdoutTask = $process.StandardOutput.ReadToEndAsync()
180 |         $stderrTask = $process.StandardError.ReadToEndAsync()
181 |         $process.WaitForExit()
182 |         $stdout = $stdoutTask.GetAwaiter().GetResult()
183 |         $stderr = $stderrTask.GetAwaiter().GetResult()
184 |         $combined = @($stdout, $stderr) -join ''
185 |         if (-not [string]::IsNullOrWhiteSpace($LogPath)) {
186 |             $logFull = Assert-DescendantPath -Parent $ReleaseRoot -Child $LogPath
187 |             New-Item -ItemType Directory -Force -Path (Split-Path -Parent $logFull) |
188 |                 Out-Null
189 |             [IO.File]::WriteAllText($logFull, $combined, [Text.UTF8Encoding]::new($false))
190 |         }
191 |         if ($process.ExitCode -ne 0 -and -not $AllowFailure) {
192 |             $tail = @($combined -split '\r?\n' | Where-Object { $_ }) |
193 |                 Select-Object -Last 30
194 |             throw "$FilePath failed with exit code $($process.ExitCode).`n$($tail -join "`n")"
195 |         }
196 |         return [pscustomobject]@{
197 |             ExitCode = $process.ExitCode
198 |             Stdout = $stdout
199 |             Stderr = $stderr
200 |             Output = $combined
201 |         }
202 |     }
203 |     finally {
204 |         $process.Dispose()
205 |     }
206 | }
207 | 
208 | function Initialize-ReleaseEnvironment {
209 |     New-Item -ItemType Directory -Force -Path @(
210 |         $ReleaseRoot,
211 |         $ArtifactsRoot,
212 |         $LogsRoot,
213 |         $BackupRoot,
214 |         $TaskTempRoot,
215 |         $TaskCargoTarget
216 |     ) | Out-Null
217 | 
218 |     $env:TEMP = $TaskTempRoot
219 |     $env:TMP = $TaskTempRoot
220 |     $env:PUB_CACHE = Join-Path $SdkRoot 'pub-cache'
221 |     $env:ProgramData = 'C:\ProgramData'
222 |     $env:SystemDrive = 'C:'
223 |     $env:HOMEDRIVE = 'C:'
224 |     $env:HOMEPATH = '\Users\Administrator'
225 |     $env:PUBLIC = 'C:\Users\Public'
226 |     $env:ProgramW6432 = 'C:\Program Files'
227 |     $env:ALLUSERSPROFILE = $env:ProgramData
228 |     $env:CommonProgramFiles = 'C:\Program Files\Common Files'
229 |     ${env:CommonProgramFiles(x86)} = 'C:\Program Files (x86)\Common Files'
230 |     $env:CommonProgramW6432 = 'C:\Program Files\Common Files'
231 |     $env:GRADLE_USER_HOME = Join-Path $SdkRoot 'gradle-user-home'
232 |     $env:CARGO_HOME = Join-Path $SdkRoot 'cargo-home'
233 |     $env:RUSTUP_HOME = Join-Path $SdkRoot 'rust\rustup'
234 |     $env:RUSTUP_TOOLCHAIN = 'stable'
235 |     $env:CARGO_TARGET_DIR = $TaskCargoTarget
236 |     $rustToolchainBin = Join-Path $SdkRoot 'rust\rustup\toolchains\stable-x86_64-pc-windows-msvc\bin'
237 |     $rustupShimBin = Join-Path $TaskTempRoot '.cargo\bin'
238 |     New-Item -ItemType Directory -Force -Path $rustupShimBin | Out-Null
239 |     Copy-Item -LiteralPath (Join-Path $SdkRoot 'rust-gamelaucher\cargo\bin\rustup.exe') `
240 |         -Destination (Join-Path $rustupShimBin 'rustup.exe') -Force
241 |     $env:RUSTC = Join-Path $rustToolchainBin 'rustc.exe'
242 |     $env:RUSTDOC = Join-Path $rustToolchainBin 'rustdoc.exe'
243 |     $env:PATH = "$rustupShimBin;$rustToolchainBin;$env:PATH"
244 |     $env:GOCACHE = Join-Path $TaskTempRoot 'go-build'
245 |     $env:GOMODCACHE = Join-Path $SdkRoot 'go/pkg/mod'
246 |     $env:ANDROID_HOME = Join-Path $SdkRoot 'android'
247 |     $env:ANDROID_SDK_ROOT = $env:ANDROID_HOME
248 |     $ndkVersionFile = Join-Path $ProjectRoot 'android\gradle\libs.versions.toml'
249 |     $ndkVersionText = [IO.File]::ReadAllText($ndkVersionFile)
250 |     $ndkVersionMatch = [regex]::Match($ndkVersionText, '(?m)^ndkVersion\s*=\s*"(?<version>[^\"]+)"')
251 |     if (-not $ndkVersionMatch.Success) { throw 'Android NDK version is missing from libs.versions.toml.' }
252 |     $env:ANDROID_NDK = Join-Path $env:ANDROID_HOME ("ndk\" + $ndkVersionMatch.Groups['version'].Value)
253 |     if (-not (Test-Path -LiteralPath $env:ANDROID_NDK -PathType Container)) { throw "Configured Android NDK is missing: $env:ANDROID_NDK" }
254 |     $env:JAVA_HOME = Join-Path $SdkRoot 'jdk'
255 |     $env:INNO_SETUP_PATH = Join-Path $SdkRoot 'inno-setup-6'
256 | }
257 | 
258 | function Initialize-PortableWindowsToolchain {
259 |     $visualStudioCandidates = @(
260 |         (Join-Path $SdkRoot 'visual-studio-build-tools-vs2022'),
261 |         (Join-Path $SdkRoot 'visual-studio-build-tools')
262 |     )
263 |     $visualStudioRoot = $visualStudioCandidates |
264 |         Where-Object {
265 |             Test-Path -LiteralPath (Join-Path $_ 'VC\Tools\MSVC') -PathType Container
266 |         } |
267 |         Where-Object {
268 |             @(
269 |                 Get-ChildItem -LiteralPath (Join-Path $_ 'VC\Tools\MSVC') -Directory |
270 |                     Where-Object {
271 |                         Test-Path -LiteralPath (Join-Path $_.FullName 'bin\Hostx64\x64\cl.exe') -PathType Leaf
272 |                     }
273 |             ).Count -gt 0
274 |         } |
275 |         Select-Object -First 1
276 |     if ([string]::IsNullOrWhiteSpace($visualStudioRoot)) {
277 |         throw 'The portable Visual Studio C++ toolchain is incomplete.'
278 |     }
279 |     $windowsSdkRoot = Join-Path $SdkRoot 'windows-sdk'
280 |     $programFilesX86 = Join-Path $SdkRoot 'program-files-x86'
281 | 
282 |     $msvc = Get-ChildItem -LiteralPath (Join-Path $visualStudioRoot 'VC\Tools\MSVC') -Directory |
283 |         Sort-Object { [version]$_.Name } -Descending |
284 |         Where-Object {
285 |             Test-Path -LiteralPath (Join-Path $_.FullName 'bin\Hostx64\x64\cl.exe') -PathType Leaf
286 |         } |
287 |         Select-Object -First 1
288 |     $windowsSdk = Get-ChildItem -LiteralPath (Join-Path $windowsSdkRoot 'Include') -Directory |
289 |         Sort-Object { [version]$_.Name } -Descending |
290 |         Where-Object {
291 |             Test-Path -LiteralPath (Join-Path $windowsSdkRoot "Lib\$($_.Name)\um\x64\kernel32.lib") -PathType Leaf
292 |         } |
293 |         Select-Object -First 1
294 |     if ($null -eq $msvc -or $null -eq $windowsSdk) {
295 |         throw 'The portable Windows C++ toolchain is incomplete.'
296 |     }
297 | 
298 |     $msbuild = Join-Path $visualStudioRoot 'MSBuild\Current\Bin\MSBuild.exe'
299 |     $cmakeBin = Join-Path $visualStudioRoot 'Common7\IDE\CommonExtensions\Microsoft\CMake\CMake\bin'
300 |     $ninjaBin = Join-Path $visualStudioRoot 'Common7\IDE\CommonExtensions\Microsoft\CMake\Ninja'
301 |     $nugetBin = Join-Path $SdkRoot 'nuget'
302 |     $vswhere = Join-Path $programFilesX86 'Microsoft Visual Studio\Installer\vswhere.exe'
303 |     foreach ($required in @($msbuild, (Join-Path $cmakeBin 'cmake.exe'), (Join-Path $ninjaBin 'ninja.exe'), (Join-Path $nugetBin 'nuget.exe'), $vswhere)) {
304 |         if (-not (Test-Path -LiteralPath $required -PathType Leaf)) {
305 |             throw "Portable Windows build tool is missing: $required"
306 |         }
307 |     }
308 | 
309 |     $vcvars64 = Join-Path $visualStudioRoot 'VC\Auxiliary\Build\vcvars64.bat'
310 |     if (-not (Test-Path -LiteralPath $vcvars64 -PathType Leaf)) {
311 |         throw "Portable Visual Studio environment script is missing: $vcvars64"
312 |     }
313 |     $vcvarsEnvironment = & $env:ComSpec /d /s /c "call `"$vcvars64`" >nul && set"
314 |     if ($LASTEXITCODE -ne 0) {
315 |         throw 'Portable Visual Studio environment initialization failed.'
316 |     }
317 |     foreach ($line in $vcvarsEnvironment) {
318 |         $separator = $line.IndexOf('=')
319 |         if ($separator -gt 0) {
320 |             [Environment]::SetEnvironmentVariable(
321 |                 $line.Substring(0, $separator),
322 |                 $line.Substring($separator + 1),
323 |                 'Process'
324 |             )
325 |         }
326 |     }
327 |     $msvcRoot = $msvc.FullName
328 |     $msvcBin = Join-Path $msvcRoot 'bin\Hostx64\x64'
329 |     $sdkVersion = $windowsSdk.Name
330 |     $sdkBin = Join-Path $windowsSdkRoot "bin\$sdkVersion\x64"
331 |     $sdkIncludes = @('ucrt', 'shared', 'um', 'winrt', 'cppwinrt') |
332 |         ForEach-Object { Join-Path $windowsSdkRoot "Include\$sdkVersion\$_" } |
333 |         Where-Object { Test-Path -LiteralPath $_ -PathType Container }
334 | 
335 |     ${env:ProgramFiles(x86)} = $programFilesX86
336 |     $env:VSINSTALLDIR = "$visualStudioRoot\"
337 |     $env:VCINSTALLDIR = "$(Join-Path $visualStudioRoot 'VC')\"
338 |     $env:VisualStudioVersion = '17.0'
339 |     $env:NEKOSTAR_VS_BUILD_VERSION = (Get-Item -LiteralPath $msbuild).VersionInfo.FileVersion
340 |     $env:VCToolsInstallDir = "$msvcRoot\"
341 |     $env:VCToolsVersion = $msvc.Name
342 |     $env:WindowsSdkDir = "$windowsSdkRoot\"
343 |     $env:WindowsSDKVersion = "$sdkVersion\"
344 |     $env:WindowsTargetPlatformVersion = $sdkVersion
345 |     $env:UniversalCRTSdkDir = "$windowsSdkRoot\"
346 |     $env:UCRTVersion = $sdkVersion
347 |     $env:CC = Join-Path $msvcBin 'cl.exe'
348 |     $env:CXX = $env:CC
349 |     $env:RC = Join-Path $sdkBin 'rc.exe'
350 |     $env:INCLUDE = (@((Join-Path $msvcRoot 'include')) + $sdkIncludes) -join ';'
351 |     $env:LIB = @(
352 |         (Join-Path $msvcRoot 'lib\x64'),
353 |         (Join-Path $windowsSdkRoot "Lib\$sdkVersion\ucrt\x64"),
354 |         (Join-Path $windowsSdkRoot "Lib\$sdkVersion\um\x64")
355 |     ) -join ';'
356 |     $env:CMAKE_GENERATOR = 'Visual Studio 17 2022'
357 |     $env:CMAKE_GENERATOR_INSTANCE = "$visualStudioRoot,version=$($env:NEKOSTAR_VS_BUILD_VERSION)"
358 |     $env:CMAKE_SYSTEM_VERSION = $sdkVersion
359 |     $env:PATH = @(
360 |         $msvcBin,
361 |         $sdkBin,
362 |         (Join-Path $visualStudioRoot 'MSBuild\Current\Bin'),
363 |         $cmakeBin,
364 |         $ninjaBin,
365 |         $nugetBin,
366 |         $env:PATH
367 |     ) -join ';'
368 | 
369 |     $probe = Invoke-Captured -FilePath $vswhere -Arguments @(
370 |         '-format', 'json', '-products', '*', '-utf8', '-latest'
371 |     )
372 |     if ($probe.Stdout -notmatch 'portable-vs-build-tools') {
373 |         throw 'Portable Visual Studio discovery probe failed.'
374 |     }
375 | }
376 | 
377 | function Assert-DiskBudget {
378 |     $cDrive = Get-PSDrive -Name C -ErrorAction Stop
379 |     $dDrive = Get-PSDrive -Name D -ErrorAction Stop
380 |     $cFree = [math]::Round($cDrive.Free / 1GB, 2)
381 |     $dFree = [math]::Round($dDrive.Free / 1GB, 2)
382 |     if ($cFree -lt 16) {
383 |         throw "C drive free space is below 16 GiB ($cFree GiB)."
384 |     }
385 |         if ($dFree -lt 50) {
386 |         throw "D drive free space is below 50 GiB ($dFree GiB)."
387 |     }
388 | 
389 |     return [pscustomobject]@{ CFreeGiB = $cFree; DFreeGiB = $dFree }
390 | }
391 | 
392 | function Get-AppVersion {
393 |     $pubspec = Get-Content -LiteralPath (Join-Path $ProjectRoot 'pubspec.yaml') -Raw
394 |     $match = [regex]::Match($pubspec, '(?m)^version:\s*([^\s]+)\s*$')
395 |     if (-not $match.Success) {
396 |         throw 'Unable to read pubspec version.'
397 |     }
398 |     return $match.Groups[1].Value
399 | }
400 | 
401 | function Write-ProvenanceBackup {
402 |     New-Item -ItemType Directory -Force -Path $BackupRoot | Out-Null
403 |     $status = Invoke-Captured -FilePath (Get-GitExecutable) -Arguments @(
404 |         'status', '--porcelain=v1', '-uall'
405 |     ) -AllowFailure
406 |     [IO.File]::WriteAllText(
407 |         (Join-Path $BackupRoot 'git-status-before.txt'),
408 |         $status.Output,
409 |         [Text.UTF8Encoding]::new($false)
410 |     )
411 | 
412 |     $head = Invoke-Captured -FilePath (Get-GitExecutable) -Arguments @('rev-parse', 'HEAD')
413 |     [IO.File]::WriteAllText(
414 |         (Join-Path $BackupRoot 'base-commit.txt'),
415 |         $head.Stdout.Trim() + "`n",
416 |         [Text.UTF8Encoding]::new($false)
417 |     )
418 | 
419 |     $diff = Invoke-Captured -FilePath (Get-GitExecutable) -Arguments @(
420 |         'diff', '--binary', '--no-ext-diff', 'HEAD'
421 |     ) -AllowFailure
422 |     $superPatch = Join-Path $BackupRoot 'superproject-working.patch'
423 |     [IO.File]::WriteAllText(
424 |         $superPatch,
425 |         $diff.Output,
426 |         [Text.UTF8Encoding]::new($false)
427 |     )
428 | 
429 |     $nestedPatch = Join-Path $BackupRoot 'flutter-distributor-working.patch'
430 |     $nestedRoot = Join-Path $ProjectRoot 'plugins/flutter_distributor'
431 |     if (Test-Path -LiteralPath (Join-Path $nestedRoot '.git')) {
432 |         $nested = Invoke-Captured -FilePath (Get-GitExecutable) -WorkingDirectory $nestedRoot `
433 |             -Arguments @('diff', '--binary', '--no-ext-diff', 'HEAD') -AllowFailure
434 |         [IO.File]::WriteAllText(
435 |             $nestedPatch,
436 |             $nested.Output,
437 |             [Text.UTF8Encoding]::new($false)
438 |         )
439 |     }
440 |     else {
441 |         [IO.File]::WriteAllText(
442 |             $nestedPatch,
443 |             '',
444 |             [Text.UTF8Encoding]::new($false)
445 |         )
446 |     }
447 | 
448 |     $records = @(
449 |         foreach ($path in @(
450 |                 (Join-Path $BackupRoot 'git-status-before.txt'),
451 |                 (Join-Path $BackupRoot 'base-commit.txt'),
452 |                 $superPatch,
453 |                 $nestedPatch
454 |             )) {
455 |             $item = Get-Item -LiteralPath $path
456 |             [ordered]@{
457 |                                 file = $item.Name
458 |                 sizeBytes = $item.Length
459 | 
460 | 
461 |             }
462 |         }
463 |     )
464 |     [ordered]@{
465 |         schemaVersion = 1
466 |         capturedAt = [DateTimeOffset]::UtcNow.ToString('o')
467 |         tag = $Tag
468 |         appVersion = Get-AppVersion
469 |         files = $records
470 |     } | ConvertTo-Json -Depth 8 |
471 |         Set-Content -LiteralPath (Join-Path $BackupRoot 'provenance.json') -Encoding utf8
472 | }
473 | 
474 | function New-RandomPassword {
475 |     $bytes = [byte[]]::new(36)
476 |     [Security.Cryptography.RandomNumberGenerator]::Fill($bytes)
477 |     return [Convert]::ToBase64String($bytes).TrimEnd('=').Replace('+', 'A').Replace('/', 'B')
478 | }
479 | 
480 | function Protect-SigningCredential {
481 |     param(
482 |         [Parameter(Mandatory)][string]$Password
483 |     )
484 | 
485 |     $payload = [ordered]@{
486 |         schemaVersion = 1
487 |         alias = $SigningAlias
488 |         storePassword = $Password
489 |         keyPassword = $Password
490 |     } | ConvertTo-Json -Compress
491 |     $secure = ConvertTo-SecureString -String $payload -AsPlainText -Force
492 |     try {
493 |         ConvertFrom-SecureString -SecureString $secure |
494 |             Set-Content -LiteralPath $SigningCredential -Encoding ascii
495 |     }
496 |     finally {
497 |         $secure.Dispose()
498 |         $payload = $null
499 |     }
500 | }
501 | 
502 | function New-AndroidSigningIdentity {
503 |     New-Item -ItemType Directory -Force -Path $SigningRoot | Out-Null
504 |     $keyExists = Test-Path -LiteralPath $SigningKeyStore -PathType Leaf
505 |     $credentialExists = Test-Path -LiteralPath $SigningCredential -PathType Leaf
506 |     if ($keyExists -xor $credentialExists) {
507 |         throw 'Android signing identity is incomplete; refusing to replace it.'
508 |     }
509 |     if ($keyExists -and $credentialExists) {
510 |         return
511 |     }
512 | 
513 |     $keytool = Join-Path $env:JAVA_HOME 'bin/keytool.exe'
514 |     if (-not (Test-Path -LiteralPath $keytool -PathType Leaf)) {
515 |         throw 'keytool.exe was not found in the D drive JDK.'
516 |     }
517 | 
518 |     $password = New-RandomPassword
519 |     try {
520 |         Invoke-Captured -FilePath $keytool -Arguments @(
521 |             '-genkeypair',
522 |             '-keystore', $SigningKeyStore,
523 |             '-storepass', $password,
524 |             '-keypass', $password,
525 |             '-alias', $SigningAlias,
526 |             '-keyalg', 'RSA',
527 |             '-keysize', '4096',
528 |             '-validity', '10000',
529 |             '-dname', 'CN=FlClashPlus Public Release,OU=Release,O=Nekobyran,L=Singapore,ST=Singapore,C=SG'
530 |         ) -LogPath (Join-Path $LogsRoot 'android-signing-key-create.log') | Out-Null
531 |         Protect-SigningCredential -Password $password
532 |     }
533 |     catch {
534 |         if (Test-Path -LiteralPath $SigningKeyStore) {
535 |             Remove-Item -LiteralPath $SigningKeyStore -Force
536 |         }
537 |         if (Test-Path -LiteralPath $SigningCredential) {
538 |             Remove-Item -LiteralPath $SigningCredential -Force
539 |         }
540 |         throw
541 |     }
542 |     finally {
543 |         $password = $null
544 |     }
545 | }
546 | 
547 | function Read-SigningCredential {
548 |     $protected = Get-Content -LiteralPath $SigningCredential -Raw -Encoding ascii
549 |     $secure = ConvertTo-SecureString -String $protected.Trim()
550 |     $bstr = [IntPtr]::Zero
551 |     try {
552 |         $bstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure)
553 |         $json = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr)
554 |         $value = $json | ConvertFrom-Json
555 |         if (
556 |             $value.schemaVersion -ne 1 -or
557 |             $value.alias -ne $SigningAlias -or
558 |             [string]::IsNullOrWhiteSpace($value.storePassword) -or
559 |             [string]::IsNullOrWhiteSpace($value.keyPassword)
560 |         ) {
561 |             throw 'Android signing credential is invalid.'
562 |         }
563 |         return $value
564 |     }
565 |     finally {
566 |         if ($bstr -ne [IntPtr]::Zero) {
567 |             [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr)
568 |         }
569 |         $secure.Dispose()
570 |         $protected = $null
571 |         $json = $null
572 |     }
573 | }
574 | 
575 | function Save-FileState {
576 |     param([Parameter(Mandatory)][string]$Path)
577 |     if (Test-Path -LiteralPath $Path -PathType Leaf) {
578 |         return [pscustomobject]@{
579 |             Path = $Path
580 |             Existed = $true
581 |             Bytes = [IO.File]::ReadAllBytes($Path)
582 |         }
583 |     }
584 |     return [pscustomobject]@{ Path = $Path; Existed = $false; Bytes = $null }
585 | }
586 | 
587 | function Restore-FileState {
588 |     param([Parameter(Mandatory)][pscustomobject]$State)
589 |     if ($State.Existed) {
590 |         [IO.File]::WriteAllBytes($State.Path, [byte[]]$State.Bytes)
591 |     }
592 |     elseif (Test-Path -LiteralPath $State.Path -PathType Leaf) {
593 |         Remove-Item -LiteralPath $State.Path -Force
594 |     }
595 | }
596 | 
597 | function Get-LatestBuildTool {
598 |     param([Parameter(Mandatory)][string]$Name)
599 |     $root = Join-Path $env:ANDROID_SDK_ROOT 'build-tools'
600 |     $candidates = @(
601 |         Get-ChildItem -LiteralPath $root -Directory -ErrorAction Stop |
602 |             ForEach-Object {
603 |                 $tool = Join-Path $_.FullName $Name
604 |                 if (Test-Path -LiteralPath $tool -PathType Leaf) {
605 |                     $version = $null
606 |                     if ([version]::TryParse($_.Name, [ref]$version)) {
607 |                         [pscustomobject]@{ Path = $tool; Version = $version }
608 |                     }
609 |                 }
610 |             }
611 |     )
612 |     $selected = $candidates | Sort-Object Version -Descending | Select-Object -First 1
613 |     if ($null -eq $selected) {
614 |         throw "Android build tool was not found: $Name"
615 |     }
616 |     return $selected.Path
617 | }
618 | 
619 | function Test-AndroidArtifact {
620 |     param([Parameter(Mandatory)][string]$ApkPath)
621 | 
622 |     $aapt = Get-LatestBuildTool -Name 'aapt.exe'
623 |     $apksigner = Get-LatestBuildTool -Name 'apksigner.bat'
624 |     $badging = Invoke-Captured -FilePath $aapt -Arguments @(
625 |         'dump', 'badging', $ApkPath
626 |     ) -LogPath (Join-Path $LogsRoot 'android-aapt-badging.log')
627 |     if ($badging.Output -notmatch "package: name='$([regex]::Escape($ExpectedAndroidPackage))'") {
628 |         throw 'Android package name does not match the release contract.'
629 |     }
630 |     if ($badging.Output -notmatch "native-code:.*'arm64-v8a'") {
631 |         throw 'Android artifact does not contain the arm64-v8a ABI.'
632 |     }
633 | 
634 |     $signature = Invoke-Captured -FilePath $apksigner -Arguments @(
635 |         'verify', '--verbose', '--print-certs', $ApkPath
636 |     ) -LogPath (Join-Path $LogsRoot 'android-apksigner-verify.log')
637 |     if ($signature.Output -notmatch 'Verified using v[23] scheme.*true') {
638 |         throw 'Android APK signature verification did not report a valid modern scheme.'
639 |     }
640 | }
641 | 
642 | function Test-WindowsZipArtifact {
643 |     param([Parameter(Mandatory)][string]$ZipPath)
644 | 
645 |     Add-Type -AssemblyName System.IO.Compression
646 |     $archive = [IO.Compression.ZipFile]::OpenRead($ZipPath)
647 |     try {
648 |         $names = @($archive.Entries | ForEach-Object FullName)
649 |         if (-not ($names | Where-Object { $_ -match '(^|/)flclashplusplus\.exe$' })) {
650 |             throw 'Windows portable ZIP is missing flclashplusplus.exe.'
651 |         }
652 |         if (-not ($names | Where-Object { $_ -match '(^|/)flutter_windows\.dll$' })) {
653 |             throw 'Windows portable ZIP is missing flutter_windows.dll.'
654 |         }
655 |         $names | Sort-Object |
656 |             Set-Content -LiteralPath (Join-Path $LogsRoot 'windows-zip-entries.txt') -Encoding utf8
657 |     }
658 |     finally {
659 |         $archive.Dispose()
660 |     }
661 | }
662 | 
663 | function Get-ReleaseAssets {
664 |     $files = @(
665 |         Get-ChildItem -LiteralPath $ArtifactsRoot -File |
666 |             Where-Object { $_.Extension -in @('.apk', '.exe', '.zip') } |
667 |             Sort-Object Name
668 |     )
669 |     if ($files.Count -ne 3) {
670 |         throw 'Expected exactly Android APK, Windows setup, and Windows portable artifacts.'
671 |     }
672 |     return @(
673 |         foreach ($file in $files) {
674 |             $platform = if ($file.Extension -eq '.apk') { 'android' } else { 'windows' }
675 |             $kind = switch ($file.Extension) {
676 |                 '.apk' { 'installer' }
677 |                 '.exe' { 'installer' }
678 |                 '.zip' { 'portable' }
679 |             }
680 |             $label = switch ($file.Extension) {
681 |                 '.apk' { 'Android ARM64' }
682 |                 '.exe' { 'Windows Installer' }
683 |                 '.zip' { 'Windows Portable' }
684 |             }
685 |             [ordered]@{
686 |                 id = [IO.Path]::GetFileNameWithoutExtension($file.Name).ToLowerInvariant()
687 |                 label = $label
688 |                 platform = $platform
689 |                 arch = if ($file.Extension -eq '.apk') { 'arm64-v8a' } else { 'x64' }
690 |                 fileName = $file.Name
691 |                 sizeBytes = $file.Length
692 |                 url = "https://github.com/$Repository/releases/download/$Tag/$([Uri]::EscapeDataString($file.Name))"
693 |                 kind = $kind
694 |             }
695 |         }
696 |     )
697 | }
698 | function Write-SiteManifest {
699 |     if (-not (Test-Path -LiteralPath $SiteRoot -PathType Container)) {
700 |         throw 'release-site is missing.'
701 |     }
702 |     $assets = Get-ReleaseAssets
703 |     $manifest = [ordered]@{
704 |         schemaVersion = 1
705 |         product = [ordered]@{
706 |             name = 'FlClashPlus'
707 |             tagline = '公开源码与跨端正式发布。'
708 |         }
709 |         release = [ordered]@{
710 |             tag = $Tag
711 |             version = $Version
712 |             appVersion = Get-AppVersion
713 |             publishedAt = [DateTimeOffset]::UtcNow.ToString('o')
714 |             releaseUrl = "https://github.com/$Repository/releases/tag/$Tag"
715 |             privateAccess = $false
716 |             notes = @(
717 |                 '公开源码与公开 Release，遵循 GNU GPL v3.0。',
718 |                                 'Android 与 Windows 工件来自同一份源码快照。'
719 | 
720 |             )
721 |             assets = $assets
722 |         }
723 |     }
724 |     $manifestPath = Join-Path $SiteRoot 'public/release.json'
725 |     $manifest | ConvertTo-Json -Depth 12 |
726 |         Set-Content -LiteralPath $manifestPath -Encoding utf8
727 |     $assets | ConvertTo-Json -Depth 8 |
728 |         Set-Content -LiteralPath (Join-Path $ArtifactsRoot 'artifact-manifest.json') -Encoding utf8
729 | }
730 | 
731 | function Invoke-ReleaseBuild {
732 |     Initialize-ReleaseEnvironment
733 |     foreach ($obsolete in @('SHA256SUMS', 'SOURCE_MANIFEST.sha256')) {
734 |         $obsoletePath = Join-Path $ArtifactsRoot $obsolete
735 |         if (Test-Path -LiteralPath $obsoletePath -PathType Leaf) {
736 |             Remove-Item -LiteralPath $obsoletePath -Force
737 |         }
738 |     }
739 |     $disk = Assert-DiskBudget
740 | 
741 |     Write-ProvenanceBackup
742 |     New-AndroidSigningIdentity
743 | 
744 |     New-Item -ItemType Directory -Force -Path $PackageOutputRoot | Out-Null
745 | 
746 |     $baselinePaths = @(
747 |         (Join-Path $ProjectRoot 'build'),
748 |         (Join-Path $ProjectRoot 'libclash'),
749 |         (Join-Path $ProjectRoot 'services/helper/target'),
750 |         (Join-Path $ProjectRoot 'plugins/rust_api/rust/target'),
751 |         (Join-Path $ProjectRoot 'android/app/src/main/jniLibs')
752 |     )
753 |     [ordered]@{
754 |         schemaVersion = 1
755 |         paths = @(
756 |             foreach ($path in $baselinePaths) {
757 |                 [ordered]@{
758 |                     path = $path
759 |                     existedBefore = Test-Path -LiteralPath $path
760 |                 }
761 |             }
762 |         )
763 |     } | ConvertTo-Json -Depth 6 |
764 |         Set-Content -LiteralPath (Join-Path $BackupRoot 'build-path-baseline.json') -Encoding utf8
765 | 
766 |     $localPropertiesPath = Join-Path $ProjectRoot 'android/local.properties'
767 |     $temporaryKeyStorePath = Join-Path $ProjectRoot 'android/app/keystore.jks'
768 |     $distributorOptionsPath = Join-Path $ProjectRoot 'distribute_options.yaml'
769 |     $windowsMakeConfigPath = Join-Path $ProjectRoot 'windows/packaging/exe/make_config.yaml'
770 |     $envJsonPath = Join-Path $ProjectRoot 'env.json'
771 |     $coreHashPath = Join-Path $ProjectRoot 'core_sha256.json'
772 |     $localState = Save-FileState -Path $localPropertiesPath
773 |     $optionsState = Save-FileState -Path $distributorOptionsPath
774 |     $windowsMakeConfigState = Save-FileState -Path $windowsMakeConfigPath
775 |     $envState = Save-FileState -Path $envJsonPath
776 |     $coreState = Save-FileState -Path $coreHashPath
777 |     if (Test-Path -LiteralPath $temporaryKeyStorePath) {
778 |         throw 'android/app/keystore.jks already exists; refusing to overwrite it.'
779 |     }
780 | 
781 |     $credential = $null
782 |     try {
783 |         $credential = Read-SigningCredential
784 |         Copy-Item -LiteralPath $SigningKeyStore -Destination $temporaryKeyStorePath
785 | 
786 |         $localText = if ($localState.Existed) {
787 |             [Text.Encoding]::UTF8.GetString([byte[]]$localState.Bytes)
788 |         }
789 |         else {
790 |             ''
791 |         }
792 |         if ($localText.Length -gt 0 -and -not $localText.EndsWith("`n")) {
793 |             $localText += "`n"
794 |         }
795 |         $localText += "storePassword=$($credential.storePassword)`n"
796 |         $localText += "keyAlias=$SigningAlias`n"
797 |         $localText += "keyPassword=$($credential.keyPassword)`n"
798 |         [IO.File]::WriteAllText(
799 |             $localPropertiesPath,
800 |             $localText,
801 |             [Text.UTF8Encoding]::new($false)
802 |         )
803 | 
804 |         $optionsText = [Text.Encoding]::UTF8.GetString([byte[]]$optionsState.Bytes)
805 |         $relativeOutput = [IO.Path]::GetRelativePath(
806 |             $ProjectRoot,
807 |             $PackageOutputRoot
808 |         ).Replace('\', '/').TrimEnd('/') + '/'
809 |         $updatedOptions = [regex]::Replace(
810 |             $optionsText,
811 |             "(?m)^output:\s*['""]?.*?['""]?\s*$",
812 |             "output: '$relativeOutput'"
813 |         )
814 |         if ($updatedOptions -eq $optionsText) {
815 |             throw 'Unable to redirect flutter_distributor output safely.'
816 |         }
817 |         [IO.File]::WriteAllText(
818 |             $distributorOptionsPath,
819 |             $updatedOptions,
820 |             [Text.UTF8Encoding]::new($false)
821 |         )
822 | 
823 |         $windowsMakeConfigText = [Text.Encoding]::UTF8.GetString(
824 |             [byte[]]$windowsMakeConfigState.Bytes
825 |         )
826 |         $setupIconPath = (Join-Path $ProjectRoot 'windows/runner/resources/app_icon.ico').Replace('\', '/')
827 |         $localePath = (Join-Path $ProjectRoot 'windows/packaging/exe/ChineseSimplified.isl').Replace('\', '/')
828 |         $windowsMakeConfigText = [regex]::Replace(
829 |             $windowsMakeConfigText,
830 |             '(?m)^setup_icon_file:\s*.*$',
831 |             "setup_icon_file: '$setupIconPath'"
832 |         )
833 |         $windowsMakeConfigText = [regex]::Replace(
834 |             $windowsMakeConfigText,
835 |             '(?m)^(\s*file:\s*).*$',
836 |             "    file: '$localePath'"
837 |         )
838 |         [IO.File]::WriteAllText(
839 |             $windowsMakeConfigPath,
840 |             $windowsMakeConfigText,
841 |             [Text.UTF8Encoding]::new($false)
842 |         )
843 | 
844 |         Invoke-Captured -FilePath 'dart' -Arguments @(
845 |             'pub', 'get'
846 |         ) -LogPath (Join-Path $LogsRoot 'dart-pub-get.log') | Out-Null
847 | 
848 |         $existingApks = @(Get-ChildItem -LiteralPath $PackageOutputRoot -Recurse -File -Filter '*.apk')
849 |         if ($existingApks.Count -gt 1) {
850 |             throw 'Multiple Android package outputs exist; refusing an ambiguous resume.'
851 |         }
852 |         if ($existingApks.Count -eq 0) {
853 |             $androidLogPath = Join-Path $LogsRoot 'build-android-release.log'
854 |             $androidBuild = Invoke-Captured -FilePath 'dart' -Arguments @(
855 |                 'setup.dart', 'android', '--env', 'stable', '--targets', 'apk',
856 |                 '--arch', 'arm64'
857 |             ) -LogPath $androidLogPath -AllowFailure
858 |             if ($androidBuild.ExitCode -ne 0) {
859 |                 $knownDistributorFailure = $androidBuild.Output -match
860 |                     "type '_BuildAndroidApkResult' is not a subtype of type 'BuildWindowsResult'"
861 |                 $flutterApk = Join-Path $ProjectRoot 'build/app/outputs/flutter-apk/app-arm64-v8a-release.apk'
862 |                 if (-not $knownDistributorFailure -or -not (Test-Path -LiteralPath $flutterApk -PathType Leaf)) {
863 |                     throw "Android packaging failed with exit code $($androidBuild.ExitCode)."
864 |                 }
865 |                 $recoveredApk = Join-Path $PackageOutputRoot 'app-arm64-v8a-release.apk'
866 |                 Copy-Item -LiteralPath $flutterApk -Destination $recoveredApk -Force
867 |             }
868 |         }
869 | 
870 |         $existingExes = @(Get-ChildItem -LiteralPath $PackageOutputRoot -File -Filter '*.exe')
871 |         $existingZips = @(Get-ChildItem -LiteralPath $PackageOutputRoot -File -Filter '*.zip')
872 |         if ($existingExes.Count -gt 1 -or $existingZips.Count -gt 1) {
873 |             throw 'Multiple Windows package outputs exist; refusing an ambiguous resume.'
874 |         }
875 |         if ($existingExes.Count -eq 0 -or $existingZips.Count -eq 0) {
876 |             $env:CARGO_TARGET_DIR = $null
877 |             Initialize-PortableWindowsToolchain
878 |             Invoke-Captured -FilePath $env:ComSpec -Arguments @(
879 |                 '/d', '/s', '/c', 'flutter doctor -v'
880 |             ) -LogPath (Join-Path $LogsRoot 'flutter-doctor-windows.log') | Out-Null
881 |             Invoke-Captured -FilePath 'dart' -Arguments @(
882 |                 'setup.dart', 'windows', '--env', 'stable', '--targets', 'exe,zip'
883 |             ) -LogPath (Join-Path $LogsRoot 'build-windows-release.log') | Out-Null
884 |         }
885 |     }
886 |     finally {
887 |         $credential = $null
888 |         if (Test-Path -LiteralPath $temporaryKeyStorePath -PathType Leaf) {
889 |             Remove-Item -LiteralPath $temporaryKeyStorePath -Force
890 |         }
891 |         Restore-FileState -State $localState
892 |         Restore-FileState -State $optionsState
893 |         Restore-FileState -State $windowsMakeConfigState
894 |         Restore-FileState -State $envState
895 |         Restore-FileState -State $coreState
896 |     }
897 | 
898 |     $apk = Get-ChildItem -LiteralPath $PackageOutputRoot -Recurse -File -Filter '*.apk' |
899 |         Sort-Object LastWriteTime -Descending | Select-Object -First 1
900 |     $setup = Get-ChildItem -LiteralPath $PackageOutputRoot -File -Filter '*.exe' |
901 |         Sort-Object LastWriteTime -Descending | Select-Object -First 1
902 |     $portable = Get-ChildItem -LiteralPath $PackageOutputRoot -File -Filter '*.zip' |
903 |         Sort-Object LastWriteTime -Descending | Select-Object -First 1
904 |     if ($null -eq $apk -or $null -eq $setup -or $null -eq $portable) {
905 |         throw 'One or more expected package outputs are missing.'
906 |     }
907 | 
908 |     $artifactPaths = [ordered]@{
909 |         Android = Join-Path $ArtifactsRoot "FlClashPlus-$Version-android-arm64-v8a.apk"
910 |         WindowsSetup = Join-Path $ArtifactsRoot "FlClashPlus-$Version-windows-x64-setup.exe"
911 |         WindowsPortable = Join-Path $ArtifactsRoot "FlClashPlus-$Version-windows-x64-portable.zip"
912 |     }
913 |     foreach ($destination in $artifactPaths.Values) {
914 |         if (Test-Path -LiteralPath $destination) {
915 |             throw "Artifact already exists: $destination"
916 |         }
917 |     }
918 |     Copy-Item -LiteralPath $apk.FullName -Destination $artifactPaths.Android
919 |     Copy-Item -LiteralPath $setup.FullName -Destination $artifactPaths.WindowsSetup
920 |     Copy-Item -LiteralPath $portable.FullName -Destination $artifactPaths.WindowsPortable
921 | 
922 |     Test-AndroidArtifact -ApkPath $artifactPaths.Android
923 |     Test-WindowsZipArtifact -ZipPath $artifactPaths.WindowsPortable
924 |     $signature = Get-AuthenticodeSignature -LiteralPath $artifactPaths.WindowsSetup
925 |     [ordered]@{
926 |         status = [string]$signature.Status
927 |         statusMessage = [string]$signature.StatusMessage
928 |         signerSubject = if ($signature.SignerCertificate) {
929 |             $signature.SignerCertificate.Subject
930 |         }
931 |         else {
932 |             $null
933 |         }
934 |     } | ConvertTo-Json |
935 |         Set-Content -LiteralPath (Join-Path $LogsRoot 'windows-setup-authenticode.json') -Encoding utf8
936 | 
937 |     Write-SiteManifest
938 |     $siteCheckSource = Join-Path $SiteRoot 'scripts\check.mjs'
939 |     $siteCheckScript = Join-Path $TaskTempRoot 'release-site-check.mjs'
940 |     $siteCheckText = Get-Content -LiteralPath $siteCheckSource -Raw
941 |     $siteRootMarker = 'const siteRoot = join(scriptDirectory, "..");'
942 |     $projectRootMarker = 'const projectRoot = join(siteRoot, "..");'
943 |     if (-not $siteCheckText.Contains($siteRootMarker) -or -not $siteCheckText.Contains($projectRootMarker)) {
944 |         throw 'release-site checker root markers are missing.'
945 |     }
946 |     $siteRootJson = $SiteRoot | ConvertTo-Json -Compress
947 |     $projectRootJson = $ProjectRoot | ConvertTo-Json -Compress
948 |     $siteCheckText = $siteCheckText.Replace($siteRootMarker, "const siteRoot = $siteRootJson;")
949 |     $siteCheckText = $siteCheckText.Replace($projectRootMarker, "const projectRoot = $projectRootJson;")
950 |     [IO.File]::WriteAllText($siteCheckScript, $siteCheckText, [Text.UTF8Encoding]::new($false))
951 |     Invoke-Captured -FilePath 'node' -WorkingDirectory $ProjectRoot -Arguments @($siteCheckScript) -LogPath (Join-Path $LogsRoot 'release-site-check.log') | Out-Null
952 |     [ordered]@{
953 |         result = 'built'
954 |         tag = $Tag
955 |         appVersion = Get-AppVersion
956 |         cFreeGiBAtStart = $disk.CFreeGiB
957 |         dFreeGiBAtStart = $disk.DFreeGiB
958 |         artifacts = Get-ReleaseAssets
959 |     } | ConvertTo-Json -Depth 12
960 | }
961 | 
962 | function Test-SensitiveStagingContent {
963 |     param([Parameter(Mandatory)][string]$Root)
964 | 
965 |     $forbiddenNames = @(
966 |         '.env',
967 |         'local.properties',
968 |         'keystore.jks',
969 |         'google-services.json'
970 |     )
971 |     $forbidden = @(
972 |         Get-ChildItem -LiteralPath $Root -Recurse -File -Force |
973 |             Where-Object { $_.Name -in $forbiddenNames }
974 |     )
975 |     if ($forbidden.Count -gt 0) {
976 |         throw "Sensitive or machine-local file entered the source mirror: $($forbidden[0].FullName)"
977 |     }
978 | 
979 |     $tokenPattern = '(?:gh[pousr]_[A-Za-z0-9]{20,}|github_pat_[A-Za-z0-9_]{20,}|CLOUDFLARE_API_TOKEN\s*=\s*["'']?[A-Za-z0-9_-]{16,})'
980 |     $passwordPattern = '(?m)^\s*(?<name>storePassword|keyPassword)\s*=\s*["''](?<value>[^"''\r\n]{4,})["'']'
981 |     $allowedPasswordPlaceholders = @(
982 |         'your_key_password',
983 |         'your_store_password'
984 |     )
985 |     $textFiles = @(
986 |         Get-ChildItem -LiteralPath $Root -Recurse -File -Force |
987 |             Where-Object {
988 |                 $_.Length -lt 2MB -and
989 |                 $_.FullName -notmatch '[\\/]\.git[\\/]' -and
990 |                 $_.Extension -notin @(
991 |                     '.png', '.jpg', '.jpeg', '.gif', '.ico', '.ttf', '.dat',
992 |                     '.mmdb', '.metadb', '.jar', '.zip', '.apk', '.exe', '.dll',
993 |                     '.so', '.dylib', '.a', '.lib'
994 |                 )
995 |             }
996 |     )
997 |     foreach ($file in $textFiles) {
998 |         if (Select-String -LiteralPath $file.FullName -Pattern $tokenPattern -Quiet) {
999 |             throw "Potential token pattern found in source mirror: $($file.FullName)"
1000 |         }
1001 |         $passwordHits = @(Select-String -LiteralPath $file.FullName `
1002 |                 -Pattern $passwordPattern -AllMatches)
1003 |         foreach ($hit in $passwordHits) {
1004 |             foreach ($match in $hit.Matches) {
1005 |                 $value = $match.Groups['value'].Value.ToLowerInvariant()
1006 |                 if ($value -notin $allowedPasswordPlaceholders) {
1007 |                     throw "Potential literal password found in source mirror: $($file.FullName)"
1008 |                 }
1009 |             }
1010 |         }
1011 |     }
1012 | }
1013 | 
1014 | function Copy-SourceTree {
1015 |     param(
1016 |         [Parameter(Mandatory)][string]$Source,
1017 |         [Parameter(Mandatory)][string]$Destination
1018 |     )
1019 | 
1020 |     $excludedSegments = @(
1021 |         '.git', '.dart_tool', '.flutter', '.visual-qa', '.wrangler', '.npm', '=',
1022 |         'npm-cache', 'build', 'coverage', 'target', '.gradle', '.kotlin',
1023 |         '.idea', '.vs', '.cxx', 'Pods', '.plugin_symlinks', 'node_modules',
1024 |         'jniLibs'
1025 |     )
1026 |     $excludedFiles = @(
1027 |         'local.properties', 'keystore.jks', 'google-services.json',
1028 |         'env.json', 'core_sha256.json', '.flutter_tool_state'
1029 |     )
1030 |     if (Test-Path -LiteralPath $Source -PathType Leaf) {
1031 |         New-Item -ItemType Directory -Force -Path (Split-Path -Parent $Destination) |
1032 |             Out-Null
1033 |         Copy-Item -LiteralPath $Source -Destination $Destination
1034 |         return
1035 |     }
1036 | 
1037 |     foreach ($file in Get-ChildItem -LiteralPath $Source -Recurse -File -Force) {
1038 |         $relative = [IO.Path]::GetRelativePath($Source, $file.FullName)
1039 |         $segments = @($relative -split '[\\/]')
1040 |         if (@($segments | Where-Object { $_ -in $excludedSegments -or $_ -match '^vibecodingsdktoolswrangler(?:-|$)' }).Count -gt 0) {
1041 |             continue
1042 |         }
1043 |         if ($file.Name -in $excludedFiles -or
1044 |             $file.Name -match '^(?:hs_err_pid|replay_pid).+\.log$') {
1045 |             continue
1046 |         }
1047 |         $target = Join-Path $Destination $relative
1048 |         New-Item -ItemType Directory -Force -Path (Split-Path -Parent $target) |
1049 |             Out-Null
1050 |         Copy-Item -LiteralPath $file.FullName -Destination $target
1051 |     }
1052 | }
1053 | 
1054 | function Assert-PublicRepository {
1055 |     $result = Invoke-Captured -FilePath (Get-GitHubCliExecutable) -Arguments @(
1056 |         'repo', 'view', $Repository, '--json', 'isPrivate,nameWithOwner,visibility,url'
1057 |     )
1058 |     $repo = $result.Stdout | ConvertFrom-Json
1059 |     if ($repo.isPrivate -ne $false -or
1060 |         $repo.visibility -ne 'PUBLIC' -or
1061 |         $repo.nameWithOwner -ne $Repository) {
1062 |         throw 'Refusing to publish to a repository that is not the expected public repository.'
1063 |     }
1064 |     return $repo
1065 | }
1066 | 
1067 | function Initialize-PublicRepository {
1068 |     $probe = Invoke-Captured -FilePath (Get-GitHubCliExecutable) -Arguments @(
1069 |         'repo', 'view', $Repository, '--json', 'isPrivate'
1070 |     ) -AllowFailure
1071 |     if ($probe.ExitCode -ne 0) {
1072 |         Invoke-Captured -FilePath (Get-GitHubCliExecutable) -Arguments @(
1073 |             'repo', 'create', $Repository, '--public',
1074 |             '--description', 'FlClashPlus public source and release channel',
1075 |             '--disable-issues', '--disable-wiki'
1076 |         ) | Out-Null
1077 |     }
1078 |     return Assert-PublicRepository
1079 | }
1080 | 
1081 | function Initialize-SourceMirror {
1082 |     if (Test-Path -LiteralPath $RepositoryStage) {
1083 |         if (-not (Test-Path -LiteralPath (Join-Path $RepositoryStage '.git'))) {
1084 |             throw 'Repository staging directory exists but is not a Git repository.'
1085 |         }
1086 |         $origin = Invoke-Captured -FilePath (Get-GitExecutable) `
1087 |             -WorkingDirectory $RepositoryStage `
1088 |             -Arguments @('remote', 'get-url', 'origin')
1089 |         $repositoryPattern = [regex]::Escape($Repository) + '(?:\.git)?$'
1090 |         if ($origin.Stdout.Trim() -notmatch $repositoryPattern) {
1091 |             throw 'Repository staging origin does not match the release repository.'
1092 |         }
1093 |         $status = Invoke-Captured -FilePath (Get-GitExecutable) `
1094 |             -WorkingDirectory $RepositoryStage `
1095 |             -Arguments @('status', '--porcelain=v1')
1096 |         if (-not [string]::IsNullOrWhiteSpace($status.Stdout)) {
1097 |             throw 'Repository staging directory contains uncommitted changes.'
1098 |         }
1099 |     }
1100 |     else {
1101 |         New-Item -ItemType Directory -Force -Path (Split-Path -Parent $RepositoryStage) |
1102 |             Out-Null
1103 |         Invoke-Captured -FilePath (Get-GitHubCliExecutable) -Arguments @(
1104 |             'repo', 'clone', $Repository, $RepositoryStage
1105 |         ) -WorkingDirectory $ReleaseRoot `
1106 |             -LogPath (Join-Path $LogsRoot 'github-clone.log') | Out-Null
1107 |     }
1108 | 
1109 |     $sourceDirectories = @(
1110 |         'android', 'arb', 'assets', 'core', 'lib', 'linux', 'macos', 'plugins',
1111 |         'services', 'test', 'windows', 'release-site'
1112 |     )
1113 |     foreach ($relative in $sourceDirectories) {
1114 |         $source = Join-Path $ProjectRoot $relative
1115 |         if (-not (Test-Path -LiteralPath $source)) {
1116 |             throw "Required source directory is missing: $relative"
1117 |         }
1118 |         Copy-SourceTree -Source $source -Destination (Join-Path $RepositoryStage $relative)
1119 |     }
1120 | 
1121 |     $rootFiles = @(
1122 |         '.gitignore', '.metadata', 'analysis_options.yaml', 'build.yaml',
1123 |         'build_config.yaml', 'CHANGELOG.md', 'LICENSE', 'NOTICE.md', 'pubspec.lock',
1124 |         'pubspec.yaml', 'README.md', 'README_zh_CN.md', 'setup.dart',
1125 |         'distribute_options.yaml'
1126 |     )
1127 |     foreach ($relative in $rootFiles) {
1128 |         $source = Join-Path $ProjectRoot $relative
1129 |         if (Test-Path -LiteralPath $source -PathType Leaf) {
1130 |             Copy-SourceTree -Source $source -Destination (Join-Path $RepositoryStage $relative)
1131 |         }
1132 |     }
1133 |     foreach ($relative in @(
1134 |             'command/Publish-FlClashPlusRelease.ps1',
1135 |             'command/Deploy-FlClashPlusSite.ps1',
1136 |             'command/gitpush.cmd'
1137 |         )) {
1138 |         $source = Join-Path $ProjectRoot $relative
1139 |         if (-not (Test-Path -LiteralPath $source -PathType Leaf)) {
1140 |             throw "Required release command is missing: $relative"
1141 |         }
1142 |         Copy-SourceTree -Source $source -Destination (Join-Path $RepositoryStage $relative)
1143 |     }
1144 | 
1145 |     @"
1146 | # FlClashPlus
1147 | 
1148 | Public source mirror and release channel for FlClashPlus.
1149 | 
1150 | - Release tag: $Tag
1151 | - Application version: $(Get-AppVersion)
1152 | - Release page: https://flclashplus.nkbr.cc/
1153 | - Source and release downloads are publicly accessible.
1154 | - License: GNU GPL v3.0; see `LICENSE` and `NOTICE.md`.
1155 | 
1156 | Machine-local Android signing material, `android/local.properties`, and Firebase
1157 | configuration are intentionally excluded. The vendored plugin working trees are
1158 | captured as ordinary source directories so this snapshot includes local changes.
1159 | "@ | Set-Content -LiteralPath (Join-Path $RepositoryStage 'RELEASE_CHANNEL.md') -Encoding utf8
1160 | 
1161 |     @"
1162 | .dart_tool/
1163 | build/
1164 | target/
1165 | .gradle/
1166 | .cxx/
1167 | node_modules/
1168 | android/local.properties
1169 | android/app/keystore.jks
1170 | android/app/google-services.json
1171 | env.json
1172 | core_sha256.json
1173 | "@ | Set-Content -LiteralPath (Join-Path $RepositoryStage '.gitignore') -Encoding utf8
1174 | 
1175 |         foreach ($obsolete in @('SHA256SUMS', 'SOURCE_MANIFEST.sha256')) {
1176 |         $obsoletePath = Join-Path $RepositoryStage $obsolete
1177 |         if (Test-Path -LiteralPath $obsoletePath -PathType Leaf) {
1178 |             Remove-Item -LiteralPath $obsoletePath -Force
1179 |         }
1180 |     }
1181 |     Test-SensitiveStagingContent -Root $RepositoryStage
1182 | 
1183 | }
1184 | 
1185 | function Write-ReleaseNotes {
1186 |     $assetRows = Get-ReleaseAssets
1187 |     $lines = @(
1188 |         "# FlClashPlus $Version",
1189 |         '',
1190 |         'FlClashPlus 公开发布版本。',
1191 |         '',
1192 |         ('Application version: `{0}`' -f (Get-AppVersion)),
1193 |         '',
1194 |         '## Artifacts',
1195 |         ''
1196 |     )
1197 |     foreach ($asset in $assetRows) {
1198 |         $lines += ('- **{0}** — `{1}` — {2:N1} MiB' -f `
1199 |                 $asset.label, $asset.fileName, ($asset.sizeBytes / 1MB))
1200 |     }
1201 |     $lines += @(
1202 |         '',
1203 |         '## Notes',
1204 |         '',
1205 |         '- Android 使用 FlClashPlus 专用发布签名身份。',
1206 |         '- Windows 安装器未进行 Authenticode 签名，系统可能显示 SmartScreen 提示。',
1207 |         '- 对应公开源码快照保存在同名 Release 标签。',
1208 |         '- 公共发布页不包含 GitHub 或 Cloudflare 凭据。'
1209 |     )
1210 |     $notesPath = Join-Path $ReleaseRoot 'release-notes.md'
1211 |     [IO.File]::WriteAllText(
1212 |         $notesPath,
1213 |         ($lines -join "`n") + "`n",
1214 |         [Text.UTF8Encoding]::new($false)
1215 |     )
1216 |     return $notesPath
1217 | }
1218 | 
1219 | function Push-SourceMirror {
1220 |     param(
1221 |         [Parameter(Mandatory)][string]$CommitMessage
1222 |     )
1223 | 
1224 |     Invoke-Captured -FilePath (Get-GitExecutable) -WorkingDirectory $RepositoryStage -Arguments @(
1225 |         'config', 'user.name', 'FlClashPlus Release Bot'
1226 |     ) | Out-Null
1227 |     Invoke-Captured -FilePath (Get-GitExecutable) -WorkingDirectory $RepositoryStage -Arguments @(
1228 |         'config', 'user.email', 'actions@users.noreply.github.com'
1229 |     ) | Out-Null
1230 |     Invoke-Captured -FilePath (Get-GitExecutable) -WorkingDirectory $RepositoryStage -Arguments @(
1231 |         'add', '--all'
1232 |     ) | Out-Null
1233 | 
1234 |     $diffCheck = Invoke-Captured -FilePath (Get-GitExecutable) -WorkingDirectory $RepositoryStage `
1235 |         -Arguments @(
1236 |             'diff', '--cached', '--check', '--',
1237 |             'README.md', 'README_zh_CN.md', 'NOTICE.md', 'RELEASE_CHANNEL.md',
1238 |             '.gitignore', 'command/Publish-FlClashPlusRelease.ps1',
1239 |             'command/Deploy-FlClashPlusSite.ps1', 'command/gitpush.cmd'
1240 |         ) -AllowFailure `
1241 |         -LogPath (Join-Path $LogsRoot 'source-mirror-diff-check.log')
1242 |     if ($diffCheck.ExitCode -ne 0) {
1243 |         throw 'Source mirror contains whitespace errors; see source-mirror-diff-check.log.'
1244 |     }
1245 | 
1246 |     $pending = Invoke-Captured -FilePath (Get-GitExecutable) -WorkingDirectory $RepositoryStage `
1247 |         -Arguments @('diff', '--cached', '--quiet') -AllowFailure
1248 |     if ($pending.ExitCode -eq 1) {
1249 |         Invoke-Captured -FilePath (Get-GitExecutable) -WorkingDirectory $RepositoryStage -Arguments @(
1250 |             'commit', '-m', $CommitMessage
1251 |         ) -LogPath (Join-Path $LogsRoot 'github-commit.log') | Out-Null
1252 |     }
1253 |     elseif ($pending.ExitCode -ne 0) {
1254 |         throw "Unable to inspect staged source changes; git exited $($pending.ExitCode)."
1255 |     }
1256 | 
1257 |     Invoke-Captured -FilePath (Get-GitExecutable) -WorkingDirectory $RepositoryStage -Arguments @(
1258 |         'push', '-u', 'origin', 'HEAD:main'
1259 |     ) -LogPath (Join-Path $LogsRoot 'github-push-main.log') | Out-Null
1260 | 
1261 |     $head = Invoke-Captured -FilePath (Get-GitExecutable) -WorkingDirectory $RepositoryStage -Arguments @(
1262 |         'rev-parse', 'HEAD'
1263 |     )
1264 |     return $head.Stdout.Trim()
1265 | }
1266 | 
1267 | function Invoke-SourceVerification {
1268 |     Initialize-ReleaseEnvironment
1269 |     $repo = Assert-PublicRepository
1270 | 
1271 |     $notice = Invoke-Captured -FilePath (Get-GitHubCliExecutable) -Arguments @(
1272 |         'api', "repos/$Repository/contents/NOTICE.md", '--silent'
1273 |     ) -AllowFailure
1274 |     if ($notice.ExitCode -ne 0) {
1275 |         throw 'Published repository is missing NOTICE.md.'
1276 |     }
1277 | 
1278 |     $metadata = $null
1279 |     $acceptedLicenses = @('GPL-3.0', 'GPL-3.0-only', 'GPL-3.0-or-later')
1280 |     foreach ($attempt in 1..15) {
1281 |         $metadataResult = Invoke-Captured -FilePath (Get-GitHubCliExecutable) -Arguments @(
1282 |             'api', "repos/$Repository", '--jq',
1283 |             '{fullName:.full_name,visibility:.visibility,private:.private,defaultBranch:.default_branch,license:.license.spdx_id,url:.html_url}'
1284 |         )
1285 |         $metadata = $metadataResult.Stdout | ConvertFrom-Json
1286 |         if ($metadata.defaultBranch -eq 'main' -and
1287 |             $metadata.visibility -eq 'public' -and
1288 |             $metadata.private -eq $false -and
1289 |             $metadata.license -in $acceptedLicenses) {
1290 |             break
1291 |         }
1292 |         Start-Sleep -Seconds 2
1293 |     }
1294 | 
1295 |     if ($metadata.defaultBranch -ne 'main') {
1296 |         throw "Unexpected default branch: $($metadata.defaultBranch)"
1297 |     }
1298 |     if ($metadata.visibility -ne 'public' -or $metadata.private -ne $false) {
1299 |         throw 'Repository readback did not confirm public visibility.'
1300 |     }
1301 |     if ($metadata.license -notin $acceptedLicenses) {
1302 |         throw "GitHub did not recognize the expected GPL-3.0 license: $($metadata.license)"
1303 |     }
1304 | 
1305 |     $commitResult = Invoke-Captured -FilePath (Get-GitHubCliExecutable) -Arguments @(
1306 |         'api', "repos/$Repository/commits/main", '--jq', '.sha'
1307 |     )
1308 |     return [ordered]@{
1309 |         result = 'source-verified'
1310 |         repository = $repo.nameWithOwner
1311 |         visibility = $metadata.visibility
1312 |         private = $metadata.private
1313 |         defaultBranch = $metadata.defaultBranch
1314 |         license = $metadata.license
1315 |         notice = $true
1316 |         commit = $commitResult.Stdout.Trim()
1317 |         url = $metadata.url
1318 |     }
1319 | }
1320 | 
1321 | function Invoke-SourcePublish {
1322 |     if (-not $Apply) {
1323 |         throw 'Source publishing requires the explicit -Apply switch.'
1324 |     }
1325 |     Initialize-ReleaseEnvironment
1326 |     [void](Initialize-PublicRepository)
1327 |     Initialize-SourceMirror
1328 |     [void](Push-SourceMirror -CommitMessage 'Publish FlClashPlus public source')
1329 |     return Invoke-SourceVerification
1330 | }
1331 | 
1332 | function Invoke-GitHubPublish {
1333 |     if (-not $Apply) {
1334 |         throw 'Publish requires the explicit -Apply switch.'
1335 |     }
1336 |     Initialize-ReleaseEnvironment
1337 |     Write-SiteManifest
1338 |     $notesPath = Write-ReleaseNotes
1339 |     [void](Initialize-PublicRepository)
1340 |     Initialize-SourceMirror
1341 |     [void](Push-SourceMirror -CommitMessage "FlClashPlus $Tag public release")
1342 | 
1343 |     Invoke-Captured -FilePath (Get-GitExecutable) -WorkingDirectory $RepositoryStage -Arguments @(
1344 |         'tag', '-a', $Tag, '-m', "FlClashPlus $Version"
1345 |     ) | Out-Null
1346 |     Invoke-Captured -FilePath (Get-GitExecutable) -WorkingDirectory $RepositoryStage -Arguments @(
1347 |         'push', 'origin', $Tag
1348 |     ) -LogPath (Join-Path $LogsRoot 'github-push-tag.log') | Out-Null
1349 | 
1350 |         $uploadPaths = @(
1351 |         Get-ReleaseAssets |
1352 |             ForEach-Object { Join-Path $ArtifactsRoot $_.fileName }
1353 |     )
1354 | 
1355 |     $releaseArgs = @(
1356 |         'release', 'create', $Tag,
1357 |         '--repo', $Repository,
1358 |         '--verify-tag',
1359 |         '--draft',
1360 |         '--title', "FlClashPlus $Version",
1361 |         '--notes-file', $notesPath
1362 |     ) + $uploadPaths
1363 |     Invoke-Captured -FilePath (Get-GitHubCliExecutable) -Arguments $releaseArgs `
1364 |         -LogPath (Join-Path $LogsRoot 'github-release-create.log') | Out-Null
1365 | 
1366 |     $draftResult = Invoke-Captured -FilePath (Get-GitHubCliExecutable) -Arguments @(
1367 |         'release', 'view', $Tag, '--repo', $Repository,
1368 |         '--json', 'tagName,isDraft,isPrerelease,url,assets'
1369 |     )
1370 |     $draft = $draftResult.Stdout | ConvertFrom-Json
1371 |     if ($draft.isDraft -ne $true -or $draft.tagName -ne $Tag) {
1372 |         throw 'GitHub draft release readback failed.'
1373 |     }
1374 |     $expectedNames = @($uploadPaths | ForEach-Object { [IO.Path]::GetFileName($_) })
1375 |     $actualNames = @($draft.assets | ForEach-Object name)
1376 |     foreach ($expected in $expectedNames) {
1377 |         if ($expected -notin $actualNames) {
1378 |             throw "GitHub draft release is missing asset: $expected"
1379 |         }
1380 |     }
1381 | 
1382 |     Invoke-Captured -FilePath (Get-GitHubCliExecutable) -Arguments @(
1383 |         'release', 'edit', $Tag, '--repo', $Repository, '--draft=false'
1384 |     ) -LogPath (Join-Path $LogsRoot 'github-release-publish.log') | Out-Null
1385 |     return Invoke-ReleaseVerification
1386 | }
1387 | 
1388 | function Invoke-ReleaseVerification {
1389 |     Initialize-ReleaseEnvironment
1390 |     $repo = Assert-PublicRepository
1391 |     $releaseResult = Invoke-Captured -FilePath (Get-GitHubCliExecutable) -Arguments @(
1392 |         'release', 'view', $Tag, '--repo', $Repository,
1393 |         '--json', 'tagName,isDraft,isPrerelease,url,assets,publishedAt'
1394 |     )
1395 |     $release = $releaseResult.Stdout | ConvertFrom-Json
1396 |     if ($release.tagName -ne $Tag -or $release.isDraft -ne $false) {
1397 |         throw 'GitHub release is not published as expected.'
1398 |     }
1399 |     $localAssets = Get-ReleaseAssets
1400 |     $remoteNames = @($release.assets | ForEach-Object name)
1401 |     foreach ($asset in $localAssets) {
1402 |         if ($asset.fileName -notin $remoteNames) {
1403 |             throw "Published release is missing asset: $($asset.fileName)"
1404 |         }
1405 |     }
1406 |     return [ordered]@{
1407 |         result = 'verified'
1408 |         repository = $repo.nameWithOwner
1409 |         private = $repo.isPrivate
1410 |         tag = $release.tagName
1411 |         draft = $release.isDraft
1412 |         prerelease = $release.isPrerelease
1413 |         publishedAt = $release.publishedAt
1414 |         releaseUrl = $release.url
1415 |         assetCount = @($release.assets).Count
1416 |     }
1417 | }
1418 | 
1419 | function Remove-OwnedPath {
1420 |     param(
1421 |         [Parameter(Mandatory)][string]$Path,
1422 |         [Parameter(Mandatory)][string[]]$AllowedRoots
1423 |     )
1424 |     if (-not (Test-Path -LiteralPath $Path)) {
1425 |         return
1426 |     }
1427 |     $full = [IO.Path]::GetFullPath($Path)
1428 |     $allowed = $false
1429 |     foreach ($root in $AllowedRoots) {
1430 |         $rootFull = [IO.Path]::GetFullPath($root).TrimEnd('\', '/')
1431 |         if ($full.StartsWith(
1432 |                 $rootFull + [IO.Path]::DirectorySeparatorChar,
1433 |                 [StringComparison]::OrdinalIgnoreCase
1434 |             )) {
1435 |             $allowed = $true
1436 |             break
1437 |         }
1438 |     }
1439 |     if (-not $allowed) {
1440 |         throw "Cleanup path is outside the explicit roots: $full"
1441 |     }
1442 |     Remove-Item -LiteralPath $full -Recurse -Force
1443 | }
1444 | 
1445 | function Invoke-ReleaseCleanup {
1446 |     Initialize-ReleaseEnvironment
1447 |     $allowedRoots = @($ProjectRoot, $SdkRoot, $ReleaseRoot)
1448 |     Remove-OwnedPath -Path $TaskTempRoot -AllowedRoots $allowedRoots
1449 |     Remove-OwnedPath -Path $TaskCargoTarget -AllowedRoots $allowedRoots
1450 |     Remove-OwnedPath -Path $PackageOutputRoot -AllowedRoots $allowedRoots
1451 | 
1452 |     $baselinePath = Join-Path $BackupRoot 'build-path-baseline.json'
1453 |     $removed = [Collections.Generic.List[string]]::new()
1454 |     if (Test-Path -LiteralPath $baselinePath -PathType Leaf) {
1455 |         $baseline = Get-Content -LiteralPath $baselinePath -Raw | ConvertFrom-Json
1456 |         foreach ($record in $baseline.paths) {
1457 |             if ($record.existedBefore -eq $false -and (Test-Path -LiteralPath $record.path)) {
1458 |                 Remove-OwnedPath -Path $record.path -AllowedRoots $allowedRoots
1459 |                 $removed.Add([string]$record.path)
1460 |             }
1461 |         }
1462 |     }
1463 |     return [ordered]@{
1464 |         result = 'cleaned'
1465 |         removedBuildPaths = @($removed)
1466 |         preserved = @($ArtifactsRoot, $LogsRoot, $RepositoryStage, $BackupRoot)
1467 |     }
1468 | }
1469 | 
1470 | Initialize-ReleaseEnvironment
1471 | 
1472 | switch ($Action) {
1473 |     'Plan' {
1474 |         [ordered]@{
1475 |             action = 'Plan'
1476 |             tag = $Tag
1477 |             appVersion = Get-AppVersion
1478 |             repository = $Repository
1479 |             repositoryMustBePublic = $true
1480 |             license = 'GPL-3.0'
1481 |             releaseRoot = $ReleaseRoot
1482 |             artifacts = @(
1483 |                 "FlClashPlus-$Version-android-arm64-v8a.apk",
1484 |                 "FlClashPlus-$Version-windows-x64-setup.exe",
1485 |                                 "FlClashPlus-$Version-windows-x64-portable.zip"
1486 |             )
1487 | 
1488 |             externalWriteRequiresApply = $true
1489 |         } | ConvertTo-Json -Depth 8
1490 |     }
1491 |     'Build' {
1492 |         Invoke-ReleaseBuild
1493 |     }
1494 |     'Source' {
1495 |         Invoke-SourcePublish | ConvertTo-Json -Depth 8
1496 |     }
1497 |     'Publish' {
1498 |         Invoke-GitHubPublish
1499 |     }
1500 |     'Verify' {
1501 |         Invoke-ReleaseVerification | ConvertTo-Json -Depth 8
1502 |     }
1503 |     'Clean' {
1504 |         Invoke-ReleaseCleanup | ConvertTo-Json -Depth 8
1505 |     }
1506 |     'All' {
1507 |         if (-not $Apply) {
1508 |             throw 'All requires the explicit -Apply switch.'
1509 |         }
1510 |         Invoke-ReleaseBuild | Out-Host
1511 |         Invoke-GitHubPublish | ConvertTo-Json -Depth 8
1512 |     }
1513 | }