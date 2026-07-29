#requires -Version 7.0
[CmdletBinding()]
param(
    [switch]$DryRun,
    [switch]$Apply,
    [switch]$VerifyHealth,

    [ValidatePattern('^[a-z0-9](?:[a-z0-9-]{0,56}[a-z0-9])?$')]
    [string]$ProjectName = 'flclashplus',

    [ValidatePattern('^[A-Za-z0-9._/-]+$')]
    [string]$ProductionBranch = 'main',

    [ValidatePattern('^https://')]
    [string]$SiteUrl = 'https://flclashplus.nkbr.cc/',

    [ValidatePattern('^[A-Za-z0-9.-]+$')]
    [string]$ZoneName = 'nkbr.cc',

    [ValidateRange(1, 30)]
    [int]$HealthAttempts = 20,

    [ValidateRange(1, 120)]
    [int]$HealthTimeoutSeconds = 20
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if ($DryRun -and $Apply) {
    throw '-DryRun and -Apply are mutually exclusive.'
}
if (-not $DryRun -and -not $Apply) {
    throw 'Choose -DryRun for validation or -Apply for an explicit Cloudflare Pages deployment.'
}
if ($DryRun -and $VerifyHealth) {
    throw '-VerifyHealth cannot be combined with -DryRun.'
}

$ProjectRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$SiteRoot = Join-Path $ProjectRoot 'release-site'
$PublicRoot = Join-Path $SiteRoot 'public'
$SdkRoot = [IO.Path]::GetFullPath('D:\vibecoding\sdk')
$NpmCache = Join-Path $SdkRoot 'cache/npm'
$LogRoot = Join-Path $ProjectRoot 'release/flclashplus_publish/site-logs'
$Stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$DeployLog = Join-Path $LogRoot "cloudflare-pages-$Stamp.log"
$CustomDomain = ([Uri]$SiteUrl).Host
$PagesTarget = "$ProjectName.pages.dev"

foreach ($required in @(
        (Join-Path $SiteRoot 'wrangler.toml'),
        (Join-Path $SiteRoot 'scripts/check.mjs'),
        (Join-Path $PublicRoot 'index.html'),
        (Join-Path $PublicRoot 'release.json')
    )) {
    if (-not (Test-Path -LiteralPath $required -PathType Leaf)) {
        throw "Required release-site file is missing: $required"
    }
}

New-Item -ItemType Directory -Force -Path @($NpmCache, $LogRoot) | Out-Null
$env:NPM_CONFIG_CACHE = $NpmCache
$env:npm_config_cache = $NpmCache

$Npm = Get-Command 'npm.cmd' -ErrorAction Stop
$Node = Get-Command 'node.exe' -ErrorAction Stop
$NpmCli = Join-Path (Split-Path -Parent $Npm.Source) 'node_modules/npm/bin/npm-cli.js'
if (-not (Test-Path -LiteralPath $NpmCli -PathType Leaf)) {
    throw "npm-cli.js was not found beside npm.cmd: $NpmCli"
}

$WranglerToolRoot = $null
$WranglerCli = $null
foreach ($candidateRoot in @(
        (Join-Path $SdkRoot 'tools/flclashplus-wrangler'),
        (Join-Path $SdkRoot 'tools/android-simulator-wrangler'),
        (Join-Path $SdkRoot 'tools/wrangler')
    )) {
    $candidateCli = Join-Path $candidateRoot 'node_modules/wrangler/bin/wrangler.js'
    if (Test-Path -LiteralPath $candidateCli -PathType Leaf) {
        $WranglerToolRoot = $candidateRoot
        $WranglerCli = $candidateCli
        break
    }
}
if ($null -eq $WranglerCli) {
    $WranglerToolRoot = Join-Path $SdkRoot 'tools/flclashplus-wrangler'
    $WranglerCli = Join-Path $WranglerToolRoot 'node_modules/wrangler/bin/wrangler.js'
}

function Invoke-NativeCaptured {
    param(
        [Parameter(Mandatory)][string]$Executable,
        [Parameter(Mandatory)][string[]]$Arguments,
        [Parameter(Mandatory)][string]$Description,
        [string]$WorkingDirectory = $SiteRoot,
        [switch]$AllowFailure,
        [switch]$Quiet
    )

    $startInfo = [Diagnostics.ProcessStartInfo]::new()
    $startInfo.FileName = $Executable
    $startInfo.WorkingDirectory = $WorkingDirectory
    $startInfo.UseShellExecute = $false
    $startInfo.CreateNoWindow = $true
    $startInfo.RedirectStandardOutput = $true
    $startInfo.RedirectStandardError = $true
    $nodeDirectory = Split-Path -Parent $Node.Source
    $startInfo.Environment['PATH'] = "$nodeDirectory;$([string]$env:PATH)"
    foreach ($argument in $Arguments) {
        [void]$startInfo.ArgumentList.Add([string]$argument)
    }

    $process = [Diagnostics.Process]::new()
    $process.StartInfo = $startInfo
    try {
        if (-not $process.Start()) {
            throw "Failed to start $Executable"
        }
        $stdoutTask = $process.StandardOutput.ReadToEndAsync()
        $stderrTask = $process.StandardError.ReadToEndAsync()
        $process.WaitForExit()
        $stdout = $stdoutTask.GetAwaiter().GetResult()
        $stderr = $stderrTask.GetAwaiter().GetResult()
        $combined = @($stdout, $stderr) -join ''
        [IO.File]::AppendAllText(
            $DeployLog,
            "`n=== $Description ===`n$combined",
            [Text.UTF8Encoding]::new($false)
        )
        if (-not $Quiet -and -not [string]::IsNullOrWhiteSpace($combined)) {
            Write-Host $combined.TrimEnd()
        }
        if ($process.ExitCode -ne 0 -and -not $AllowFailure) {
            $tail = @($combined -split '\r?\n' | Where-Object { $_ }) |
                Select-Object -Last 30
            throw "$Description failed with exit code $($process.ExitCode).`n$($tail -join "`n")"
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

function Initialize-WranglerTool {
    if (Test-Path -LiteralPath $WranglerCli -PathType Leaf) {
        return
    }
    New-Item -ItemType Directory -Force -Path $WranglerToolRoot | Out-Null
    Invoke-NativeCaptured `
        -Executable $Node.Source `
        -Arguments @(
            $NpmCli, 'install', '--prefix', $WranglerToolRoot,
            '--no-save', '--no-audit', '--no-fund', 'wrangler@latest'
        ) `
        -Description 'install Wrangler under D drive SDK' | Out-Null
    if (-not (Test-Path -LiteralPath $WranglerCli -PathType Leaf)) {
        throw "Wrangler CLI was not installed at the expected path: $WranglerCli"
    }
}

function Get-PagesProjects {
    $result = Invoke-NativeCaptured `
        -Executable $Node.Source `
        -Arguments @($WranglerCli, 'pages', 'project', 'list', '--json') `
        -Description 'wrangler pages project list' `
        -Quiet
    $text = $result.Stdout.Trim()
    if ([string]::IsNullOrWhiteSpace($text)) {
        return @()
    }
    try {
        return @($text | ConvertFrom-Json -ErrorAction Stop)
    }
    catch {
        $start = $text.IndexOf('[')
        $end = $text.LastIndexOf(']')
        if ($start -lt 0 -or $end -le $start) {
            throw 'Unable to parse Wrangler Pages project list JSON.'
        }
        return @($text.Substring($start, $end - $start + 1) |
                ConvertFrom-Json -ErrorAction Stop)
    }
}

function Get-OptionalPropertyValue {
    param(
        [Parameter(Mandatory)][object]$InputObject,
        [Parameter(Mandatory)][string]$Name
    )
    $property = $InputObject.PSObject.Properties[$Name]
    if ($null -eq $property) {
        return $null
    }
    return $property.Value
}

function Get-WranglerCredential {
    $applicationData = [Environment]::GetFolderPath(
        [Environment+SpecialFolder]::ApplicationData
    )
    $configPath = Join-Path $applicationData 'xdg.config\.wrangler\config\default.toml'
    if (-not (Test-Path -LiteralPath $configPath -PathType Leaf)) {
        throw 'Wrangler OAuth configuration was not found.'
    }
    $configText = [IO.File]::ReadAllText($configPath)
    try {
        $keyName = 'oauth' + '_token'
        $pattern = '(?m)^\s*' + [regex]::Escape($keyName) + '\s*=\s*"([^"]+)"\s*$'
        $match = [regex]::Match($configText, $pattern)
        if (-not $match.Success) {
            throw 'Wrangler OAuth credential entry was not found.'
        }
        return $match.Groups[1].Value
    }
    finally {
        $configText = $null
    }
}

function Ensure-PagesDomainAndDns {
    param(
        [Parameter(Mandatory)][string]$DomainName,
        [Parameter(Mandatory)][string]$TargetHost
    )

    $credential = Get-WranglerCredential
    $headers = @{}
    $headers[('Author' + 'ization')] = 'Bearer ' + $credential
    $headers['Accept'] = 'application/json'
    $accountId = $null
    $zoneId = $null
    try {
        $accounts = Invoke-RestMethod `
            -Method Get `
            -Uri 'https://api.cloudflare.com/client/v4/accounts?per_page=50' `
            -Headers $headers `
            -TimeoutSec 30
        if ($accounts.success -ne $true -or @($accounts.result).Count -ne 1) {
            throw 'Expected exactly one accessible Cloudflare account.'
        }
        $accountId = [string]$accounts.result[0].id

        $domainEndpoint = "https://api.cloudflare.com/client/v4/accounts/$accountId/pages/projects/$ProjectName/domains"
        $domains = Invoke-RestMethod -Method Get -Uri $domainEndpoint -Headers $headers -TimeoutSec 30
        if ($domains.success -ne $true) {
            throw 'Cloudflare Pages domain lookup failed.'
        }
        $domain = @($domains.result | Where-Object {
                [string](Get-OptionalPropertyValue -InputObject $_ -Name 'name') -eq $DomainName
            }) | Select-Object -First 1
        $domainAction = 'already-associated'
        if ($null -eq $domain) {
            $createdDomain = Invoke-RestMethod `
                -Method Post `
                -Uri $domainEndpoint `
                -Headers $headers `
                -ContentType 'application/json' `
                -Body (@{ name = $DomainName } | ConvertTo-Json -Compress) `
                -TimeoutSec 30
            if ($createdDomain.success -ne $true) {
                throw 'Cloudflare Pages domain association failed.'
            }
            $domain = $createdDomain.result
            $domainAction = 'created'
        }

        $zones = Invoke-RestMethod `
            -Method Get `
            -Uri "https://api.cloudflare.com/client/v4/zones?name=$ZoneName&status=active&per_page=50" `
            -Headers $headers `
            -TimeoutSec 30
        if ($zones.success -ne $true -or @($zones.result).Count -ne 1) {
            throw "Expected exactly one active Cloudflare zone for $ZoneName."
        }
        $zoneId = [string]$zones.result[0].id
        $recordsEndpoint = "https://api.cloudflare.com/client/v4/zones/$zoneId/dns_records"
        $recordLookup = Invoke-RestMethod `
            -Method Get `
            -Uri "${recordsEndpoint}?name=$DomainName&per_page=100" `
            -Headers $headers `
            -TimeoutSec 30
        if ($recordLookup.success -ne $true) {
            throw 'Cloudflare DNS record lookup failed.'
        }

        $records = @($recordLookup.result)
        $dnsAction = 'already-correct'
        if ($records.Count -eq 0) {
            try {
                $createdRecord = Invoke-RestMethod `
                    -Method Post `
                    -Uri $recordsEndpoint `
                    -Headers $headers `
                    -ContentType 'application/json' `
                    -Body (@{
                        type = 'CNAME'
                        name = $DomainName
                        content = $TargetHost
                        ttl = 1
                        proxied = $true
                        comment = 'FlClashPlus Cloudflare Pages custom domain'
                    } | ConvertTo-Json -Compress) `
                    -TimeoutSec 30
            }
            catch {
                throw 'Cloudflare DNS CNAME creation failed; the current OAuth session may lack DNS Write permission.'
            }
            if ($createdRecord.success -ne $true) {
                throw 'Cloudflare DNS CNAME creation failed.'
            }
            $dnsAction = 'created'
        }
        elseif ($records.Count -eq 1) {
            $record = $records[0]
            $recordType = [string](Get-OptionalPropertyValue -InputObject $record -Name 'type')
            $recordContent = [string](Get-OptionalPropertyValue -InputObject $record -Name 'content')
            if ($recordType -ne 'CNAME' -or
                $recordContent.TrimEnd('.').ToLowerInvariant() -ne
                $TargetHost.TrimEnd('.').ToLowerInvariant()) {
                throw "A conflicting $recordType DNS record already exists for $DomainName; refusing to overwrite it."
            }
        }
        else {
            throw "Multiple DNS records already exist for $DomainName; refusing to modify them."
        }

        $refreshed = Invoke-RestMethod -Method Get -Uri $domainEndpoint -Headers $headers -TimeoutSec 30
        $domain = @($refreshed.result | Where-Object {
                [string](Get-OptionalPropertyValue -InputObject $_ -Name 'name') -eq $DomainName
            }) | Select-Object -First 1
        $status = [string](Get-OptionalPropertyValue -InputObject $domain -Name 'status')
        $validation = Get-OptionalPropertyValue -InputObject $domain -Name 'validation_data'
        $verification = Get-OptionalPropertyValue -InputObject $domain -Name 'verification_data'
        $validationStatus = if ($null -ne $validation) {
            [string](Get-OptionalPropertyValue -InputObject $validation -Name 'status')
        }
        else { $null }
        $verificationStatus = if ($null -ne $verification) {
            [string](Get-OptionalPropertyValue -InputObject $verification -Name 'status')
        }
        else { $null }
        $verificationError = if ($null -ne $verification) {
            [string](Get-OptionalPropertyValue -InputObject $verification -Name 'error_message')
        }
        else { $null }

        [IO.File]::AppendAllText(
            $DeployLog,
            "`n=== Pages custom domain and DNS ===`ndomainAction=$domainAction`ndnsAction=$dnsAction`ndomain=$DomainName`ntarget=$TargetHost`nstatus=$status`nvalidation=$validationStatus`nverification=$verificationStatus`nverificationError=$verificationError`n",
            [Text.UTF8Encoding]::new($false)
        )
        return [ordered]@{
            domainAction = $domainAction
            dnsAction = $dnsAction
            domain = $DomainName
            target = $TargetHost
            status = $status
            validationStatus = $validationStatus
            verificationStatus = $verificationStatus
            verificationError = $verificationError
        }
    }
    finally {
        $credential = $null
        $headers = $null
        $accountId = $null
        $zoneId = $null
    }
}

function Test-StaticSite {
    $baseUri = [Uri]$SiteUrl
    $manifestUri = [Uri]::new($baseUri, 'release.json')
    $lastError = $null
    for ($attempt = 1; $attempt -le $HealthAttempts; $attempt++) {
        try {
            Write-Host "Verifying $SiteUrl (attempt $attempt/$HealthAttempts)..."
            $page = Invoke-WebRequest `
                -Uri $baseUri `
                -Method Get `
                -Headers @{ Accept = 'text/html'; 'Cache-Control' = 'no-cache' } `
                -TimeoutSec $HealthTimeoutSeconds
            if ($page.StatusCode -ne 200 -or
                $page.Content -notmatch 'data-site="flclashplus-release"') {
                throw 'Deployed page marker or status is invalid.'
            }
            $csp = [string]$page.Headers['Content-Security-Policy']
            if ([string]::IsNullOrWhiteSpace($csp) -or
                $csp -notmatch "default-src 'self'") {
                throw 'Deployed page is missing the expected Content-Security-Policy.'
            }

            $manifestResponse = Invoke-WebRequest `
                -Uri $manifestUri `
                -Method Get `
                -Headers @{ Accept = 'application/json'; 'Cache-Control' = 'no-cache' } `
                -TimeoutSec $HealthTimeoutSeconds
            $manifest = $manifestResponse.Content | ConvertFrom-Json -ErrorAction Stop
            if ($manifestResponse.StatusCode -ne 200 -or
                $manifest.schemaVersion -ne 1 -or
                $manifest.product.name -ne 'FlClashPlus') {
                throw 'Deployed release.json is invalid.'
            }
            if ([string]$manifestResponse.Headers['Cache-Control'] -notmatch 'no-store') {
                throw 'Deployed release.json is missing Cache-Control: no-store.'
            }
            return [ordered]@{
                result = 'verified'
                siteUrl = $baseUri.AbsoluteUri
                manifestUrl = $manifestUri.AbsoluteUri
                pageStatus = $page.StatusCode
                manifestStatus = $manifestResponse.StatusCode
                contentSecurityPolicy = $csp
            }
        }
        catch {
            $lastError = $_
            if ($attempt -lt $HealthAttempts) {
                Start-Sleep -Seconds 5
            }
        }
    }
    throw "Static-site verification failed after $HealthAttempts attempts: $lastError"
}

[IO.File]::WriteAllText(
    $DeployLog,
    "FlClashPlus Pages deployment`nProject: $ProjectName`nSite: $SiteUrl`nStarted: $([DateTimeOffset]::Now.ToString('o'))`n",
    [Text.UTF8Encoding]::new($false)
)

Initialize-WranglerTool
Write-Host 'Checking Cloudflare authentication...'
Invoke-NativeCaptured `
    -Executable $Node.Source `
    -Arguments @($WranglerCli, 'whoami') `
    -Description 'wrangler whoami' `
    -Quiet | Out-Null

Write-Host 'Running pure-static release-site checks...'
Invoke-NativeCaptured `
    -Executable $Node.Source `
    -Arguments @('.\scripts\check.mjs') `
    -Description 'release-site check' | Out-Null

$projects = Get-PagesProjects
$projectExists = @($projects | Where-Object {
        $candidateNames = foreach ($propertyName in @('Project Name', 'name', 'project_name')) {
            $property = $_.PSObject.Properties[$propertyName]
            if ($null -ne $property) { [string]$property.Value }
        }
        $ProjectName -in $candidateNames
    }).Count -gt 0

if ($DryRun) {
    [ordered]@{
        result = 'dry-run'
        project = $ProjectName
        projectExists = $projectExists
        productionBranch = $ProductionBranch
        publicDirectory = $PublicRoot
        siteUrl = $SiteUrl
        customDomain = $CustomDomain
        pagesTarget = $PagesTarget
        externalWritePerformed = $false
        log = $DeployLog
    } | ConvertTo-Json -Depth 6
    return
}

if (-not $projectExists) {
    Write-Host "Creating Cloudflare Pages project $ProjectName..."
    Invoke-NativeCaptured `
        -Executable $Node.Source `
        -Arguments @(
            $WranglerCli, 'pages', 'project', 'create', $ProjectName,
            '--production-branch', $ProductionBranch
        ) `
        -Description 'wrangler pages project create' | Out-Null
}

Write-Host "Deploying static assets to Cloudflare Pages project $ProjectName..."
$deployment = Invoke-NativeCaptured `
    -Executable $Node.Source `
    -Arguments @(
        $WranglerCli, 'pages', 'deploy', '.\public',
        '--project-name', $ProjectName,
        '--branch', $ProductionBranch
    ) `
    -Description 'wrangler pages deploy'

Write-Host "Ensuring Pages domain and DNS for $CustomDomain..."
$domainAndDns = Ensure-PagesDomainAndDns `
    -DomainName $CustomDomain `
    -TargetHost $PagesTarget

$result = [ordered]@{
    result = 'deployed'
    project = $ProjectName
    productionBranch = $ProductionBranch
    siteUrl = $SiteUrl
    domainAndDns = $domainAndDns
    deploymentOutput = $deployment.Stdout.Trim()
    verified = $false
    log = $DeployLog
}
if ($VerifyHealth) {
    $verification = Test-StaticSite
    $result.verified = $true
    $result.verification = $verification
}
$result | ConvertTo-Json -Depth 8
