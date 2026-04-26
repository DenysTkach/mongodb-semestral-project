# MongoDB Cluster Setup

This folder contains a sharded MongoDB setup for the semestral project.

## Architecture

- `1` sharded MongoDB cluster
- `3` config servers in replica set `configReplSet`
- `3` shard replica sets: `shard01rs`, `shard02rs`, `shard03rs`
- `3` nodes per shard replica set
- `1` `mongos` router exposed on port `27030`
- internal authentication via `keyFile` generated at runtime
- external authentication via MongoDB users
- MongoDB image `mongo:8.0.20` by default

In total, the topology contains `13` containers:

- `configsvr01`, `configsvr02`, `configsvr03`
- `shard01a`, `shard01b`, `shard01c`
- `shard02a`, `shard02b`, `shard02c`
- `shard03a`, `shard03b`, `shard03c`
- `mongos`

## Data Model

The project uses three linked datasets prepared in `../Data/processed`:

- `matches`
- `players`
- `events`

The largest collection is `events`, which is sharded by hashed `event_id`.

## Start

Run the following command from this directory:

```powershell
docker compose up -d
```

Docker Desktop must be running before these commands are executed.

The compose file contains default values for all required variables. Optional
local overrides can be placed in `.env`; `.env.example` shows the expected
variables.

The `cluster-setup` one-shot service now waits for all MongoDB containers,
configures replica sets and shards, creates users, and imports the datasets
automatically.

The cluster `keyFile` is generated automatically into a dedicated Docker volume,
so no fixed authentication key is stored in the repository. Running
`docker compose down -v` removes it and the next `up` generates a new one.

To stop everything:

```powershell
docker compose down
```

To stop everything and remove volumes:

```powershell
docker compose down -v
```

## Verification

Basic health check:

```powershell
docker exec mongos-router mongosh --eval 'db.runCommand({ ping: 1 })'
```

MongoDB version:

```powershell
docker exec mongos-router mongosh --eval 'db.runCommand({ buildInfo: 1 })'
```

Replica set status:

```powershell
docker exec shard01a mongosh --port 27018 --eval 'rs.status()'
docker exec shard02a mongosh --port 27018 --eval 'rs.status()'
docker exec shard03a mongosh --port 27018 --eval 'rs.status()'
docker exec configsvr01 mongosh --eval 'rs.status()'
```

Sharding status:

```powershell
docker exec mongos-router mongosh -u admin -p admin123 --authenticationDatabase admin --eval 'sh.status()'
```

Database statistics:

```powershell
docker exec mongos-router mongosh -u admin -p admin123 --authenticationDatabase admin --eval 'db.getSiblingDB("statsbomb").stats()'
docker exec mongos-router mongosh -u admin -p admin123 --authenticationDatabase admin --eval 'db.getSiblingDB("statsbomb").events.stats()'
```

Indexes:

```powershell
docker exec mongos-router mongosh -u admin -p admin123 --authenticationDatabase admin --eval 'db.getSiblingDB("statsbomb").events.getIndexes()'
```

Optional cluster overview:

```powershell
docker compose exec mongos mongosh -u admin -p admin123 --authenticationDatabase admin /workspace/scripts/mongo/cluster-health.js
```

Pre-defense self-check with evidence capture:

```powershell
.\scripts\pre-defense-check.ps1
```

Optional failover demonstration for one shard replica set:

```powershell
.\scripts\pre-defense-check.ps1 -SimulateFailover -ReplicaSet shard01rs
```

## Important Notes

- `cluster-setup` performs the full automatic bootstrap during `docker compose up -d`.
- `import-data.ps1` remains available as a manual utility for re-importing the prepared datasets.
- `pre-defense-check.ps1` runs the common verification steps, captures evidence files, and can optionally demonstrate a controlled shard failover.
- The `events` collection is the main fact collection and provides enough records for the project requirement of at least `5,000` records in one dataset.
