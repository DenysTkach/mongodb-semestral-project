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

function Invoke-MongoshEval {
    param([string]$Eval)

    Invoke-DockerCommand -Arguments @(
        "exec", "mongos-router",
        "mongosh",
        "--quiet",
        "--port", "27017",
        "--username", $rootUser,
        "--password", $rootPassword,
        "--authenticationDatabase", "admin",
        "--eval", $Eval
    )
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

    $prepareEventsCollection = @"
const dbName = '$dbName';
const appDb = db.getSiblingDB(dbName);

try {
  appDb.events.drop();
} catch (e) {
  const message = String(e);
  if (
    !message.includes('ns not found') &&
    !message.includes('NamespaceNotFound')
  ) {
    throw e;
  }
}

sh.enableSharding(dbName);
sh.shardCollection(
  dbName + '.events',
  { event_id: 'hashed' }
);
"@
    Invoke-MongoshEval -Eval $prepareEventsCollection

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
        "--jsonArray"
    )

    Invoke-DockerCommand -Arguments @(
        "exec", "mongos-router",
        "mongosh",
        "--quiet",
        "--port", "27017",
        "--username", $rootUser,
        "--password", $rootPassword,
        "--authenticationDatabase", "admin",
        "--eval", "globalThis.APP_DB = '$dbName';",
        "/workspace/scripts/mongo/post-import-setup.js"
    )

    Write-Host ""
    Write-Host "Data import completed."
    Write-Host "Collections: matches, players, events"
}
finally {
    Pop-Location
}
