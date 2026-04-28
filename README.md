# MongoDB Semestral Project

Sharded MongoDB deployment for analytical work with StatsBomb football data.
The project combines data preparation, a multi-node MongoDB cluster, schema
validation, indexes, analytical queries, performance checks, and administration
evidence for a complete semestral database assignment.

## Project Scope

This repository demonstrates:

- a Docker Compose based MongoDB 8 sharded cluster
- 3 config servers in replica set `configReplSet`
- 3 shard replica sets: `shard01rs`, `shard02rs`, `shard03rs`
- 3 data-bearing nodes per shard replica set
- a `mongos` router exposed on local port `27030`
- `mongo-express` web UI exposed on local port `8081`
- automatic cluster bootstrap, user creation, data import, validators, and indexes
- analytical MongoDB queries with captured outputs
- Python data preparation and exploratory analysis
- pre-defense verification scripts with optional failover demonstration

## Dataset

The project uses StatsBomb Open Data and transforms it into three linked
MongoDB collections:

| Collection | Records | Purpose |
| --- | ---: | --- |
| `matches` | 33 | Match metadata, teams, scores, venue, referee |
| `players` | 476 | Player metadata linked by `player_id` |
| `events` | 129,058 | Main event-level fact collection |

The main collection is `events`. It contains more than enough records for the
large-dataset requirement and is sharded by hashed `event_id`.

Prepared files are stored in:

```text
Data/processed/
```

## Repository Structure

| Path | Description |
| --- | --- |
| `Data/raw` | Original StatsBomb Open Data source files |
| `Data/processed` | Cleaned CSV and JSON files imported into MongoDB |
| `Data/scripts` | Python scripts for data preparation and analysis |
| `Data/notebooks` | Jupyter notebook for the data analysis workflow |
| `Data/analysis` | Generated tables, plots, summaries, and analysis report |
| `Dotazy/mongo_queries.md` | Final MongoDB queries grouped by topic |
| `Dotazy/mongo_query_outputs.md` | Captured outputs for the queries |
| `Funkcni_reseni` | Functional Docker Compose MongoDB cluster solution |
| `Dokumentace` | Written project documentation |

## Architecture

The functional solution starts a complete local MongoDB deployment:

```text
mongo-express
     |
   mongos
     |
  statsbomb database
     |
  +----------------+----------------+----------------+
  | shard01rs      | shard02rs      | shard03rs      |
  | 3 members      | 3 members      | 3 members      |
  +----------------+----------------+----------------+
     |
 configReplSet: 3 config servers
```

The cluster contains 13 MongoDB containers:

- `configsvr01`, `configsvr02`, `configsvr03`
- `shard01a`, `shard01b`, `shard01c`
- `shard02a`, `shard02b`, `shard02c`
- `shard03a`, `shard03b`, `shard03c`
- `mongos-router`

Additional services:

- `mongo-express` for browser-based inspection
- `keyfile-setup` for internal MongoDB authentication key generation
- `cluster-setup` for automatic replica set, sharding, import, validator, and index setup

## Quick Start

Requirements:

- Docker Desktop
- PowerShell
- enough free disk space for Docker volumes and imported data

Start the full cluster:

```powershell
cd Funkcni_reseni
docker compose up -d
```

The bootstrap is automatic. It initializes replica sets, adds shards, creates
MongoDB users, imports datasets, applies validators, and creates indexes.

Open mongo-express:

```text
http://localhost:8081
```

Default local web login:

```text
admin / admin123
```

The MongoDB router is exposed locally at:

```text
localhost:27030
```

## Verification

Run the complete pre-defense check from `Funkcni_reseni`:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\pre-defense-check.ps1
```

The script checks cluster health, sharding, statistics, indexes,
mongo-express availability, and stores evidence files in:

```text
Funkcni_reseni/evidence/
```

Optional controlled failover demonstration:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\pre-defense-check.ps1 -SimulateFailover -ReplicaSet shard01rs
```

Useful manual checks:

```powershell
docker exec mongos-router mongosh --eval 'db.runCommand({ ping: 1 })'
docker exec mongos-router mongosh -u admin -p admin123 --authenticationDatabase admin --eval 'sh.status()'
docker exec mongos-router mongosh -u admin -p admin123 --authenticationDatabase admin --eval 'db.getSiblingDB("statsbomb").stats()'
```

## Query Set

The project contains 30 MongoDB queries grouped into five categories:

| Category | Focus |
| --- | --- |
| 1. Join / lookup | `$lookup`, cross-collection enrichment, readable analytical output |
| 2. Aggregation / statistics | counts, averages, percentages, conditional aggregation |
| 3. Nested / embedded documents | subdocuments, embedded arrays, document reshaping |
| 4. Indexes / performance | `$indexStats`, `explain`, index usage, blocking sort analysis |
| 5. Cluster / sharding / admin | chunk distribution, changelog, replication, validation, users |

Main query files:

```text
Dotazy/mongo_queries.md
Dotazy/mongo_query_outputs.md
```

## Data Analysis

Run the analysis script from the project root:

```powershell
& .\.venv\Scripts\python.exe Data\scripts\analyze_statsbomb_data.py
```

Open the notebook:

```powershell
& .\.venv\Scripts\python.exe -m jupyter lab
```

Notebook:

```text
Data/notebooks/analyze_statsbomb.ipynb
```

Generated analysis artifacts are written to:

```text
Data/analysis/
```

## Stop and Cleanup

Stop containers but keep volumes:

```powershell
cd Funkcni_reseni
docker compose down
```

Stop containers and remove volumes:

```powershell
cd Funkcni_reseni
docker compose down -v
```

Removing volumes also removes the generated MongoDB keyFile and database data.
The next `docker compose up -d` creates a fresh cluster again.

## Important Notes

- The cluster setup is fully automated through `cluster-setup`.
- The internal MongoDB keyFile is generated at runtime and is not stored in the repository.
- The default credentials are intended for local semestral-project testing only.
- `events` is the main sharded fact collection.
- Validators are applied to `matches`, `players`, and `events`.
- Indexes are created for the analytical workloads and documented with performance queries.

