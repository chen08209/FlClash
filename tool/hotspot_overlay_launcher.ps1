param(
    [ValidateSet('Install','Restore')][string]$Action='Install',
    [string]$PackageDirectory=$PSScriptRoot,
    [string]$TargetDirectory
)
$ErrorActionPreference='Stop'
$messages=[Collections.Generic.List[string]]::new()
$result=@{At=(Get-Date).ToString('o');Action=$Action;Success=$false}
try {
    $params=@{Action=$Action;Apply=$true;PackageDirectory=$PackageDirectory}
    if($TargetDirectory){$params.TargetDirectory=$TargetDirectory}
    & (Join-Path $PSScriptRoot 'hotspot_overlay.ps1') @params 2>&1 | ForEach-Object {
        $line=$_.ToString();$messages.Add($line);Write-Host $line
    }
    $result.Success=$true
} catch {
    $result.Error=$_.Exception.Message
    $line='操作没有完成：'+$result.Error
    $messages.Add($line);Write-Host $line -ForegroundColor Red
} finally {
    [IO.File]::WriteAllText((Join-Path $PackageDirectory 'last-operation.log'),($messages -join [Environment]::NewLine),[Text.UTF8Encoding]::new($false))
    [IO.File]::WriteAllText((Join-Path $PackageDirectory 'last-operation-result.json'),($result|ConvertTo-Json -Depth 5),[Text.UTF8Encoding]::new($false))
}
if(!$result.Success){exit 1}
