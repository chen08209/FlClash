param(
    [ValidateSet('Inspect','Install','Restore')][string]$Action='Inspect',
    [string]$TargetDirectory,
    [string]$PackageDirectory=$PSScriptRoot,
    [switch]$Apply
)
$ErrorActionPreference='Stop'
function Get-ScopedPath([string]$Root,[string]$Relative) {
    $base=[IO.Path]::GetFullPath($Root).TrimEnd('\')+'\'
    $path=[IO.Path]::GetFullPath((Join-Path $base $Relative))
    if(!$path.StartsWith($base,[StringComparison]::OrdinalIgnoreCase)){throw '文件路径超出允许目录'}
    return $path
}
function Get-Sha([string]$Path) {(Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash}
function Write-Json([string]$Path,$Value) {
    [IO.File]::WriteAllText($Path,($Value|ConvertTo-Json -Depth 12),[Text.UTF8Encoding]::new($false))
}
function Assert-Stopped {
    $running=@(Get-Process -Name FlClash,FlClashCore -ErrorAction SilentlyContinue)
    foreach($process in $running) {
        try {$path=$process.Path} catch {$path=$null}
        if($path -and $path.StartsWith($target+'\',[StringComparison]::OrdinalIgnoreCase)){throw '请先关闭 Windows 热点，再从托盘退出 FlClash；本工具不会结束正在运行的程序。'}
    }
    foreach($name in @('FlClash.exe','FlClashCore.exe','data\app.so')) {
        $path=Get-ScopedPath $target $name
        if(Test-Path -LiteralPath $path) {
            try {$handle=[IO.File]::Open($path,[IO.FileMode]::Open,[IO.FileAccess]::ReadWrite,[IO.FileShare]::None);$handle.Dispose()}
            catch {throw '目标程序文件仍被占用或不可写，请先退出目标 FlClash；本工具不会结束任何进程。'}
        }
    }
}
$package=[IO.Path]::GetFullPath($PackageDirectory)
$manifest=Get-Content -LiteralPath (Join-Path $package 'hotspot-manifest.json') -Raw -Encoding utf8 | ConvertFrom-Json
if(!$TargetDirectory){$TargetDirectory=$manifest.TargetDirectory}
$target=[IO.Path]::GetFullPath($TargetDirectory).TrimEnd('\')
if(!(Test-Path -LiteralPath (Join-Path $target 'FlClash.exe'))){throw '目标目录不是可识别的 FlClash 安装目录'}
$operationMutex=[Threading.Mutex]::new($false,'Local\FlClashHotspotCodeUpdate')
$operationLocked=$false
try {
if($Apply -and $Action -ne 'Inspect') {
    try {$operationLocked=$operationMutex.WaitOne(0)} catch [Threading.AbandonedMutexException] {$operationLocked=$true}
    if(!$operationLocked){throw '另一个安装或恢复操作正在进行，请等待完成后再试。'}
}
$backupRoot=Join-Path $target 'hotspot-code-backups'
$previous=$null
$pointer=Join-Path $backupRoot 'latest.txt'
if(Test-Path -LiteralPath $pointer) {
    $previousName=(Get-Content -LiteralPath $pointer -Raw -Encoding utf8).Trim()
    $previousPath=Get-ScopedPath $backupRoot $previousName
    $previousRecord=Get-Content -LiteralPath (Join-Path $previousPath 'backup.json') -Raw -Encoding utf8 | ConvertFrom-Json
    if($previousRecord.TargetDirectory -ne $target){throw '既有备份与目标目录不匹配'}
    foreach($saved in $previousRecord.Files) {
        if($saved.WasPresent -and (Get-Sha (Get-ScopedPath $previousPath ('files\'+$saved.Path))) -ne $saved.OriginalSha256){throw '既有原版备份校验失败'}
    }
    $previous=@{Name=$previousName;Path=$previousPath;Record=$previousRecord}
}
if($Action -eq 'Restore') {
    $pointer=Join-Path $backupRoot 'latest.txt'
    if(!(Test-Path -LiteralPath $pointer)){throw '没有找到本功能的程序备份'}
    $backup=Get-ScopedPath $backupRoot ((Get-Content -LiteralPath $pointer -Raw -Encoding utf8).Trim())
    $record=Get-Content -LiteralPath (Join-Path $backup 'backup.json') -Raw -Encoding utf8 | ConvertFrom-Json
    if($record.TargetDirectory -ne $target){throw '备份与目标目录不匹配'}
    foreach($file in $record.Files) {
        $destination=Get-ScopedPath $target $file.Path
        if($file.WasPresent -and (Get-Sha (Get-ScopedPath $backup ('files\'+$file.Path))) -ne $file.OriginalSha256){throw '原版程序备份校验失败'}
        if((Test-Path -LiteralPath $destination) -and (Get-Sha $destination) -notin @($file.InstalledSha256,$file.OriginalSha256,$file.PreviousInstalledSha256)){throw ('目标文件已被其他操作更改，拒绝覆盖：'+$file.Path)}
    }
    if(!$Apply){Write-Output '预览：校验通过；加入 -Apply 才会恢复原版程序资源，不更改节点或用户配置。';return}
    Assert-Stopped
    foreach($file in $record.Files) {
        $destination=Get-ScopedPath $target $file.Path
        if($file.WasPresent){Copy-Item -LiteralPath (Get-ScopedPath $backup ('files\'+$file.Path)) -Destination $destination -Force}
        elseif(Test-Path -LiteralPath $destination){Remove-Item -LiteralPath $destination -Force}
    }
    $record | Add-Member -NotePropertyName RestoredAt -NotePropertyValue (Get-Date).ToString('o') -Force
    Write-Json (Join-Path $backup 'backup.json') $record
    Write-Output '原版程序资源已恢复。请手动打开 FlClash；节点、订阅和用户配置未修改。'
    return
}
foreach($file in $manifest.PayloadFiles) {
    if($file.Path -ne 'data\app.so' -and !$file.Path.StartsWith('data\flutter_assets\',[StringComparison]::OrdinalIgnoreCase)){throw '安装包包含超出范围的文件'}
    $source=Get-ScopedPath (Join-Path $package 'payload') $file.Path
    if((Get-Sha $source) -ne $file.Sha256){throw ('安装包校验失败：'+$file.Path)}
}
foreach($file in $manifest.BaseFiles) {
    $actual=Get-Sha (Get-ScopedPath $target $file.Path)
    if($actual -ne $file.Sha256) {
        $owned=if($previous -and $previous.Record.SourceCommit -eq $manifest.SourceCommit){$previous.Record.Files | Where-Object Path -eq $file.Path | Select-Object -First 1}else{$null}
        if($file.Path -ne 'data\app.so' -or !$owned -or $actual -notin @($owned.InstalledSha256,$owned.OriginalSha256,$owned.PreviousInstalledSha256)){throw ('目标原版与此测试包不兼容：'+$file.Path)}
    }
}
$different=@(foreach($file in $manifest.PayloadFiles){$path=Get-ScopedPath $target $file.Path;if(!(Test-Path -LiteralPath $path) -or (Get-Sha $path) -ne $file.Sha256){$file.Path}})
if(!$different.Count){Write-Output '已经安装此测试版，全部资源校验一致，无需重复安装。';return}
Write-Output ('目标目录：'+$target)
Write-Output ('已校验应用资源：'+$manifest.PayloadFiles.Count+' 项')
Write-Output '只更新程序应用层资源；节点、订阅、DNS、规则、驱动和系统代理不在安装范围。'
if($Action -eq 'Inspect' -or !$Apply){Write-Output '当前为预览，没有安装。';return}
Assert-Stopped
$name=if($previous){$previous.Name}else{(Get-Date).ToString('yyyyMMdd-HHmmss')+'-'+[guid]::NewGuid().ToString('N').Substring(0,8)}
$backup=Get-ScopedPath $backupRoot $name
New-Item -ItemType Directory -Path $backup -Force | Out-Null
$files=@(foreach($file in $manifest.PayloadFiles) {
    $destination=Get-ScopedPath $target $file.Path
    $present=Test-Path -LiteralPath $destination
    $hash=if($present){Get-Sha $destination}else{$null}
    $owned=if($previous){$previous.Record.Files | Where-Object Path -eq $file.Path | Select-Object -First 1}else{$null}
    if($owned) {
        if($hash -notin @($owned.InstalledSha256,$owned.OriginalSha256,$owned.PreviousInstalledSha256)){throw ('既有测试版资源被其他操作更改：'+$file.Path)}
        @{Path=$file.Path;WasPresent=$owned.WasPresent;OriginalSha256=$owned.OriginalSha256;InstalledSha256=$file.Sha256;PreviousInstalledSha256=$hash}
    } else {
    if($present) {
        $saved=Get-ScopedPath $backup ('files\'+$file.Path)
        New-Item -ItemType Directory -Path (Split-Path $saved -Parent) -Force | Out-Null
        Copy-Item -LiteralPath $destination -Destination $saved
        if((Get-Sha $saved) -ne $hash){throw '写入前的原版程序备份校验失败'}
    }
    @{Path=$file.Path;WasPresent=$present;OriginalSha256=$hash;InstalledSha256=$file.Sha256}
    }
})
$restoreFiles=@($files)
if($previous){$restoreFiles+=@($previous.Record.Files | Where-Object {$_.Path -notin @($files.Path)})}
$capturedAt=if($previous){if($previous.Record.OriginalCapturedAt){$previous.Record.OriginalCapturedAt}else{$previous.Record.PreparedAt}}else{(Get-Date).ToString('o')}
$record=@{TargetDirectory=$target;SourceCommit=$manifest.SourceCommit;OriginalCapturedAt=$capturedAt;PreparedAt=(Get-Date).ToString('o');Status='Prepared';Files=$restoreFiles}
Write-Json (Join-Path $backup 'backup.json') $record
$changed=@()
try {
    foreach($file in $files) {
        $destination=Get-ScopedPath $target $file.Path
        New-Item -ItemType Directory -Path (Split-Path $destination -Parent) -Force | Out-Null
        $temporary=$destination+'.hotspot-'+[guid]::NewGuid().ToString('N')
        Copy-Item -LiteralPath (Get-ScopedPath (Join-Path $package 'payload') $file.Path) -Destination $temporary
        try {Move-Item -LiteralPath $temporary -Destination $destination -Force}
        finally {if(Test-Path -LiteralPath $temporary){Remove-Item -LiteralPath $temporary -Force}}
        $changed+=,$file
        if((Get-Sha $destination) -ne $file.InstalledSha256){throw '安装后校验失败'}
    }
    $record.Status='Installed'
    Write-Json (Join-Path $backup 'backup.json') $record
    [IO.File]::WriteAllText((Join-Path $backupRoot 'latest.txt'),$name,[Text.UTF8Encoding]::new($false))
} catch {
    foreach($file in $restoreFiles) {
        $destination=Get-ScopedPath $target $file.Path
        if($file.WasPresent){Copy-Item -LiteralPath (Get-ScopedPath $backup ('files\'+$file.Path)) -Destination $destination -Force}
        elseif(Test-Path -LiteralPath $destination){Remove-Item -LiteralPath $destination -Force}
    }
    $record.Status='RolledBack'
    Write-Json (Join-Path $backup 'backup.json') $record
    throw
}
Write-Output '热点分流测试版资源已安装，原版程序资源已备份。请手动打开 FlClash。'
Write-Output '入口：工具 → 网络 → 热点共享分流。先保持规则模式与虚拟网卡开启，再打开新开关。'
} finally {
    if($operationLocked){$operationMutex.ReleaseMutex()}
    $operationMutex.Dispose()
}
