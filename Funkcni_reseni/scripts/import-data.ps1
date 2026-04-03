Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Read-EnvFile {
    param([string]$Path)

    $result = @{}
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

function Invoke-DockerCommand {
    param([string[]]$Arguments)

    & docker @Arguments
    if ($LASTEXITCODE -ne 0) {
        throw "docker command failed: $($Arguments -join ' ')"
    }
}

$solutionRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$projectRoot = Resolve-Path (Join-Path $solutionRoot "..")
$envPath = Join-Path $solutionRoot ".env"
$envMap = Read-EnvFile -Path $envPath

$dbName = $envMap["MONGO_APP_DB"]
$rootUser = $envMap["MONGO_ROOT_USERNAME"]
$rootPassword = $envMap["MONGO_ROOT_PASSWORD"]

$processedDir = Join-Path $projectRoot "Data\\processed"
$requiredFiles = @("matches.json", "players.json", "events.json")

foreach ($fileName in $requiredFiles) {
    $fullPath = Join-Path $processedDir $fileName
    if (-not (Test-Path -LiteralPath $fullPath)) {
        throw "Required processed dataset not found: $fullPath"
    }
}

Push-Location $solutionRoot
try {
    Invoke-DockerCommand -Arguments @(
        "exec", "mongos-router",
        "mongoimport",
        "--host", "localhost",
        "--port", "27017",
        "--username", $rootUser,
        "--password", $rootPassword,
        "--authenticationDatabase", "admin",
        "--db", $dbName,
        "--collection", "matches",
        "--file", "/import/matches.json",
        "--jsonArray",
        "--drop"
    )

    Invoke-DockerCommand -Arguments @(
        "exec", "mongos-router",
        "mongoimport",
        "--host", "localhost",
        "--port", "27017",
        "--username", $rootUser,
        "--password", $rootPassword,
        "--authenticationDatabase", "admin",
        "--db", $dbName,
        "--collection", "players",
        "--file", "/import/players.json",
        "--jsonArray",
        "--drop"
    )

    Invoke-DockerCommand -Arguments @(
        "exec", "mongos-router",
        "mongoimport",
        "--host", "localhost",
        "--port", "27017",
        "--username", $rootUser,
        "--password", $rootPassword,
        "--authenticationDatabase", "admin",
        "--db", $dbName,
        "--collection", "events",
        "--file", "/import/events.json",
        "--jsonArray",
        "--drop"
    )

    $postImportEval = @"
const adminDb = db.getSiblingDB('admin');
adminDb.auth('$rootUser', '$rootPassword');
const appDb = db.getSiblingDB('$dbName');
appDb.matches.createIndex({ match_id: 1 }, { unique: true, name: 'ux_match_id' });
appDb.players.createIndex({ player_id: 1 }, { unique: true, name: 'ux_player_id' });
appDb.events.createIndex({ event_id: 'hashed' }, { name: 'ix_events_event_id_hashed' });
appDb.events.createIndex({ match_id: 1 }, { name: 'ix_events_match_id' });
appDb.events.createIndex({ player_id: 1 }, { name: 'ix_events_player_id' });
appDb.events.createIndex({ team_id: 1, event_type_name: 1 }, { name: 'ix_events_team_type' });
appDb.events.createIndex({ season: 1, minute: 1 }, { name: 'ix_events_season_minute' });
sh.enableSharding('$dbName');
try {
  sh.shardCollection('$dbName.events', { event_id: 'hashed' });
} catch (e) {
  if (!String(e).includes('already sharded')) {
    throw e;
  }
}
printjson(appDb.runCommand({ collStats: 'events' }));
"@

    Invoke-DockerCommand -Arguments @(
        "exec", "mongos-router",
        "mongosh",
        "--quiet",
        "--port", "27017",
        "--username", $rootUser,
        "--password", $rootPassword,
        "--authenticationDatabase", "admin",
        "--eval", $postImportEval
    )

    Write-Host ""
    Write-Host "Data import completed."
    Write-Host "Collections: matches, players, events"
}
finally {
    Pop-Location
}
