param(
    [string]$OutputDir,
    [switch]$SimulateFailover,
    [string]$ReplicaSet = "shard01rs",
    [int]$FailoverTimeoutSeconds = 120
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Read-EnvFile {
    param([string]$Path)

    $result = @{}
    if (-not (Test-Path -LiteralPath $Path)) {
        return $result
    }

    Get-Content -LiteralPath $Path | ForEach-Object {
        $line = $_.Trim()
        if (-not $line -or $line.StartsWith("#")) {
            return
        }

        $parts = $line.Split("=", 2)
        if ($parts.Count -eq 2) {
            $result[$parts[0]] = $parts[1]
        }
    }

    return $result
}

function Get-EnvOrDefault {
    param(
        [hashtable]$Map,
        [string]$Name,
        [string]$Default
    )

    if ($Map.ContainsKey($Name) -and $Map[$Name]) {
        return $Map[$Name]
    }

    return $Default
}

function Invoke-DockerCapture {
    param([string[]]$Arguments)

    $outputLines = & docker @Arguments 2>&1
    $exitCode = $LASTEXITCODE
    $output = ($outputLines | Out-String).TrimEnd()

    if ($exitCode -ne 0) {
        throw "docker command failed: $($Arguments -join ' ')`n$output"
    }

    return $output
}

function Write-EvidenceFile {
    param(
        [string]$RelativePath,
        [string]$Content
    )

    $targetPath = Join-Path $evidenceRoot $RelativePath
    $parentDir = Split-Path -Parent $targetPath
    if (-not (Test-Path -LiteralPath $parentDir)) {
        New-Item -ItemType Directory -Path $parentDir -Force | Out-Null
    }

    Set-Content -LiteralPath $targetPath -Value $Content -Encoding utf8
}

function Format-Json {
    param($Value)
    return ($Value | ConvertTo-Json -Depth 20)
}

function Extract-JsonPayload {
    param([string]$RawOutput)

    $startMarker = "__JSON_START__"
    $endMarker = "__JSON_END__"
    $startIndex = $RawOutput.IndexOf($startMarker)
    $endIndex = $RawOutput.IndexOf($endMarker)

    if ($startIndex -lt 0 -or $endIndex -lt 0 -or $endIndex -le $startIndex) {
        throw "Could not find JSON markers in mongosh output.`n$RawOutput"
    }

    $payloadStart = $startIndex + $startMarker.Length
    $payload = $RawOutput.Substring($payloadStart, $endIndex - $payloadStart).Trim()
    $cleanLines = foreach ($line in ($payload -split "`r?`n")) {
        $line -replace '^.*?>\s*(\|\s*)*', ''
    }

    return (($cleanLines -join "`n").Trim())
}

function Invoke-MongosEval {
    param([string]$Eval)

    $outputLines = $Eval | & docker exec -i `
        mongos-router `
        mongosh `
        --quiet `
        --port 27017 `
        --username $rootUser `
        --password $rootPassword `
        --authenticationDatabase admin 2>&1
    $exitCode = $LASTEXITCODE
    $output = ($outputLines | Out-String).TrimEnd()

    if ($exitCode -ne 0) {
        throw "mongosh command failed on mongos-router.`n$output"
    }

    return $output
}

function Invoke-NodeEval {
    param(
        [string]$Container,
        [int]$Port,
        [string]$Eval,
        [switch]$UseAuth
    )

    $dockerArgs = @("exec", "-i", $Container, "mongosh", "--quiet", "--port", [string]$Port)
    if ($UseAuth) {
        $dockerArgs += @(
            "--username", $rootUser,
            "--password", $rootPassword,
            "--authenticationDatabase", "admin"
        )
    }

    $outputLines = $Eval | & docker @dockerArgs 2>&1
    $exitCode = $LASTEXITCODE
    $output = ($outputLines | Out-String).TrimEnd()

    if ($exitCode -ne 0) {
        throw "mongosh command failed on $Container.`n$output"
    }

    return $output
}

function Invoke-NodeJson {
    param(
        [string]$Container,
        [int]$Port,
        [string]$Expression,
        [switch]$UseAuth
    )

    $raw = Invoke-NodeEval -Container $Container -Port $Port -UseAuth:$UseAuth -Eval @"
print("__JSON_START__");
print(JSON.stringify(($Expression), null, 2));
print("__JSON_END__");
"@
    return (Extract-JsonPayload -RawOutput $raw) | ConvertFrom-Json
}

function Invoke-MongosJson {
    param([string]$Expression)

    $raw = Invoke-MongosEval -Eval @"
print("__JSON_START__");
print(JSON.stringify(($Expression), null, 2));
print("__JSON_END__");
"@
    return (Extract-JsonPayload -RawOutput $raw) | ConvertFrom-Json
}

function Get-ReplicaSetMembers {
    param([string]$ReplicaSetName)

    $replicaSetConfig = $replicaSets[$ReplicaSetName]
    foreach ($node in $replicaSetConfig.Nodes) {
        try {
            return Invoke-NodeJson -Container $node -Port $replicaSetConfig.Port -Expression @"
rs.status().members.map(member => ({
  name: member.name,
  stateStr: member.stateStr,
  health: member.health,
  uptime: member.uptime
}))
"@ -UseAuth:($replicaSetConfig.UseAuth)
        }
        catch {
            continue
        }
    }

    throw "Could not read replica set status for $ReplicaSetName."
}

function Get-ReplicaSetPrimary {
    param([string]$ReplicaSetName)

    $members = Get-ReplicaSetMembers -ReplicaSetName $ReplicaSetName
    return $members | Where-Object { $_.stateStr -eq "PRIMARY" } | Select-Object -First 1
}

function Wait-ForCondition {
    param(
        [scriptblock]$Condition,
        [int]$TimeoutSeconds,
        [string]$Description
    )

    $deadline = (Get-Date).AddSeconds($TimeoutSeconds)
    while ((Get-Date) -lt $deadline) {
        if (& $Condition) {
            return
        }
        Start-Sleep -Seconds 2
    }

    throw "Timed out while waiting for: $Description"
}

function Test-ClusterHealth {
    $ping = Invoke-MongosJson -Expression 'db.runCommand({ ping: 1 })'
    if ($ping.ok -ne 1) {
        throw "Ping check failed."
    }

    $counts = Invoke-MongosJson -Expression @'
(() => {
  const dbx = db.getSiblingDB("statsbomb");
  return {
    matches: dbx.matches.countDocuments(),
    players: dbx.players.countDocuments(),
    events: dbx.events.countDocuments()
  };
})()
'@

    if ($counts.events -lt 5000) {
        throw "Events collection contains fewer than 5000 records."
    }

    return @{
        Ping = $ping
        Counts = $counts
    }
}

function Test-MongoExpress {
    $pair = "${mongoExpressUser}:${mongoExpressPassword}"
    $encoded = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes($pair))
    $uri = "http://localhost:$mongoExpressPort"

    try {
        $response = Invoke-WebRequest `
            -Uri $uri `
            -Headers @{ Authorization = "Basic $encoded" } `
            -UseBasicParsing `
            -TimeoutSec 15

        return @{
            url = $uri
            statusCode = [int]$response.StatusCode
            reachable = $true
        }
    }
    catch {
        throw "mongo-express availability check failed at ${uri}: $($_.Exception.Message)"
    }
}

$solutionRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$envPath = Join-Path $solutionRoot ".env"
$envMap = Read-EnvFile -Path $envPath

$rootUser = Get-EnvOrDefault -Map $envMap -Name "MONGO_ROOT_USERNAME" -Default "admin"
$rootPassword = Get-EnvOrDefault -Map $envMap -Name "MONGO_ROOT_PASSWORD" -Default "admin123"
$mongoExpressPort = Get-EnvOrDefault -Map $envMap -Name "MONGO_EXPRESS_PORT" -Default "8081"
$mongoExpressUser = Get-EnvOrDefault -Map $envMap -Name "MONGO_EXPRESS_BASICAUTH_USERNAME" -Default "admin"
$mongoExpressPassword = Get-EnvOrDefault -Map $envMap -Name "MONGO_EXPRESS_BASICAUTH_PASSWORD" -Default "admin123"

$replicaSets = @{
    "configReplSet" = @{
        Nodes = @("configsvr01", "configsvr02", "configsvr03")
        Port = 27017
        UseAuth = $true
    }
    "shard01rs" = @{
        Nodes = @("shard01a", "shard01b", "shard01c")
        Port = 27018
        UseAuth = $false
    }
    "shard02rs" = @{
        Nodes = @("shard02a", "shard02b", "shard02c")
        Port = 27018
        UseAuth = $false
    }
    "shard03rs" = @{
        Nodes = @("shard03a", "shard03b", "shard03c")
        Port = 27018
        UseAuth = $false
    }
}

if (-not $OutputDir) {
    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $OutputDir = Join-Path $solutionRoot "evidence\$timestamp"
}

$evidenceRoot = Resolve-Path -LiteralPath (New-Item -ItemType Directory -Path $OutputDir -Force)

Write-Host "Evidence directory: $evidenceRoot"
Write-Host "Running cluster self-check..."

$dockerPs = Invoke-DockerCapture -Arguments @("compose", "ps")
Write-EvidenceFile -RelativePath "docker-compose-ps.txt" -Content $dockerPs

$clusterHealth = Test-ClusterHealth
$mongoExpressHealth = Test-MongoExpress
Write-EvidenceFile -RelativePath "summary\counts.json" -Content (Format-Json $clusterHealth.Counts)
Write-EvidenceFile -RelativePath "summary\mongo-express.json" -Content (Format-Json $mongoExpressHealth)

$buildInfo = Invoke-MongosJson -Expression 'db.runCommand({ buildInfo: 1 })'
$dbStats = Invoke-MongosJson -Expression @'
(() => {
  const s = db.getSiblingDB("statsbomb").stats();
  return {
    db: s.db,
    collections: s.collections,
    objects: s.objects,
    avgObjSize: s.avgObjSize,
    dataSize: s.dataSize,
    storageSize: s.storageSize,
    indexes: s.indexes,
    indexSize: s.indexSize,
    totalSize: s.totalSize
  };
})()
'@
$eventsStats = Invoke-MongosJson -Expression @'
(() => {
  const s = db.getSiblingDB("statsbomb").events.stats();
  return {
    ns: s.ns,
    sharded: s.sharded,
    count: s.count,
    avgObjSize: s.avgObjSize,
    nindexes: s.nindexes,
    totalIndexSize: s.totalIndexSize,
    indexSizes: s.indexSizes
  };
})()
'@
$indexes = Invoke-MongosJson -Expression 'db.getSiblingDB("statsbomb").events.getIndexes().map(index => ({ name: index.name, key: index.key, version: index.v }))'
$adminUsers = Invoke-MongosJson -Expression 'db.getSiblingDB("admin").getUsers().users'

Write-EvidenceFile -RelativePath "summary\build-info.json" -Content (Format-Json @{
    version = $buildInfo.version
    gitVersion = $buildInfo.gitVersion
})
Write-EvidenceFile -RelativePath "summary\db-stats.json" -Content (Format-Json $dbStats)
Write-EvidenceFile -RelativePath "summary\events-stats.json" -Content (Format-Json $eventsStats)
Write-EvidenceFile -RelativePath "summary\indexes.json" -Content (Format-Json $indexes)
Write-EvidenceFile -RelativePath "summary\admin-users.json" -Content (Format-Json $adminUsers)

$shStatusRaw = Invoke-MongosEval -Eval "sh.status()"
$distributionRaw = Invoke-MongosEval -Eval 'db.getSiblingDB("statsbomb").events.getShardDistribution()'
$connectionStatusRaw = Invoke-MongosEval -Eval 'db.adminCommand({ connectionStatus: 1, showPrivileges: false })'
$configCollectionsRaw = Invoke-MongosEval -Eval 'db.getSiblingDB("config").collections.find({}, { _id: 1, key: 1, unique: 1, lastmodEpoch: 1 }).toArray()'

Write-EvidenceFile -RelativePath "cluster\sh-status.txt" -Content $shStatusRaw
Write-EvidenceFile -RelativePath "cluster\events-shard-distribution.txt" -Content $distributionRaw
Write-EvidenceFile -RelativePath "cluster\connection-status.txt" -Content $connectionStatusRaw
Write-EvidenceFile -RelativePath "cluster\config-collections.txt" -Content $configCollectionsRaw

$replicaSetSnapshots = @{}
foreach ($replicaSetName in $replicaSets.Keys) {
    $members = Get-ReplicaSetMembers -ReplicaSetName $replicaSetName
    $replicaSetSnapshots[$replicaSetName] = $members
    Write-EvidenceFile -RelativePath "replica-sets\$replicaSetName-members.json" -Content (Format-Json $members)
}

$summary = [ordered]@{
    mongoVersion = $buildInfo.version
    counts = $clusterHealth.Counts
    replicaSets = @{}
    evidenceRoot = "$evidenceRoot"
}

foreach ($replicaSetName in $replicaSetSnapshots.Keys) {
    $summary.replicaSets[$replicaSetName] = $replicaSetSnapshots[$replicaSetName]
}

if ($SimulateFailover) {
    Write-Host "Simulating failover on $ReplicaSet..."

    $primaryBefore = Get-ReplicaSetPrimary -ReplicaSetName $ReplicaSet
    if (-not $primaryBefore) {
        throw "Could not determine the current primary for $ReplicaSet."
    }

    $primaryContainer = ($primaryBefore.name -split ":")[0]
    Write-Host "Stopping current primary: $primaryContainer"
    Write-EvidenceFile -RelativePath "failover\$ReplicaSet-before.json" -Content (Format-Json (Get-ReplicaSetMembers -ReplicaSetName $ReplicaSet))

    Invoke-DockerCapture -Arguments @("stop", $primaryContainer) | Out-Null

    Wait-ForCondition -TimeoutSeconds $FailoverTimeoutSeconds -Description "new primary election for $ReplicaSet" -Condition {
        try {
            $newPrimary = Get-ReplicaSetPrimary -ReplicaSetName $ReplicaSet
            return $null -ne $newPrimary -and $newPrimary.name -ne $primaryBefore.name
        }
        catch {
            return $false
        }
    }

    $afterStopMembers = Get-ReplicaSetMembers -ReplicaSetName $ReplicaSet
    $primaryAfter = $afterStopMembers | Where-Object { $_.stateStr -eq "PRIMARY" } | Select-Object -First 1
    Write-EvidenceFile -RelativePath "failover\$ReplicaSet-after-stop.json" -Content (Format-Json $afterStopMembers)

    Write-Host "New primary after failover: $($primaryAfter.name)"
    Write-Host "Starting stopped node again: $primaryContainer"
    Invoke-DockerCapture -Arguments @("start", $primaryContainer) | Out-Null

    Wait-ForCondition -TimeoutSeconds $FailoverTimeoutSeconds -Description "recovery of $primaryContainer" -Condition {
        try {
            $members = Get-ReplicaSetMembers -ReplicaSetName $ReplicaSet
            $recovered = $members | Where-Object { $_.name -like "${primaryContainer}:*" } | Select-Object -First 1
            return $null -ne $recovered -and $recovered.health -eq 1 -and $recovered.stateStr -in @("SECONDARY", "PRIMARY")
        }
        catch {
            return $false
        }
    }

    $afterRecoveryMembers = Get-ReplicaSetMembers -ReplicaSetName $ReplicaSet
    Write-EvidenceFile -RelativePath "failover\$ReplicaSet-after-recovery.json" -Content (Format-Json $afterRecoveryMembers)

    $summary["failover"] = @{
        replicaSet = $ReplicaSet
        primaryBefore = $primaryBefore.name
        primaryAfter = $primaryAfter.name
        recoveredNode = $primaryContainer
    }
}

Write-EvidenceFile -RelativePath "summary\run-summary.json" -Content (Format-Json $summary)

Write-Host ""
Write-Host "Self-check completed successfully."
Write-Host "MongoDB version: $($buildInfo.version)"
Write-Host "Counts: matches=$($clusterHealth.Counts.matches), players=$($clusterHealth.Counts.players), events=$($clusterHealth.Counts.events)"
Write-Host "mongo-express: $($mongoExpressHealth.url), HTTP $($mongoExpressHealth.statusCode)"
if ($SimulateFailover) {
    Write-Host "Failover scenario completed for $ReplicaSet."
}
Write-Host "Evidence saved to: $evidenceRoot"
