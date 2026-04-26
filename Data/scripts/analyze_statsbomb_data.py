from __future__ import annotations

from pathlib import Path

import matplotlib.pyplot as plt
import pandas as pd
import seaborn as sns


PROJECT_ROOT = Path(__file__).resolve().parents[2]
DATA_DIR = PROJECT_ROOT / "Data"
PROCESSED_DIR = DATA_DIR / "processed"
ANALYSIS_DIR = DATA_DIR / "analysis"
PLOTS_DIR = ANALYSIS_DIR / "plots"

DATASETS = {
    "matches": PROCESSED_DIR / "matches.csv",
    "players": PROCESSED_DIR / "players.csv",
    "events": PROCESSED_DIR / "events.csv",
}


def ensure_dirs() -> None:
    ANALYSIS_DIR.mkdir(parents=True, exist_ok=True)
    PLOTS_DIR.mkdir(parents=True, exist_ok=True)


def load_datasets() -> dict[str, pd.DataFrame]:
    return {name: pd.read_csv(path) for name, path in DATASETS.items()}


def dataset_overview(frames: dict[str, pd.DataFrame]) -> pd.DataFrame:
    rows = []
    for name, df in frames.items():
        total_missing = int(df.isna().sum().sum())
        rows.append(
            {
                "dataset": name,
                "rows": len(df),
                "columns": len(df.columns),
                "total_missing_values": total_missing,
                "duplicate_rows": int(df.duplicated().sum()),
                "file": DATASETS[name].name,
            }
        )
    return pd.DataFrame(rows).sort_values("rows", ascending=False)


def missing_summary(name: str, df: pd.DataFrame) -> pd.DataFrame:
    total_rows = max(len(df), 1)
    summary = pd.DataFrame(
        {
            "column": df.columns,
            "missing_count": df.isna().sum().values,
        }
    )
    summary["missing_pct"] = (
        summary["missing_count"] / total_rows * 100
    ).round(2)
    summary["dataset"] = name
    return summary.sort_values(
        ["missing_count", "column"], ascending=[False, True]
    ).reset_index(drop=True)


def numeric_summary(name: str, df: pd.DataFrame) -> pd.DataFrame:
    numeric = df.select_dtypes(include="number")
    if numeric.empty:
        return pd.DataFrame(
            columns=[
                "dataset",
                "column",
                "count",
                "mean",
                "std",
                "min",
                "median",
                "max",
            ]
        )

    stats = numeric.describe().T.reset_index().rename(columns={"index": "column"})
    stats["median"] = numeric.median().values
    stats.insert(0, "dataset", name)
    columns = ["dataset", "column", "count", "mean", "std", "min", "median", "max"]
    return stats[columns].round(3)


def save_tables(frames: dict[str, pd.DataFrame]) -> dict[str, pd.DataFrame]:
    overview = dataset_overview(frames)
    overview.to_csv(ANALYSIS_DIR / "dataset_overview.csv", index=False)

    missing_tables = []
    numeric_tables = []
    for name, df in frames.items():
        missing = missing_summary(name, df)
        numeric = numeric_summary(name, df)
        missing.to_csv(ANALYSIS_DIR / f"{name}_missing_summary.csv", index=False)
        numeric.to_csv(ANALYSIS_DIR / f"{name}_numeric_summary.csv", index=False)
        missing_tables.append(missing)
        numeric_tables.append(numeric)

    all_missing = pd.concat(missing_tables, ignore_index=True)
    all_numeric = pd.concat(numeric_tables, ignore_index=True)
    all_missing.to_csv(ANALYSIS_DIR / "all_missing_summary.csv", index=False)
    all_numeric.to_csv(ANALYSIS_DIR / "all_numeric_summary.csv", index=False)

    return {
        "overview": overview,
        "all_missing": all_missing,
        "all_numeric": all_numeric,
    }


def save_plot(fig: plt.Figure, filename: str) -> None:
    fig.tight_layout()
    fig.savefig(PLOTS_DIR / filename, dpi=160, bbox_inches="tight")
    plt.close(fig)


def remove_legend(ax: plt.Axes) -> None:
    legend = ax.get_legend()
    if legend is not None:
        legend.remove()


def annotate_bars(ax: plt.Axes) -> None:
    for container in ax.containers:
        labels = []
        for bar in container:
            value = bar.get_height()
            labels.append(f"{int(value):,}")
        ax.bar_label(container, labels=labels, padding=3, fontsize=9)


def create_plots(frames: dict[str, pd.DataFrame]) -> None:
    sns.set_theme(style="whitegrid")

    overview = dataset_overview(frames)
    fig, axes = plt.subplots(1, 2, figsize=(12, 4.8))

    sns.barplot(data=overview, x="dataset", y="rows", hue="dataset", dodge=False, ax=axes[0])
    axes[0].set_title("Dataset sizes (linear scale)")
    axes[0].set_xlabel("Dataset")
    axes[0].set_ylabel("Rows")
    remove_legend(axes[0])
    annotate_bars(axes[0])

    sns.barplot(data=overview, x="dataset", y="rows", hue="dataset", dodge=False, ax=axes[1])
    axes[1].set_title("Dataset sizes (log scale)")
    axes[1].set_xlabel("Dataset")
    axes[1].set_ylabel("Rows")
    axes[1].set_yscale("log")
    remove_legend(axes[1])
    annotate_bars(axes[1])

    save_plot(fig, "dataset_sizes.png")

    missing_plot = (
        pd.concat(
            [
                missing_summary("matches", frames["matches"]),
                missing_summary("players", frames["players"]),
                missing_summary("events", frames["events"]),
            ],
            ignore_index=True,
        )
        .sort_values(["missing_count", "dataset"], ascending=[False, True])
        .head(12)
    )
    missing_plot["label"] = missing_plot["dataset"] + "." + missing_plot["column"]
    fig, ax = plt.subplots(figsize=(11, 5.5))
    sns.barplot(data=missing_plot, x="missing_count", y="label", hue="dataset", dodge=False, ax=ax)
    ax.set_title("Top missing-value columns across all datasets")
    ax.set_xlabel("Missing values")
    ax.set_ylabel("Dataset.Column")
    remove_legend(ax)
    save_plot(fig, "top_missing_columns.png")

    events = frames["events"]
    event_types = (
        events["event_type_name"]
        .value_counts()
        .head(10)
        .rename_axis("event_type_name")
        .reset_index(name="count")
    )
    fig, ax = plt.subplots(figsize=(10, 5))
    sns.barplot(data=event_types, x="count", y="event_type_name", hue="event_type_name", dodge=False, ax=ax)
    ax.set_title("Top 10 event types")
    ax.set_xlabel("Count")
    ax.set_ylabel("Event type")
    remove_legend(ax)
    save_plot(fig, "top_event_types.png")

    fig, ax = plt.subplots(figsize=(10, 5))
    sns.histplot(events["minute"].dropna(), bins=25, kde=False, ax=ax, color="#4C72B0")
    ax.set_title("Event distribution by match minute")
    ax.set_xlabel("Minute")
    ax.set_ylabel("Event count")
    save_plot(fig, "event_minutes_histogram.png")

    shots = (
        events.loc[events["event_type_name"] == "Shot", "shot_outcome_name"]
        .fillna("Unknown")
        .value_counts()
        .head(8)
        .rename_axis("shot_outcome_name")
        .reset_index(name="count")
    )
    fig, ax = plt.subplots(figsize=(10, 5))
    sns.barplot(data=shots, x="count", y="shot_outcome_name", hue="shot_outcome_name", dodge=False, ax=ax)
    ax.set_title("Shot outcomes")
    ax.set_xlabel("Count")
    ax.set_ylabel("Shot outcome")
    remove_legend(ax)
    save_plot(fig, "shot_outcomes.png")

    team_shots = (
        events.loc[events["event_type_name"] == "Shot", "team_name"]
        .fillna("Unknown")
        .value_counts()
        .head(10)
        .rename_axis("team_name")
        .reset_index(name="count")
    )
    fig, ax = plt.subplots(figsize=(10, 5))
    sns.barplot(data=team_shots, x="count", y="team_name", hue="team_name", dodge=False, ax=ax)
    ax.set_title("Top 10 teams by shot count")
    ax.set_xlabel("Shots")
    ax.set_ylabel("Team")
    remove_legend(ax)
    save_plot(fig, "top_teams_by_shots.png")

    players = frames["players"]
    countries = (
        players["country"]
        .fillna("Unknown")
        .value_counts()
        .head(10)
        .rename_axis("country")
        .reset_index(name="count")
    )
    fig, ax = plt.subplots(figsize=(10, 5))
    sns.barplot(data=countries, x="count", y="country", hue="country", dodge=False, ax=ax)
    ax.set_title("Top 10 player countries")
    ax.set_xlabel("Players")
    ax.set_ylabel("Country")
    remove_legend(ax)
    save_plot(fig, "player_countries.png")


def markdown_table(df: pd.DataFrame, max_rows: int = 10) -> str:
    if df.empty:
        return "_No data available._"
    sample = df.head(max_rows).copy()
    headers = [str(column) for column in sample.columns]
    rows = [
        ["" if pd.isna(value) else str(value) for value in row]
        for row in sample.itertuples(index=False, name=None)
    ]

    lines = [
        "| " + " | ".join(headers) + " |",
        "| " + " | ".join(["---"] * len(headers)) + " |",
    ]
    for row in rows:
        lines.append("| " + " | ".join(row) + " |")
    return "\n".join(lines)


def build_report(frames: dict[str, pd.DataFrame], tables: dict[str, pd.DataFrame]) -> str:
    matches = frames["matches"]
    players = frames["players"]
    events = frames["events"]

    top_missing = (
        tables["all_missing"]
        .sort_values(["missing_count", "dataset"], ascending=[False, True])
        .head(12)
    )

    event_types = (
        events["event_type_name"]
        .value_counts()
        .head(10)
        .rename_axis("event_type_name")
        .reset_index(name="count")
    )

    shot_outcomes = (
        events.loc[events["event_type_name"] == "Shot", "shot_outcome_name"]
        .fillna("Unknown")
        .value_counts()
        .head(8)
        .rename_axis("shot_outcome_name")
        .reset_index(name="count")
    )

    report = f"""# StatsBomb Data Analysis

This report summarizes the three linked datasets used in the MongoDB semestral project.

## Source and transformation

- Source: StatsBomb Open Data
- Competition: La Liga
- Season: 2019/2020
- Raw JSON files were transformed into three linked CSV/JSON datasets: `matches`, `players`, `events`
- The transformation script is `Data/scripts/prepare_statsbomb_data.py`

## Dataset overview

{markdown_table(tables["overview"], max_rows=10)}

## Key observations

- The `events` dataset is the main fact dataset with {len(events):,} rows.
- The `matches` dataset contains {len(matches)} match records and serves as a metadata dimension.
- The `players` dataset contains {len(players)} unique players linked to the same season and competition context.
- Missing values are expected in several event attributes because many fields are event-type specific, for example `shot_outcome_name`, `card_name`, and `pass_recipient_name`.

## Columns with the highest number of missing values

{markdown_table(top_missing, max_rows=12)}

## Numeric summary

### Matches

{markdown_table(numeric_summary("matches", matches), max_rows=10)}

### Players

{markdown_table(numeric_summary("players", players), max_rows=10)}

### Events

{markdown_table(numeric_summary("events", events), max_rows=12)}

## Most frequent event types

{markdown_table(event_types, max_rows=10)}

## Most frequent shot outcomes

{markdown_table(shot_outcomes, max_rows=8)}

    ## Generated plots

- `Data/analysis/plots/dataset_sizes.png`
- `Data/analysis/plots/top_missing_columns.png`
- `Data/analysis/plots/top_event_types.png`
- `Data/analysis/plots/event_minutes_histogram.png`
- `Data/analysis/plots/shot_outcomes.png`
- `Data/analysis/plots/top_teams_by_shots.png`
- `Data/analysis/plots/player_countries.png`
"""
    return report


def main() -> None:
    ensure_dirs()
    frames = load_datasets()
    tables = save_tables(frames)
    create_plots(frames)
    report = build_report(frames, tables)
    (ANALYSIS_DIR / "data_analysis_report.md").write_text(report, encoding="utf-8")
    print("Analysis completed.")
    print(f"Artifacts saved to: {ANALYSIS_DIR}")


if __name__ == "__main__":
    main()
