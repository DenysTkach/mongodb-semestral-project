# MongoDB Semestral Project

Semestral project for a sharded MongoDB deployment over StatsBomb football data.

## Structure

- `Data/processed` - prepared CSV/JSON datasets used by MongoDB.
- `Data/scripts` - Python scripts for data preparation and analysis.
- `Data/notebooks` - Jupyter notebook with the required data analysis workflow.
- `Data/analysis` - generated analysis tables and plots.
- `Dotazy` - MongoDB queries and captured outputs.
- `Funkcni_reseni` - Docker Compose based MongoDB cluster and setup scripts.
  It also starts `mongo-express` as a browser UI for the MongoDB cluster.

## Run

From `Funkcni_reseni`:

```powershell
docker compose up -d
```

The cluster bootstrap is automatic. It initializes replica sets, adds shards,
creates users, imports prepared datasets, applies validators, and creates
indexes.

After startup, mongo-express is available at `http://localhost:8081` and
connects to the cluster through the `mongos` router.

Optional local configuration can be changed through `Funkcni_reseni/.env`.
The compose file also contains defaults, so the project can start without a
custom `.env` file.

## Verify

From `Funkcni_reseni`:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\pre-defense-check.ps1
```

The script captures evidence into `Funkcni_reseni/evidence`, including
MongoDB checks and mongo-express availability.
