# MongoDB Semestral Project

Semestral project for a sharded MongoDB deployment over StatsBomb football data.

## Structure

- `Data/processed` - prepared CSV/JSON datasets used by MongoDB.
- `Data/scripts` - Python scripts for data preparation and analysis.
- `Data/notebooks` - Jupyter notebook with the required data analysis workflow.
- `Data/analysis` - generated analysis tables and plots.
- `Dotazy` - MongoDB queries and captured outputs.
- `Funkcni_reseni` - Docker Compose based MongoDB cluster and setup scripts.

## Run

From `Funkcni_reseni`:

```powershell
docker compose up -d
```

The cluster bootstrap is automatic. It initializes replica sets, adds shards,
creates users, imports prepared datasets, applies validators, and creates
indexes.

Optional local configuration can be changed through `Funkcni_reseni/.env`.
The compose file also contains defaults, so the project can start without a
custom `.env` file.

## Verify

From `Funkcni_reseni`:

```powershell
.\scripts\pre-defense-check.ps1
```

The script captures evidence into `Funkcni_reseni/evidence`.
