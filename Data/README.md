# Data Folder

This folder contains the complete data pipeline for the semestral MongoDB project.

## Purpose of Each Subfolder

- `raw`
  Original source data downloaded from StatsBomb Open Data. These files are kept so the processed datasets can be reproduced from the public source.
- `processed`
  Cleaned and compact datasets used directly by the MongoDB cluster. The project works with three linked datasets: `matches`, `players`, and `events`.
- `scripts`
  Python scripts used to prepare and analyze the data. `prepare_statsbomb_data.py` builds the processed datasets and `analyze_statsbomb_data.py` produces the analysis artifacts required by the project.
- `notebooks`
  Jupyter notebooks used for exploratory analysis and for the documented data-analysis workflow. This is the folder that satisfies the requirement to include a Python notebook or notebook source with the project.
- `analysis`
  Generated outputs from the analysis step, such as summary tables, missing-value reports, markdown report, and plots for documentation.
- `Pdf_sema`
  Assignment materials, project requirements, and reference documents used while preparing the semestral work.

## Dataset Source

- Source: StatsBomb Open Data
- Source repository information is available in `Data/raw/open-data-master/README.md`

## Files Used by the MongoDB Project

- `processed/matches.csv` and `processed/matches.json`
- `processed/players.csv` and `processed/players.json`
- `processed/events.csv` and `processed/events.json`

## How to Run the Analysis

From the project root:

```powershell
& .\.venv\Scripts\python.exe Data\scripts\analyze_statsbomb_data.py
```

Open the notebook with Jupyter Lab:

```powershell
& .\.venv\Scripts\python.exe -m jupyter lab
```

Notebook file:

```text
Data/notebooks/analyze_statsbomb.ipynb
```

## Analysis Outputs

After running the analysis script, the following artifacts are created in `Data/analysis`:

- dataset overview table
- missing-value summaries
- numeric summaries
- markdown report
- plots used in documentation
