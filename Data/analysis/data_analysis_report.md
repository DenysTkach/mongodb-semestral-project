# StatsBomb Data Analysis

This report summarizes the three linked datasets used in the MongoDB semestral project.

## Source and transformation

- Source: StatsBomb Open Data
- Competition: La Liga
- Season: 2019/2020
- Raw JSON files were transformed into three linked CSV/JSON datasets: `matches`, `players`, `events`
- The transformation script is `Data/scripts/prepare_statsbomb_data.py`

## Dataset overview

| dataset | rows | columns | total_missing_values | duplicate_rows | file |
| --- | --- | --- | --- | --- | --- |
| events | 129058 | 28 | 482946 | 0 | events.csv |
| players | 476 | 9 | 186 | 0 | players.csv |
| matches | 33 | 18 | 52 | 0 | matches.csv |

## Key observations

- The `events` dataset is the main fact dataset with 129,058 rows.
- The `matches` dataset contains 33 match records and serves as a metadata dimension.
- The `players` dataset contains 476 unique players linked to the same season and competition context.
- Missing values are expected in several event attributes because many fields are event-type specific, for example `shot_outcome_name`, `card_name`, and `pass_recipient_name`.

## Columns with the highest number of missing values

| column | missing_count | missing_pct | dataset |
| --- | --- | --- | --- |
| card_name | 129022 | 99.97 | events |
| shot_outcome_name | 128306 | 99.42 | events |
| pass_recipient_id | 93338 | 72.32 | events |
| pass_recipient_name | 93338 | 72.32 | events |
| duration | 35718 | 27.68 | events |
| location_x | 764 | 0.59 | events |
| location_y | 764 | 0.59 | events |
| player_id | 424 | 0.33 | events |
| player_name | 424 | 0.33 | events |
| position_id | 424 | 0.33 | events |
| position_name | 424 | 0.33 | events |
| position | 107 | 22.48 | players |

## Numeric summary

### Matches

| dataset | column | count | mean | std | min | median | max |
| --- | --- | --- | --- | --- | --- | --- | --- |
| matches | match_id | 33.0 | 303574.818 | 107.242 | 303377.0 | 303596.0 | 303731.0 |
| matches | competition_id | 33.0 | 11.0 | 0.0 | 11.0 | 11.0 | 11.0 |
| matches | home_team_id | 33.0 | 289.727 | 229.089 | 205.0 | 217.0 | 1049.0 |
| matches | away_team_id | 33.0 | 296.121 | 229.762 | 205.0 | 217.0 | 1049.0 |
| matches | home_score | 33.0 | 1.848 | 1.523 | 0.0 | 2.0 | 5.0 |
| matches | away_score | 33.0 | 1.273 | 1.353 | 0.0 | 1.0 | 5.0 |
| matches | stadium_id | 33.0 | 891.424 | 1441.803 | 342.0 | 342.0 | 5043.0 |
| matches | referee_id | 7.0 | 185.286 | 11.427 | 180.0 | 180.0 | 211.0 |
| matches | competition_stage_id | 33.0 | 1.0 | 0.0 | 1.0 | 1.0 | 1.0 |

### Players

| dataset | column | count | mean | std | min | median | max |
| --- | --- | --- | --- | --- | --- | --- | --- |
| players | player_id | 476.0 | 14229.662 | 10814.89 | 2948.0 | 6958.5 | 41733.0 |
| players | jersey_number | 476.0 | 15.561 | 9.384 | 1.0 | 15.0 | 43.0 |
| players | team_id | 476.0 | 348.172 | 279.982 | 205.0 | 216.0 | 1049.0 |

### Events

| dataset | column | count | mean | std | min | median | max |
| --- | --- | --- | --- | --- | --- | --- | --- |
| events | match_id | 129058.0 | 303574.507 | 105.014 | 303377.0 | 303596.0 | 303731.0 |
| events | index | 129058.0 | 1963.75 | 1142.612 | 1.0 | 1956.0 | 4656.0 |
| events | period | 129058.0 | 1.49 | 0.5 | 1.0 | 1.0 | 2.0 |
| events | minute | 129058.0 | 44.504 | 26.92 | 0.0 | 45.0 | 97.0 |
| events | second | 129058.0 | 29.425 | 17.371 | 0.0 | 29.0 | 59.0 |
| events | possession | 129058.0 | 85.488 | 51.787 | 1.0 | 84.0 | 224.0 |
| events | possession_team_id | 129058.0 | 265.692 | 184.051 | 205.0 | 217.0 | 1049.0 |
| events | team_id | 129058.0 | 272.531 | 195.971 | 205.0 | 217.0 | 1049.0 |
| events | player_id | 128634.0 | 9602.748 | 7093.459 | 2948.0 | 6589.0 | 41125.0 |
| events | position_id | 128634.0 | 10.79 | 6.996 | 0.0 | 10.0 | 24.0 |
| events | event_type_id | 129058.0 | 33.427 | 11.335 | 2.0 | 42.0 | 43.0 |
| events | play_pattern_id | 129058.0 | 2.876 | 2.263 | 1.0 | 3.0 | 9.0 |

## Most frequent event types

| event_type_name | count |
| --- | --- |
| Pass | 37157 |
| Ball Receipt* | 35718 |
| Carry | 30480 |
| Pressure | 10667 |
| Ball Recovery | 2793 |
| Duel | 1681 |
| Block | 1174 |
| Dribble | 1150 |
| Clearance | 1138 |
| Foul Committed | 985 |

## Most frequent shot outcomes

| shot_outcome_name | count |
| --- | --- |
| Off T | 224 |
| Saved | 191 |
| Blocked | 184 |
| Goal | 101 |
| Wayward | 27 |
| Post | 18 |
| Saved Off Target | 6 |
| Saved to Post | 1 |

    ## Generated plots

- `Data/analysis/plots/dataset_sizes.png`
- `Data/analysis/plots/top_missing_columns.png`
- `Data/analysis/plots/top_event_types.png`
- `Data/analysis/plots/event_minutes_histogram.png`
- `Data/analysis/plots/shot_outcomes.png`
- `Data/analysis/plots/top_teams_by_shots.png`
- `Data/analysis/plots/player_countries.png`
