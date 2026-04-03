# MongoDB Cluster Setup

This folder contains a sharded MongoDB setup for the semestral project.

## Architecture

- `1` sharded MongoDB cluster
- `3` config servers in replica set `configReplSet`
- `3` shard replica sets: `shard01rs`, `shard02rs`, `shard03rs`
- `3` nodes per shard replica set
- `1` `mongos` router exposed on port `27030`
- internal authentication via `keyFile`
- external authentication via MongoDB users

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

Run the following commands from this directory:

```powershell
docker compose up -d
.\scripts\init-cluster.ps1
.\scripts\import-data.ps1
```

Docker Desktop must be running before these commands are executed.

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

## Important Notes

- `init-cluster.ps1` configures replica sets, adds shards and creates users.
- `import-data.ps1` imports `matches.json`, `players.json` and `events.json`, creates indexes and shards the `events` collection.
- The `events` collection is the main fact collection and provides enough records for the project requirement of at least `5,000` records in one dataset.
