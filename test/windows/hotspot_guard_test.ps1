$ErrorActionPreference='Stop'
$root=Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$tokens=$null;$errors=$null
$ast=[Management.Automation.Language.Parser]::ParseFile((Join-Path $root 'assets\windows\hotspot.ps1'),[ref]$tokens,[ref]$errors)
if($errors.Count){throw '热点脚本语法错误'}
$function=$ast.Find({param($node) $node -is [Management.Automation.Language.FunctionDefinitionAst] -and $node.Name -eq 'Test-ConflictingSharing'},$true)
$guard=$function.Body.GetScriptBlock()
$tun=[pscustomobject]@{InterfaceIndex=29;Forwarding='Enabled'}
$physical=[pscustomobject]@{InterfaceIndex=12;Forwarding='Disabled'}
if(& $guard @($tun,$physical) 29 $false){throw '回归：热点关闭时，把 TUN 自身转发误判成其他热点'}
if(!(& $guard @($tun,$physical) 29 $true)){throw '没有阻止已开启的未受管热点'}
$physical.Forwarding='Enabled'
if(!(& $guard @($tun,$physical) 29 $false)){throw '没有阻止其他接口的已有共享'}
$tun.Forwarding='Disabled';$physical.Forwarding='Disabled'
if(& $guard @($tun,$physical) 29 $false){throw '没有共享时不应拒绝启动'}
[pscustomobject]@{Cases=4;Passed=$true;ActualFailurePatternCovered=$true}
