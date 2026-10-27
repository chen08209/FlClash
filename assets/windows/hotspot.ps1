param(
    [ValidateSet('inspect','enable','disable','repair')][string]$Action='inspect',
    [string]$TunName='FlClash',
    [Parameter(Mandatory=$true)][string]$StateFile,
    [Parameter(Mandatory=$true)][string]$ResultFile
)
$ErrorActionPreference='Stop'
$result=@{managed=$false;on=$false;throughTun=$false;clients=0;ssid='';error=''}
$session=$null
$manager=$null
$mutex=[Threading.Mutex]::new($false,'Local\FlClashHotspotSharing')
$locked=$false
function Write-Json($Path,$Value) {
    $temp=$Path+'.tmp'
    [IO.File]::WriteAllText($temp,($Value|ConvertTo-Json -Depth 8),[Text.UTF8Encoding]::new($false))
    Move-Item -LiteralPath $temp -Destination $Path -Force
}
function Await-Operation($Operation) {
    $type=[Windows.Networking.NetworkOperators.NetworkOperatorTetheringOperationResult,Windows.Networking.NetworkOperators,ContentType=WindowsRuntime]
    $method=[System.WindowsRuntimeSystemExtensions].GetMethods() | Where-Object {$_.Name -eq 'AsTask' -and $_.IsGenericMethodDefinition -and $_.GetParameters().Count -eq 1 -and $_.GetParameters()[0].ParameterType.Name -eq 'IAsyncOperation`1'} | Select-Object -First 1
    $task=$method.MakeGenericMethod($type).Invoke($null,@($Operation))
    if(!$task.Wait(18000)){throw 'operation_timeout'}
    if($task.GetAwaiter().GetResult().Status.ToString() -ne 'Success'){throw 'operation_failed'}
}
function Stop-OwnedHotspot {
    if($manager -and $manager.TetheringOperationalState.ToString() -eq 'On') {
        Await-Operation ($manager.StopTetheringAsync())
    }
}
function Test-ConflictingSharing {
    param($Interfaces,[int]$TunIndex,[bool]$HotspotOn)
    return $HotspotOn -or @($Interfaces | Where-Object {$_.InterfaceIndex -ne $TunIndex -and $_.Forwarding.ToString() -eq 'Enabled'}).Count -gt 0
}
function Read-Shape {
    $rows=@(Get-NetIPInterface -AddressFamily IPv4)
    if(!$session -or !$session.privateGuid){return $false}
    $privateAdapter=@(Get-NetAdapter -IncludeHidden | Where-Object {$_.InterfaceGuid.ToString() -eq $session.privateGuid -and $_.Status -eq 'Up'})
    if($privateAdapter.Count -ne 1){return $false}
    $private=@(Get-NetIPAddress -AddressFamily IPv4 -InterfaceIndex $privateAdapter[0].ifIndex -ErrorAction SilentlyContinue | Where-Object {$_.IPAddress -notlike '169.254.*'})
    $tunForward=@($rows | Where-Object {$_.InterfaceIndex -eq $tun.ifIndex -and $_.Forwarding.ToString() -eq 'Enabled'}).Count -eq 1
    $privateForward=$private.Count -eq 1 -and @($rows | Where-Object {$_.InterfaceIndex -eq $private[0].InterfaceIndex -and $_.Forwarding.ToString() -eq 'Enabled'}).Count -eq 1
    $physicalIndexes=@(Get-NetAdapter -IncludeHidden | Where-Object {$_.InterfaceGuid.ToString() -ne $tun.InterfaceGuid.ToString() -and $_.ifIndex -notin @($private.InterfaceIndex) -and $_.Status -eq 'Up' -and $_.HardwareInterface} | Select-Object -ExpandProperty ifIndex)
    $physicalForward=@($rows | Where-Object {$_.InterfaceIndex -in $physicalIndexes -and $_.Forwarding.ToString() -eq 'Enabled'}).Count -gt 0
    return $tunForward -and $privateForward -and !$physicalForward
}
try {
    try {$locked=$mutex.WaitOne(2000)} catch [Threading.AbandonedMutexException] {$locked=$true}
    if(!$locked){throw 'operation_busy'}
    if(Test-Path -LiteralPath $StateFile){$session=Get-Content -LiteralPath $StateFile -Raw -Encoding utf8 | ConvertFrom-Json}
    $result.managed=$null -ne $session -and $session.version -eq 1 -and $session.active
    Add-Type -AssemblyName System.Runtime.WindowsRuntime
    $null=[Windows.Networking.Connectivity.NetworkInformation,Windows.Networking.Connectivity,ContentType=WindowsRuntime]
    $null=[Windows.Networking.NetworkOperators.NetworkOperatorTetheringManager,Windows.Networking.NetworkOperators,ContentType=WindowsRuntime]
    $tun=@(Get-NetAdapter -IncludeHidden | Where-Object {$_.Name -eq $TunName -and $_.Status -eq 'Up'})
    $profiles=@([Windows.Networking.Connectivity.NetworkInformation]::GetConnectionProfiles())
    $profile=if($tun.Count -eq 1){$profiles | Where-Object {$_.NetworkAdapter -and $_.NetworkAdapter.NetworkAdapterId.ToString() -eq $tun[0].InterfaceGuid.ToString().Trim('{}')} | Select-Object -First 1}else{$null}
    if(!$profile -and $Action -in @('disable','inspect') -and $result.managed) {
        $profile=$profiles | Where-Object {$_.NetworkAdapter -and $_.GetNetworkConnectivityLevel().ToString() -eq 'InternetAccess'} | Select-Object -First 1
    }
    if(!$profile){if($Action -ne 'inspect' -or $result.managed){throw 'tun_required'};return}
    $tun=$tun | Select-Object -First 1
    $manager=[Windows.Networking.NetworkOperators.NetworkOperatorTetheringManager]::CreateFromConnectionProfile($profile)
    for($n=0;$n -lt 30 -and $manager.TetheringOperationalState.ToString() -eq 'InTransition';$n++){Start-Sleep -Milliseconds 100}
    $result.on=$manager.TetheringOperationalState.ToString() -eq 'On'
    $result.ssid=$manager.GetCurrentAccessPointConfiguration().Ssid
    if($result.managed -and $session.ssid -ne $result.ssid){throw 'ownership_changed'}
    if($Action -eq 'disable' -and $result.managed) {
        Stop-OwnedHotspot
        $session.active=$false
        Write-Json $StateFile $session
        $result.managed=$false
    }
    if($Action -in @('enable','repair')) {
        if(!$tun){throw 'tun_required'}
        if($Action -eq 'repair' -and !$result.managed){throw 'ownership_changed'}
        if(!$result.managed) {
            if(Test-ConflictingSharing -Interfaces @(Get-NetIPInterface -AddressFamily IPv4) -TunIndex $tun.ifIndex -HotspotOn $result.on){throw 'existing_hotspot'}
            $session=[pscustomobject]@{version=1;active=$true;ssid=$result.ssid;tunGuid=$tun.InterfaceGuid.ToString();privateGuid=''}
            Write-Json $StateFile $session
            $result.managed=$true
        }
        if($Action -eq 'repair'){Stop-OwnedHotspot}
        if($manager.TetheringOperationalState.ToString() -ne 'On') {
            $beforeUp=@(Get-NetAdapter -IncludeHidden | Where-Object {$_.Status -eq 'Up'} | ForEach-Object {$_.InterfaceGuid.ToString()})
            if([Windows.Networking.NetworkOperators.NetworkOperatorTetheringManager]::GetTetheringCapabilityFromConnectionProfile($profile).ToString() -ne 'Enabled'){throw 'hotspot_unavailable'}
            Await-Operation ($manager.StartTetheringAsync())
            for($n=0;$n -lt 16;$n++) {
                $added=@(Get-NetAdapter -IncludeHidden | Where-Object {$_.Status -eq 'Up' -and $_.InterfaceGuid.ToString() -notin $beforeUp})
                if($added.Count -eq 1){$session.privateGuid=$added[0].InterfaceGuid.ToString();break}
                Start-Sleep -Milliseconds 500
            }
        }
        $valid=$false
        for($n=0;$n -lt 16;$n++){if(Read-Shape){$valid=$true;break};Start-Sleep -Milliseconds 500}
        if(!$valid){throw 'sharing_bypass'}
        $session.tunGuid=$tun.InterfaceGuid.ToString()
        Write-Json $StateFile $session
    }
    $result.on=$manager.TetheringOperationalState.ToString() -eq 'On'
    $result.clients=[int]$manager.ClientCount
    if($result.on -and $tun){$result.throughTun=Read-Shape}
} catch {
    $code=$_.Exception.Message
    $result.error=if($code -match '^(operation_timeout|operation_failed|operation_busy|tun_required|ownership_changed|existing_hotspot|hotspot_unavailable|sharing_bypass)$'){$code}else{'operation_failed'}
    if($Action -in @('enable','repair') -and $result.managed -and $manager) {
        try {
            Stop-OwnedHotspot
            $session.active=$false
            Write-Json $StateFile $session
            $result.managed=$false
            $result.on=$false
        } catch {$result.error='stop_failed'}
    }
} finally {
    Write-Json $ResultFile $result
    if($locked){$mutex.ReleaseMutex()};$mutex.Dispose()
}
