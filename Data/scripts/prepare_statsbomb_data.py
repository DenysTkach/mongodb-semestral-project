from __future__ import annotations

import json
import sys
from collections import defaultdict
from pathlib import Path

import pandas as pd


TARGET_COMPETITION_NAME = "La Liga"
TARGET_SEASON_NAME = "2019/2020"


PROJECT_ROOT = Path(__file__).resolve().parents[2]
BASE_DIR = PROJECT_ROOT / "Data" / "raw" / "open-data-master" / "data"
OUTPUT_DIR = PROJECT_ROOT / "Data" / "processed"


if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8")


def load_json(file_path: Path):
    """Loads a JSON file using UTF-8 encoding."""
    with file_path.open("r", encoding="utf-8") as file:
        return json.load(file)


def safe_get(obj, *keys, default=None):
    """Safely traverses nested dictionaries."""
    current = obj
    for key in keys:
        if not isinstance(current, dict):
            return default
        current = current.get(key)
        if current is None:
            return default
    return current


def check_input_structure():
    """Validates the required StatsBomb Open Data folder structure."""
    print(f"PROJECT_ROOT = {PROJECT_ROOT}")
    print(f"BASE_DIR     = {BASE_DIR}")
    print(f"OUTPUT_DIR   = {OUTPUT_DIR}")

    required_paths = {
        "competitions.json": BASE_DIR / "competitions.json",
        "matches directory": BASE_DIR / "matches",
        "lineups directory": BASE_DIR / "lineups",
        "events directory": BASE_DIR / "events",
    }

    missing_items = [
        f"{name}: {path}" for name, path in required_paths.items() if not path.exists()
    ]

    if missing_items:
        formatted = "\n".join(f"- {item}" for item in missing_items)
        raise FileNotFoundError(
            "StatsBomb Open Data structure is incomplete. Missing required paths:\n"
            f"{formatted}"
        )


def find_target_competition():
    """
    Finds the requested competition and season.
    If not found, raises a clear error with available alternatives.
    """
    competitions = load_json(BASE_DIR / "competitions.json")

    for competition in competitions:
        if (
            competition.get("competition_name") == TARGET_COMPETITION_NAME
            and competition.get("season_name") == TARGET_SEASON_NAME
        ):
            return {
                "competition_id": competition["competition_id"],
                "season_id": competition["season_id"],
                "competition_name": competition["competition_name"],
                "season_name": competition["season_name"],
            }

    same_competition = sorted(
        {
            (
                item.get("competition_name"),
                item.get("season_name"),
                item.get("competition_id"),
                item.get("season_id"),
            )
            for item in competitions
            if item.get("competition_name") == TARGET_COMPETITION_NAME
        },
        key=lambda value: (value[0] or "", value[1] or ""),
    )
    same_season = sorted(
        {
            (
                item.get("competition_name"),
                item.get("season_name"),
                item.get("competition_id"),
                item.get("season_id"),
            )
            for item in competitions
            if item.get("season_name") == TARGET_SEASON_NAME
        },
        key=lambda value: (value[0] or "", value[1] or ""),
    )
    all_options = sorted(
        {
            (
                item.get("competition_name"),
                item.get("season_name"),
                item.get("competition_id"),
                item.get("season_id"),
            )
            for item in competitions
        },
        key=lambda value: (value[0] or "", value[1] or ""),
    )

    message_lines = [
        (
            f"Target competition/season not found: "
            f"competition='{TARGET_COMPETITION_NAME}', season='{TARGET_SEASON_NAME}'."
        )
    ]

    if same_competition:
        message_lines.append("")
        message_lines.append("Available seasons for the requested competition:")
        for competition_name, season_name, competition_id, season_id in same_competition[:10]:
            message_lines.append(
                f"- {competition_name} / {season_name} "
                f"(competition_id={competition_id}, season_id={season_id})"
            )

    if same_season:
        message_lines.append("")
        message_lines.append("Available competitions for the requested season:")
        for competition_name, season_name, competition_id, season_id in same_season[:10]:
            message_lines.append(
                f"- {competition_name} / {season_name} "
                f"(competition_id={competition_id}, season_id={season_id})"
            )

    message_lines.append("")
    message_lines.append("Sample available competition/season pairs:")
    for competition_name, season_name, competition_id, season_id in all_options[:15]:
        message_lines.append(
            f"- {competition_name} / {season_name} "
            f"(competition_id={competition_id}, season_id={season_id})"
        )

    raise ValueError("\n".join(message_lines))


def build_matches_dataset(competition_id: int, season_id: int, season_name: str):
    """Builds the compact match-level dataset."""
    matches_file = BASE_DIR / "matches" / str(competition_id) / f"{season_id}.json"
    if not matches_file.exists():
        raise FileNotFoundError(
            f"Matches file not found for competition_id={competition_id}, "
            f"season_id={season_id}: {matches_file}"
        )

    matches_raw = load_json(matches_file)
    match_rows = []
    match_ids = []

    for match in matches_raw:
        match_id = match.get("match_id")
        if match_id is None:
            continue

        match_ids.append(match_id)
        match_rows.append(
            {
                "match_id": match_id,
                "match_date": match.get("match_date"),
                "kick_off": match.get("kick_off"),
                "season": season_name,
                "competition_id": competition_id,
                "competition_name": TARGET_COMPETITION_NAME,
                "home_team_id": safe_get(match, "home_team", "home_team_id"),
                "home_team_name": safe_get(match, "home_team", "home_team_name"),
                "away_team_id": safe_get(match, "away_team", "away_team_id"),
                "away_team_name": safe_get(match, "away_team", "away_team_name"),
                "home_score": match.get("home_score"),
                "away_score": match.get("away_score"),
                "stadium_id": safe_get(match, "stadium", "id"),
                "stadium_name": safe_get(match, "stadium", "name"),
                "referee_id": safe_get(match, "referee", "id"),
                "referee_name": safe_get(match, "referee", "name"),
                "competition_stage_id": safe_get(match, "competition_stage", "id"),
                "competition_stage_name": safe_get(match, "competition_stage", "name"),
            }
        )

    matches_df = pd.DataFrame(match_rows)
    if matches_df.empty:
        return matches_df, match_ids

    matches_df = matches_df.sort_values(by=["match_date", "match_id"]).reset_index(drop=True)
    return matches_df, match_ids


def build_players_dataset(match_ids, season_name: str):
    """
    Builds a unique players dataset.
    If a player appears for multiple teams, the most frequent team in lineups is selected.
    """
    player_team_counts = defaultdict(int)
    player_team_rows = {}

    for match_id in match_ids:
        lineup_file = BASE_DIR / "lineups" / f"{match_id}.json"
        if not lineup_file.exists():
            print(f"Warning: lineup file is missing for match_id={match_id}: {lineup_file}")
            continue

        lineup_data = load_json(lineup_file)

        for team_block in lineup_data:
            team_id = team_block.get("team_id")
            team_name = team_block.get("team_name")

            for player in team_block.get("lineup", []):
                player_id = player.get("player_id")
                if player_id is None:
                    continue

                positions = player.get("positions", [])
                position_name = None
                if positions and isinstance(positions, list) and isinstance(positions[0], dict):
                    position_name = positions[0].get("position")

                key = (player_id, team_id)
                player_team_counts[key] += 1

                candidate_row = {
                    "player_id": player_id,
                    "player_name": player.get("player_name"),
                    "player_nickname": player.get("player_nickname"),
                    "jersey_number": player.get("jersey_number"),
                    "country": safe_get(player, "country", "name"),
                    "team_id": team_id,
                    "team_name": team_name,
                    "position": position_name,
                    "season": season_name,
                }

                if key not in player_team_rows:
                    player_team_rows[key] = candidate_row
                    continue

                existing_row = player_team_rows[key]
                for field_name, field_value in candidate_row.items():
                    if existing_row.get(field_name) in (None, "") and field_value not in (None, ""):
                        existing_row[field_name] = field_value

    if not player_team_rows:
        return pd.DataFrame()

    best_rows = {}
    for player_id, team_id in player_team_rows:
        current_key = (player_id, team_id)
        current_row = player_team_rows[current_key]
        if player_id not in best_rows:
            best_rows[player_id] = current_row
            continue

        best_key = (player_id, best_rows[player_id]["team_id"])
        current_count = player_team_counts[current_key]
        best_count = player_team_counts[best_key]

        if current_count > best_count:
            best_rows[player_id] = current_row

    players_df = pd.DataFrame(best_rows.values())
    players_df = players_df.sort_values(
        by=["team_name", "player_name"],
        na_position="last",
    ).reset_index(drop=True)
    return players_df


def build_events_dataset(match_ids, season_name: str):
    """
    Builds the detailed event-level dataset.
    This is the large linked dataset that satisfies the 5,000+ records requirement.
    """
    event_rows = []

    for match_id in match_ids:
        events_file = BASE_DIR / "events" / f"{match_id}.json"
        if not events_file.exists():
            print(f"Warning: events file is missing for match_id={match_id}: {events_file}")
            continue

        events = load_json(events_file)

        for event in events:
            location = event.get("location")
            location_x = None
            location_y = None
            if isinstance(location, list) and len(location) >= 2:
                location_x = location[0]
                location_y = location[1]

            event_rows.append(
                {
                    "event_id": event.get("id") or f"{match_id}_{event.get('index')}",
                    "match_id": match_id,
                    "season": season_name,
                    "index": event.get("index"),
                    "period": event.get("period"),
                    "timestamp": event.get("timestamp"),
                    "minute": event.get("minute"),
                    "second": event.get("second"),
                    "possession": event.get("possession"),
                    "possession_team_id": safe_get(event, "possession_team", "id"),
                    "possession_team_name": safe_get(event, "possession_team", "name"),
                    "team_id": safe_get(event, "team", "id"),
                    "team_name": safe_get(event, "team", "name"),
                    "player_id": safe_get(event, "player", "id"),
                    "player_name": safe_get(event, "player", "name"),
                    "position_id": safe_get(event, "position", "id"),
                    "position_name": safe_get(event, "position", "name"),
                    "event_type_id": safe_get(event, "type", "id"),
                    "event_type_name": safe_get(event, "type", "name"),
                    "play_pattern_id": safe_get(event, "play_pattern", "id"),
                    "play_pattern_name": safe_get(event, "play_pattern", "name"),
                    "location_x": location_x,
                    "location_y": location_y,
                    "pass_recipient_id": safe_get(event, "pass", "recipient", "id"),
                    "pass_recipient_name": safe_get(event, "pass", "recipient", "name"),
                    "shot_outcome_name": safe_get(event, "shot", "outcome", "name"),
                    "card_name": safe_get(event, "bad_behaviour", "card", "name"),
                    "duration": event.get("duration"),
                }
            )

    events_df = pd.DataFrame(event_rows)
    if events_df.empty:
        return events_df

    events_df = events_df.sort_values(
        by=["match_id", "index"],
        na_position="last",
    ).reset_index(drop=True)
    return events_df


def save_outputs(matches_df: pd.DataFrame, players_df: pd.DataFrame, events_df: pd.DataFrame):
    """Saves the three linked datasets in CSV and JSON formats."""
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    matches_csv = OUTPUT_DIR / "matches.csv"
    matches_json = OUTPUT_DIR / "matches.json"
    players_csv = OUTPUT_DIR / "players.csv"
    players_json = OUTPUT_DIR / "players.json"
    events_csv = OUTPUT_DIR / "events.csv"
    events_json = OUTPUT_DIR / "events.json"

    obsolete_outputs = [
        OUTPUT_DIR / "player_stats.csv",
        OUTPUT_DIR / "player_stats.json",
    ]

    matches_df.to_csv(matches_csv, index=False, encoding="utf-8")
    players_df.to_csv(players_csv, index=False, encoding="utf-8")
    events_df.to_csv(events_csv, index=False, encoding="utf-8")

    matches_df.to_json(matches_json, orient="records", force_ascii=False, indent=2)
    players_df.to_json(players_json, orient="records", force_ascii=False, indent=2)
    events_df.to_json(events_json, orient="records", force_ascii=False, indent=2)

    for obsolete_file in obsolete_outputs:
        if obsolete_file.exists():
            obsolete_file.unlink()


def main():
    """Script entry point."""
    check_input_structure()

    target = find_target_competition()
    print(
        "Found target competition and season: "
        f"{target['competition_name']} / {target['season_name']} "
        f"(competition_id={target['competition_id']}, season_id={target['season_id']})"
    )

    matches_df, match_ids = build_matches_dataset(
        competition_id=target["competition_id"],
        season_id=target["season_id"],
        season_name=target["season_name"],
    )
    players_df = build_players_dataset(
        match_ids=match_ids,
        season_name=target["season_name"],
    )
    events_df = build_events_dataset(
        match_ids=match_ids,
        season_name=target["season_name"],
    )

    save_outputs(
        matches_df=matches_df,
        players_df=players_df,
        events_df=events_df,
    )

    print(f"matches rows: {len(matches_df)}")
    print(f"players rows: {len(players_df)}")
    print(f"events rows: {len(events_df)}")

    print("\nFirst 5 rows of matches:")
    print(matches_df.head())

    print("\nFirst 5 rows of players:")
    print(players_df.head())

    print("\nFirst 5 rows of events:")
    print(events_df.head())


if __name__ == "__main__":
    main()
