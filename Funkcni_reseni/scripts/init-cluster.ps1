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

function Invoke-MongoEval {
    param(
        [string]$Container,
        [int]$Port,
        [string]$Eval,
        [string]$Username = "",
        [string]$Password = "",
        [string]$AuthenticationDatabase = ""
    )

    $args = @("exec", $Container, "mongosh", "--quiet", "--port", "$Port")
    if ($Username) {
        $args += @("--username", $Username, "--password", $Password, "--authenticationDatabase", $AuthenticationDatabase)
    }
    $args += @("--eval", $Eval)

    & docker @args
    if ($LASTEXITCODE -ne 0) {
        throw "mongosh command failed for container '$Container'."
    }
}

function Wait-ForMongo {
    param(
        [string]$Container,
        [int]$Port,
        [int]$Attempts = 60
    )

    for ($i = 1; $i -le $Attempts; $i++) {
        try {
            $result = & docker exec $Container mongosh --quiet --port $Port --eval "db.runCommand({ ping: 1 }).ok"
            if ($LASTEXITCODE -eq 0 -and ($result -match "1")) {
                Write-Host "Mongo container ready: $Container"
                return
            }
        }
        catch {
        }

        Start-Sleep -Seconds 2
    }

    throw "Timed out waiting for Mongo container '$Container' on port $Port."
}

function Wait-ForWritablePrimary {
    param(
        [string]$Container,
        [int]$Port,
        [int]$Attempts = 60
    )

    $eval = "const hello = db.hello(); print(hello.isWritablePrimary || hello.ismaster ? 'PRIMARY' : 'NOT_PRIMARY');"

    for ($i = 1; $i -le $Attempts; $i++) {
        try {
            $result = & docker exec $Container mongosh --quiet --port $Port --eval $eval
            if ($LASTEXITCODE -eq 0 -and ($result -match "PRIMARY")) {
                Write-Host "Replica set primary ready: $Container"
                return
            }
        }
        catch {
        }

        Start-Sleep -Seconds 2
    }

    throw "Timed out waiting for primary on '$Container'."
}

$solutionRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$envPath = Join-Path $solutionRoot ".env"
$envMap = Read-EnvFile -Path $envPath

Push-Location $solutionRoot
try {
    $services = @(
        @{ Name = "configsvr01"; Port = 27017 },
        @{ Name = "configsvr02"; Port = 27017 },
        @{ Name = "configsvr03"; Port = 27017 },
        @{ Name = "shard01a"; Port = 27018 },
        @{ Name = "shard01b"; Port = 27018 },
        @{ Name = "shard01c"; Port = 27018 },
        @{ Name = "shard02a"; Port = 27018 },
        @{ Name = "shard02b"; Port = 27018 },
        @{ Name = "shard02c"; Port = 27018 },
        @{ Name = "shard03a"; Port = 27018 },
        @{ Name = "shard03b"; Port = 27018 },
        @{ Name = "shard03c"; Port = 27018 }
    )

    foreach ($service in $services) {
        Wait-ForMongo -Container $service.Name -Port $service.Port
    }

$configRsInit = @'
try {
  rs.status();
} catch (e) {
  const message = String(e);
  if (message.includes('not authorized') || message.includes('requires authentication')) {
    print('configReplSet already protected by auth.');
  } else {
    rs.initiate({
      _id: 'configReplSet',
      configsvr: true,
      members: [
        { _id: 0, host: 'configsvr01:27017' },
        { _id: 1, host: 'configsvr02:27017' },
        { _id: 2, host: 'configsvr03:27017' }
      ]
    });
  }
}
'@
    Invoke-MongoEval -Container "configsvr01" -Port 27017 -Eval $configRsInit

$shard01Init = @'
try {
  rs.status();
} catch (e) {
  const message = String(e);
  if (message.includes('not authorized') || message.includes('requires authentication')) {
    print('shard01rs already protected by auth.');
  } else {
    rs.initiate({
      _id: 'shard01rs',
      members: [
        { _id: 0, host: 'shard01a:27018' },
        { _id: 1, host: 'shard01b:27018' },
        { _id: 2, host: 'shard01c:27018' }
      ]
    });
  }
}
'@
    Invoke-MongoEval -Container "shard01a" -Port 27018 -Eval $shard01Init

$shard02Init = @'
try {
  rs.status();
} catch (e) {
  const message = String(e);
  if (message.includes('not authorized') || message.includes('requires authentication')) {
    print('shard02rs already protected by auth.');
  } else {
    rs.initiate({
      _id: 'shard02rs',
      members: [
        { _id: 0, host: 'shard02a:27018' },
        { _id: 1, host: 'shard02b:27018' },
        { _id: 2, host: 'shard02c:27018' }
      ]
    });
  }
}
'@
    Invoke-MongoEval -Container "shard02a" -Port 27018 -Eval $shard02Init

$shard03Init = @'
try {
  rs.status();
} catch (e) {
  const message = String(e);
  if (message.includes('not authorized') || message.includes('requires authentication')) {
    print('shard03rs already protected by auth.');
  } else {
    rs.initiate({
      _id: 'shard03rs',
      members: [
        { _id: 0, host: 'shard03a:27018' },
        { _id: 1, host: 'shard03b:27018' },
        { _id: 2, host: 'shard03c:27018' }
      ]
    });
  }
}
'@
    Invoke-MongoEval -Container "shard03a" -Port 27018 -Eval $shard03Init

    Wait-ForWritablePrimary -Container "configsvr01" -Port 27017
    Wait-ForWritablePrimary -Container "shard01a" -Port 27018
    Wait-ForWritablePrimary -Container "shard02a" -Port 27018
    Wait-ForWritablePrimary -Container "shard03a" -Port 27018

    $rootUser = $envMap["MONGO_ROOT_USERNAME"]
    $rootPassword = $envMap["MONGO_ROOT_PASSWORD"]
    $appDb = $envMap["MONGO_APP_DB"]
    $appUser = $envMap["MONGO_APP_USERNAME"]
    $appPassword = $envMap["MONGO_APP_PASSWORD"]

    $ensureRootUser = @"
const adminDb = db.getSiblingDB('admin');
try {
  adminDb.createUser({
    user: '$rootUser',
    pwd: '$rootPassword',
    roles: [{ role: 'root', db: 'admin' }]
  });
} catch (e) {
  const message = String(e);
  if (
    !message.includes('already exists') &&
    !message.includes('DuplicateKey') &&
    !message.includes('not authorized') &&
    !message.includes('requires authentication')
  ) {
    throw e;
  }
}
print('Root user ensured on config server.');
"@
    Invoke-MongoEval -Container "configsvr01" -Port 27017 -Eval $ensureRootUser

    Start-Sleep -Seconds 5
    Wait-ForMongo -Container "mongos-router" -Port 27017

    $addShards = @'
const existing = db.adminCommand({ listShards: 1 }).shards.map(shard => shard._id);
if (!existing.includes('shard01rs')) {
  sh.addShard('shard01rs/shard01a:27018,shard01b:27018,shard01c:27018');
}
if (!existing.includes('shard02rs')) {
  sh.addShard('shard02rs/shard02a:27018,shard02b:27018,shard02c:27018');
}
if (!existing.includes('shard03rs')) {
  sh.addShard('shard03rs/shard03a:27018,shard03b:27018,shard03c:27018');
}
printjson(db.adminCommand({ listShards: 1 }));
'@
    Invoke-MongoEval `
        -Container "mongos-router" `
        -Port 27017 `
        -Eval $addShards `
        -Username $rootUser `
        -Password $rootPassword `
        -AuthenticationDatabase "admin"

    $createAppUser = @"
const appDb = db.getSiblingDB('$appDb');
if (!appDb.getUser('$appUser')) {
  appDb.createUser({
    user: '$appUser',
    pwd: '$appPassword',
    roles: [{ role: 'readWrite', db: '$appDb' }]
  });
}
print('Application user ensured.');
"@
    Invoke-MongoEval `
        -Container "mongos-router" `
        -Port 27017 `
        -Eval $createAppUser `
        -Username $rootUser `
        -Password $rootPassword `
        -AuthenticationDatabase "admin"

    Write-Host ""
    Write-Host "Cluster initialization completed."
    Write-Host "Next step: run .\\scripts\\import-data.ps1"
}
finally {
    Pop-Location
}
