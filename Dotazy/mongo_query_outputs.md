# Mongo Query Outputs

Source: `Dotazy/mongo_queries.md`
Total queries executed: `30`

## Query 1: Players with the highest number of pass events

- Category: `Category 1: Join / lookup`
- Exit code: `0`

### Output
```text
[
  {
    pass_count: 2282,
    player_id: 5213,
    player_name: 'Gerard Piqué Bernabéu',
    team_name: 'Barcelona',
    country: 'Spain'
  },
  {
    pass_count: 2280,
    player_id: 5203,
    player_name: 'Sergio Busquets i Burgos',
    team_name: 'Barcelona',
    country: 'Spain'
  },
  {
    pass_count: 2142,
    player_id: 5503,
    player_name: 'Lionel Andrés Messi Cuccittini',
    team_name: 'Barcelona',
    country: 'Argentina'
  },
  {
    pass_count: 1883,
    player_id: 6379,
    player_name: 'Sergi Roberto Carnicer',
    team_name: 'Barcelona',
    country: 'Spain'
  },
  {
    pass_count: 1762,
    player_id: 6826,
    player_name: 'Clément Lenglet',
    team_name: 'Barcelona',
    country: 'France'
  },
  {
    pass_count: 1719,
    player_id: 5211,
    player_name: 'Jordi Alba Ramos',
    team_name: 'Barcelona',
    country: 'Spain'
  },
  {
    pass_count: 1411,
    player_id: 5470,
    player_name: 'Ivan Rakitić',
    team_name: 'Barcelona',
    country: 'Croatia'
  },
  {
    pass_count: 1385,
    player_id: 6374,
    player_name: 'Nélson Cabral Semedo',
    team_name: 'Barcelona',
    country: 'Portugal'
  },
  {
    pass_count: 1363,
    player_id: 8118,
    player_name: 'Frenkie de Jong',
    team_name: 'Barcelona',
    country: 'Netherlands'
  },
  {
    pass_count: 1263,
    player_id: 20055,
    player_name: 'Marc-André ter Stegen',
    team_name: 'Barcelona',
    country: 'Germany'
  }
]
```

## Query 2: Most frequent passer-recipient combinations

- Category: `Category 1: Join / lookup`
- Exit code: `0`

### Output
```text
[
  {
    successful_passes: 382,
    passer_name: 'Sergio Busquets i Burgos',
    recipient_name: 'Lionel Andrés Messi Cuccittini',
    passer_team: 'Barcelona',
    recipient_team: 'Barcelona'
  },
  {
    successful_passes: 355,
    passer_name: 'Sergi Roberto Carnicer',
    recipient_name: 'Lionel Andrés Messi Cuccittini',
    passer_team: 'Barcelona',
    recipient_team: 'Barcelona'
  },
  {
    successful_passes: 316,
    passer_name: 'Gerard Piqué Bernabéu',
    recipient_name: 'Clément Lenglet',
    passer_team: 'Barcelona',
    recipient_team: 'Barcelona'
  },
  {
    successful_passes: 283,
    passer_name: 'Gerard Piqué Bernabéu',
    recipient_name: 'Sergi Roberto Carnicer',
    passer_team: 'Barcelona',
    recipient_team: 'Barcelona'
  },
  {
    successful_passes: 272,
    passer_name: 'Gerard Piqué Bernabéu',
    recipient_name: 'Marc-André ter Stegen',
    passer_team: 'Barcelona',
    recipient_team: 'Barcelona'
  },
  {
    successful_passes: 264,
    passer_name: 'Sergi Roberto Carnicer',
    recipient_name: 'Gerard Piqué Bernabéu',
    passer_team: 'Barcelona',
    recipient_team: 'Barcelona'
  },
  {
    successful_passes: 264,
    passer_name: 'Clément Lenglet',
    recipient_name: 'Gerard Piqué Bernabéu',
    passer_team: 'Barcelona',
    recipient_team: 'Barcelona'
  },
  {
    successful_passes: 264,
    passer_name: 'Arturo Erasmo Vidal Pardo',
    recipient_name: 'Lionel Andrés Messi Cuccittini',
    passer_team: 'Barcelona',
    recipient_team: 'Barcelona'
  },
  {
    successful_passes: 247,
    passer_name: 'Lionel Andrés Messi Cuccittini',
    recipient_name: 'Sergi Roberto Carnicer',
    passer_team: 'Barcelona',
    recipient_team: 'Barcelona'
  },
  {
    successful_passes: 231,
    passer_name: 'Sergio Busquets i Burgos',
    recipient_name: 'Gerard Piqué Bernabéu',
    passer_team: 'Barcelona',
    recipient_team: 'Barcelona'
  }
]
```

## Query 3: Matches with the highest number of shots

- Category: `Category 1: Join / lookup`
- Exit code: `0`

### Output
```text
[
  {
    shot_count: 34,
    match_id: 303451,
    match_date: '2019-12-07',
    home_team: 'Barcelona',
    away_team: 'Mallorca'
  },
  {
    shot_count: 32,
    match_id: 303682,
    match_date: '2020-02-02',
    home_team: 'Barcelona',
    away_team: 'Levante UD'
  },
  {
    shot_count: 31,
    match_id: 303473,
    match_date: '2019-10-06',
    home_team: 'Barcelona',
    away_team: 'Sevilla'
  },
  {
    shot_count: 29,
    match_id: 303524,
    match_date: '2019-12-01',
    home_team: 'Atlético Madrid',
    away_team: 'Barcelona'
  },
  {
    shot_count: 28,
    match_id: 303516,
    match_date: '2020-06-27',
    home_team: 'Celta Vigo',
    away_team: 'Barcelona'
  },
  {
    shot_count: 28,
    match_id: 303664,
    match_date: '2019-12-14',
    home_team: 'Real Sociedad',
    away_team: 'Barcelona'
  },
  {
    shot_count: 28,
    match_id: 303725,
    match_date: '2020-07-05',
    home_team: 'Villarreal',
    away_team: 'Barcelona'
  },
  {
    shot_count: 27,
    match_id: 303600,
    match_date: '2019-10-29',
    home_team: 'Barcelona',
    away_team: 'Real Valladolid'
  },
  {
    shot_count: 27,
    match_id: 303634,
    match_date: '2020-07-16',
    home_team: 'Barcelona',
    away_team: 'Osasuna'
  },
  {
    shot_count: 26,
    match_id: 303596,
    match_date: '2019-12-18',
    home_team: 'Barcelona',
    away_team: 'Real Madrid'
  }
]
```

## Query 4: Home teams with the earliest average first shot

- Category: `Category 1: Join / lookup`
- Exit code: `0`

### Output
```text
[
  {
    matches_count: 1,
    home_team_name: 'Real Valladolid',
    avg_first_shot_minute: 0
  },
  {
    matches_count: 1,
    home_team_name: 'Sevilla',
    avg_first_shot_minute: 0
  },
  {
    matches_count: 1,
    home_team_name: 'Atlético Madrid',
    avg_first_shot_minute: 1
  },
  {
    matches_count: 1,
    home_team_name: 'Espanyol',
    avg_first_shot_minute: 1
  },
  {
    matches_count: 1,
    home_team_name: 'Granada',
    avg_first_shot_minute: 1
  },
  {
    matches_count: 1,
    home_team_name: 'Leganés',
    avg_first_shot_minute: 1
  },
  {
    matches_count: 1,
    home_team_name: 'Mallorca',
    avg_first_shot_minute: 1
  },
  {
    matches_count: 1,
    home_team_name: 'Deportivo Alavés',
    avg_first_shot_minute: 2
  },
  {
    matches_count: 1,
    home_team_name: 'Real Betis',
    avg_first_shot_minute: 2
  },
  {
    matches_count: 1,
    home_team_name: 'Valencia',
    avg_first_shot_minute: 3
  }
]
```

## Query 5: Card events by team and venue

- Category: `Category 1: Join / lookup`
- Exit code: `0`

### Output
```text
[
  {
    card_events: 13,
    team_name: 'Barcelona',
    venue: 'home',
    card_name: 'Yellow Card'
  },
  {
    card_events: 7,
    team_name: 'Barcelona',
    venue: 'away',
    card_name: 'Yellow Card'
  },
  {
    card_events: 2,
    team_name: 'Deportivo Alavés',
    venue: 'away',
    card_name: 'Yellow Card'
  },
  {
    card_events: 2,
    team_name: 'Espanyol',
    venue: 'away',
    card_name: 'Yellow Card'
  },
  {
    card_events: 1,
    team_name: 'Barcelona',
    venue: 'home',
    card_name: 'Red Card'
  },
  {
    card_events: 1,
    team_name: 'Celta Vigo',
    venue: 'home',
    card_name: 'Yellow Card'
  },
  {
    card_events: 1,
    team_name: 'Eibar',
    venue: 'away',
    card_name: 'Yellow Card'
  },
  {
    card_events: 1,
    team_name: 'Eibar',
    venue: 'home',
    card_name: 'Yellow Card'
  },
  {
    card_events: 1,
    team_name: 'Granada',
    venue: 'away',
    card_name: 'Yellow Card'
  },
  {
    card_events: 1,
    team_name: 'Leganés',
    venue: 'away',
    card_name: 'Yellow Card'
  }
]
```

## Query 6: Referees with the highest average number of fouls per match

- Category: `Category 1: Join / lookup`
- Exit code: `0`

### Output
```text
[
  {
    matches_officiated: 4,
    referee_name: 'Antonio Miguel Mateu Lahoz',
    avg_fouls_per_match: 31.5
  },
  {
    matches_officiated: 2,
    referee_name: 'Jesús Gil Manzano',
    avg_fouls_per_match: 31
  },
  {
    matches_officiated: 1,
    referee_name: 'José Luis González González',
    avg_fouls_per_match: 26
  }
]
```

## Query 7: Teams with the highest number of shot events

- Category: `Category 2: Aggregation / statistics`
- Exit code: `0`

### Output
```text
[
  { shot_count: 430, team_name: 'Barcelona', avg_shot_minute: 48.47 },
  { shot_count: 30, team_name: 'Real Madrid', avg_shot_minute: 43 },
  { shot_count: 29, team_name: 'Real Sociedad', avg_shot_minute: 51 },
  {
    shot_count: 26,
    team_name: 'Atlético Madrid',
    avg_shot_minute: 46.31
  },
  { shot_count: 24, team_name: 'Sevilla', avg_shot_minute: 45.83 },
  {
    shot_count: 22,
    team_name: 'Real Valladolid',
    avg_shot_minute: 50.73
  },
  { shot_count: 21, team_name: 'Mallorca', avg_shot_minute: 52.05 },
  { shot_count: 21, team_name: 'Villarreal', avg_shot_minute: 43.81 },
  { shot_count: 19, team_name: 'Espanyol', avg_shot_minute: 63.21 },
  { shot_count: 18, team_name: 'Eibar', avg_shot_minute: 42.67 }
]
```

## Query 8: Players with the longest average carry duration

- Category: `Category 2: Aggregation / statistics`
- Exit code: `0`

### Output
```text
[
  {
    carries: 36,
    player_id: 24140,
    player_name: 'Rui Tiago Dantas da Silva',
    team_name: 'Granada',
    avg_duration: 5.83
  },
  {
    carries: 843,
    player_id: 20055,
    player_name: 'Marc-André ter Stegen',
    team_name: 'Barcelona',
    avg_duration: 2.895
  },
  {
    carries: 71,
    player_id: 6709,
    player_name: 'Anaitz Arbilla Zabala',
    team_name: 'Eibar',
    avg_duration: 2.59
  },
  {
    carries: 44,
    player_id: 22128,
    player_name: 'Robin Aime Robert Le Normand',
    team_name: 'Real Sociedad',
    avg_duration: 2.523
  },
  {
    carries: 75,
    player_id: 31090,
    player_name: 'Takefusa Kubo',
    team_name: 'Mallorca',
    avg_duration: 2.512
  },
  {
    carries: 63,
    player_id: 4345,
    player_name: 'Lucas Ariel Ocampos',
    team_name: 'Sevilla',
    avg_duration: 2.453
  },
  {
    carries: 44,
    player_id: 11501,
    player_name: 'Darwin Daniel Machís Marcano',
    team_name: 'Granada',
    avg_duration: 2.39
  },
  {
    carries: 33,
    player_id: 6590,
    player_name: 'Norberto Murara Neto',
    team_name: 'Barcelona',
    avg_duration: 2.383
  },
  {
    carries: 31,
    player_id: 6755,
    player_name: 'Sergio Asenjo Andrés',
    team_name: 'Villarreal',
    avg_duration: 2.328
  },
  {
    carries: 110,
    player_id: 8252,
    player_name: 'Martin Ødegaard',
    team_name: 'Real Sociedad',
    avg_duration: 2.252
  }
]
```

## Query 9: Matches with the highest number of possession sequences

- Category: `Category 2: Aggregation / statistics`
- Exit code: `0`

### Output
```text
[
  {
    possession_sequences: 224,
    match_id: 303674,
    distinct_teams_involved: 2
  },
  {
    possession_sequences: 208,
    match_id: 303682,
    distinct_teams_involved: 2
  },
  {
    possession_sequences: 200,
    match_id: 303596,
    distinct_teams_involved: 2
  },
  {
    possession_sequences: 199,
    match_id: 303470,
    distinct_teams_involved: 2
  },
  {
    possession_sequences: 197,
    match_id: 303634,
    distinct_teams_involved: 2
  },
  {
    possession_sequences: 197,
    match_id: 303680,
    distinct_teams_involved: 2
  },
  {
    possession_sequences: 194,
    match_id: 303451,
    distinct_teams_involved: 2
  },
  {
    possession_sequences: 187,
    match_id: 303430,
    distinct_teams_involved: 2
  },
  {
    possession_sequences: 184,
    match_id: 303700,
    distinct_teams_involved: 2
  },
  {
    possession_sequences: 184,
    match_id: 303731,
    distinct_teams_involved: 2
  }
]
```

## Query 10: Distribution of shot outcomes

- Category: `Category 2: Aggregation / statistics`
- Exit code: `0`

### Output
```text
[
  { shot_outcome_name: 'Off T', shots: 224, share_pct: 29.79 },
  { shot_outcome_name: 'Saved', shots: 191, share_pct: 25.4 },
  { shot_outcome_name: 'Blocked', shots: 184, share_pct: 24.47 },
  { shot_outcome_name: 'Goal', shots: 101, share_pct: 13.43 },
  { shot_outcome_name: 'Wayward', shots: 27, share_pct: 3.59 },
  { shot_outcome_name: 'Post', shots: 18, share_pct: 2.39 },
  { shot_outcome_name: 'Saved Off Target', shots: 6, share_pct: 0.8 },
  { shot_outcome_name: 'Saved to Post', shots: 1, share_pct: 0.13 }
]
```

## Query 11: Teams with the best shot conversion rate

- Category: `Category 2: Aggregation / statistics`
- Exit code: `0`

### Output
```text
[
  {
    total_shots: 18,
    goals_scored: 4,
    team_name: 'Levante UD',
    conversion_rate_pct: 22.22
  },
  {
    total_shots: 16,
    goals_scored: 3,
    team_name: 'Celta Vigo',
    conversion_rate_pct: 18.75
  },
  {
    total_shots: 430,
    goals_scored: 70,
    team_name: 'Barcelona',
    conversion_rate_pct: 16.28
  },
  {
    total_shots: 14,
    goals_scored: 2,
    team_name: 'Granada',
    conversion_rate_pct: 14.29
  },
  {
    total_shots: 19,
    goals_scored: 2,
    team_name: 'Espanyol',
    conversion_rate_pct: 10.53
  },
  {
    total_shots: 21,
    goals_scored: 2,
    team_name: 'Mallorca',
    conversion_rate_pct: 9.52
  },
  {
    total_shots: 21,
    goals_scored: 2,
    team_name: 'Villarreal',
    conversion_rate_pct: 9.52
  },
  {
    total_shots: 12,
    goals_scored: 1,
    team_name: 'Deportivo Alavés',
    conversion_rate_pct: 8.33
  },
  {
    total_shots: 26,
    goals_scored: 2,
    team_name: 'Atlético Madrid',
    conversion_rate_pct: 7.69
  },
  {
    total_shots: 29,
    goals_scored: 2,
    team_name: 'Real Sociedad',
    conversion_rate_pct: 6.9
  }
]
```

## Query 12: Goal events by 15-minute interval

- Category: `Category 2: Aggregation / statistics`
- Exit code: `0`

### Output
```text
[
  { goals: 19, minute_band: '00-14' },
  { goals: 11, minute_band: '15-29' },
  { goals: 21, minute_band: '30-44' },
  { goals: 14, minute_band: '45-59' },
  { goals: 19, minute_band: '60-74' },
  { goals: 15, minute_band: '75-89' },
  { goals: 4, minute_band: '90+' }
]
```

## Query 13: Match passing leaders as embedded team documents

- Category: `Category 3: Nested / embedded documents`
- Exit code: `0`

### Output
```text
[
  {
    match_id: 303377,
    match_summary: {
      match_date: '2020-02-15',
      home_team: 'Barcelona',
      away_team: 'Getafe'
    },
    team: {
      team_id: 217,
      team_name: 'Barcelona',
      total_team_passes: 718,
      top_passers: [
        {
          player_id: 5203,
          player_name: 'Sergio Busquets i Burgos',
          country: 'Spain',
          position: 'Center Defensive Midfield',
          pass_count: 119,
          avg_pass_minute: 42.23,
          distinct_recipient_count: 13
        },
        {
          player_id: 5492,
          player_name: 'Samuel Yves Umtiti',
          country: 'France',
          position: 'Right Center Back',
          pass_count: 84,
          avg_pass_minute: 40.12,
          distinct_recipient_count: 11
        },
        {
          player_id: 5213,
          player_name: 'Gerard Piqué Bernabéu',
          country: 'Spain',
          position: 'Right Center Back',
          pass_count: 82,
          avg_pass_minute: 43.02,
          distinct_recipient_count: 10
        },
        {
          player_id: 20055,
          player_name: 'Marc-André ter Stegen',
          country: 'Germany',
          position: 'Goalkeeper',
          pass_count: 70,
          avg_pass_minute: 43.03,
          distinct_recipient_count: 11
        },
        {
          player_id: 11392,
          player_name: 'Arthur Henrique Ramos de Oliveira Melo',
          country: 'Brazil',
          position: 'Left Center Midfield',
          pass_count: 68,
          avg_pass_minute: 35.32,
          distinct_recipient_count: 11
        }
      ]
    }
  },
  {
    match_id: 303377,
    match_summary: {
      match_date: '2020-02-15',
      home_team: 'Barcelona',
      away_team: 'Getafe'
    },
    team: {
      team_id: 216,
      team_name: 'Getafe',
      total_team_passes: 243,
      top_passers: [
        {
          player_id: 17620,
          player_name: 'Marc Cucurella Saseta',
          country: 'Spain',
          position: 'Left Midfield',
          pass_count: 35,
          avg_pass_minute: 53.4,
          distinct_recipient_count: 11
        },
        {
          player_id: 6634,
          player_name: 'Djené Dakonam Ortega',
          country: 'Togo',
          position: 'Right Center Back',
          pass_count: 27,
          avg_pass_minute: 47.93,
          distinct_recipient_count: 9
        },
        {
          player_id: 6722,
          player_name: 'David Soria Solís',
          country: 'Spain',
          position: 'Goalkeeper',
          pass_count: 26,
          avg_pass_minute: 50.85,
          distinct_recipient_count: 9
        },
        {
          player_id: 6863,
          player_name: 'Mauro Wilney Arambarri Rosa',
          country: 'Uruguay',
          position: 'Right Defensive Midfield',
          pass_count: 26,
          avg_pass_minute: 49.12,
          distinct_recipient_count: 12
        },
        {
          player_id: 3991,
          player_name: 'Allan Romeo Nyom',
          country: 'Cameroon',
          position: 'Right Back',
          pass_count: 22,
          avg_pass_minute: 39.64,
          distinct_recipient_count: 6
        }
      ]
    }
  },
  {
    match_id: 303400,
    match_summary: {
      match_date: '2020-01-25',
      home_team: 'Valencia',
      away_team: 'Barcelona'
    },
    team: {
      team_id: 217,
      team_name: 'Barcelona',
      total_team_passes: 877,
      top_passers: [
        {
          player_id: 5203,
          player_name: 'Sergio Busquets i Burgos',
          country: 'Spain',
          position: 'Center Defensive Midfield',
          pass_count: 128,
          avg_pass_minute: 43.55,
          distinct_recipient_count: 11
        },
        {
          player_id: 6379,
          player_name: 'Sergi Roberto Carnicer',
          country: 'Spain',
          position: 'Right Back',
          pass_count: 113,
          avg_pass_minute: 42.3,
          distinct_recipient_count: 11
        },
        {
          player_id: 5211,
          player_name: 'Jordi Alba Ramos',
          country: 'Spain',
          position: 'Left Back',
          pass_count: 95,
          avg_pass_minute: 41.13,
          distinct_recipient_count: 11
        },
        {
          player_id: 5492,
          player_name: 'Samuel Yves Umtiti',
          country: 'France',
          position: 'Right Center Back',
          pass_count: 90,
          avg_pass_minute: 42.26,
          distinct_recipient_count: 10
        },
        {
          player_id: 5213,
          player_name: 'Gerard Piqué Bernabéu',
          country: 'Spain',
          position: 'Right Center Back',
          pass_count: 89,
          avg_pass_minute: 40.52,
          distinct_recipient_count: 11
        }
      ]
    }
  },
  {
    match_id: 303400,
    match_summary: {
      match_date: '2020-01-25',
      home_team: 'Valencia',
      away_team: 'Barcelona'
    },
    team: {
      team_id: 207,
      team_name: 'Valencia',
      total_team_passes: 325,
      top_passers: [
        {
          player_id: 6891,
          player_name: 'Ezequiel Marcelo Garay',
          country: 'Argentina',
          position: 'Right Center Back',
          pass_count: 50,
          avg_pass_minute: 40.16,
          distinct_recipient_count: 10
        },
        {
          player_id: 6797,
          player_name: 'Daniel Wass',
          country: 'Denmark',
          position: 'Right Back',
          pass_count: 42,
          avg_pass_minute: 35.38,
          distinct_recipient_count: 5
        },
        {
          player_id: 6589,
          player_name: 'Geoffrey Kondogbia',
          country: 'Central African Republic',
          position: 'Left Center Midfield',
          pass_count: 41,
          avg_pass_minute: 38.63,
          distinct_recipient_count: 10
        },
        {
          player_id: 6746,
          player_name: 'Gabriel Armando de Abreu',
          country: 'Brazil',
          position: 'Left Center Back',
          pass_count: 39,
          avg_pass_minute: 35.28,
          distinct_recipient_count: 8
        },
        {
          player_id: 6596,
          player_name: 'José Luis Gayà Peña',
          country: 'Spain',
          position: 'Left Back',
          pass_count: 29,
          avg_pass_minute: 41.72,
          distinct_recipient_count: 9
        }
      ]
    }
  },
  {
    match_id: 303421,
    match_summary: {
      match_date: '2020-07-19',
      home_team: 'Deportivo Alavés',
      away_team: 'Barcelona'
    },
    team: {
      team_id: 217,
      team_name: 'Barcelona',
      total_team_passes: 792,
      top_passers: [
        {
          player_id: 5211,
          player_name: 'Jordi Alba Ramos',
          country: 'Spain',
          position: 'Left Back',
          pass_count: 106,
          avg_pass_minute: 45.61,
          distinct_recipient_count: 12
        },
        {
          player_id: 8206,
          player_name: 'Arturo Erasmo Vidal Pardo',
          country: 'Chile',
          position: 'Left Wing',
          pass_count: 89,
          avg_pass_minute: 49.83,
          distinct_recipient_count: 13
        },
        {
          player_id: 6379,
          player_name: 'Sergi Roberto Carnicer',
          country: 'Spain',
          position: 'Right Back',
          pass_count: 84,
          avg_pass_minute: 47.08,
          distinct_recipient_count: 12
        },
        {
          player_id: 32480,
          player_name: 'Ronald Federico Araújo da Silva',
          country: 'Uruguay',
          position: 'Right Center Back',
          pass_count: 78,
          avg_pass_minute: 45.4,
          distinct_recipient_count: 10
        },
        {
          player_id: 24841,
          player_name: 'Ricard Puig Martí',
          country: 'Spain',
          position: 'Left Center Midfield',
          pass_count: 75,
          avg_pass_minute: 51.2,
          distinct_recipient_count: 12
        }
      ]
    }
  },
  {
    match_id: 303421,
    match_summary: {
      match_date: '2020-07-19',
      home_team: 'Deportivo Alavés',
      away_team: 'Barcelona'
    },
    team: {
      team_id: 206,
      team_name: 'Deportivo Alavés',
      total_team_passes: 376,
      top_passers: [
        {
          player_id: 6618,
          player_name: 'Martín Aguirregabiria Padilla',
          country: 'Spain',
          position: 'Right Back',
          pass_count: 49,
          avg_pass_minute: 40.8,
          distinct_recipient_count: 14
        },
        {
          player_id: 6659,
          player_name: 'Víctor Camarasa Ferrando',
          country: 'Spain',
          position: 'Right Center Midfield',
          pass_count: 39,
          avg_pass_minute: 38.08,
          distinct_recipient_count: 12
        },
        {
          player_id: 3265,
          player_name: 'José Luis Sanmartín Mato',
          country: 'Spain',
          position: 'Left Center Forward',
          pass_count: 36,
          avg_pass_minute: 39.94,
          distinct_recipient_count: 11
        },
        {
          player_id: 26387,
          player_name: 'Edgar Antonio Méndez Ortega',
          country: 'Spain',
          position: 'Right Midfield',
          pass_count: 31,
          avg_pass_minute: 42.23,
          distinct_recipient_count: 10
        },
        {
          player_id: 6571,
          player_name: 'Roberto Jiménez Gago',
          country: 'Spain',
          position: 'Goalkeeper',
          pass_count: 30,
          avg_pass_minute: 45.03,
          distinct_recipient_count: 10
        }
      ]
    }
  },
  {
    match_id: 303430,
    match_summary: {
      match_date: '2019-09-24',
      home_team: 'Barcelona',
      away_team: 'Villarreal'
    },
    team: {
      team_id: 217,
      team_name: 'Barcelona',
      total_team_passes: 679,
      top_passers: [
        {
          player_id: 11392,
          player_name: 'Arthur Henrique Ramos de Oliveira Melo',
          country: 'Brazil',
          position: 'Left Center Midfield',
          pass_count: 80,
          avg_pass_minute: 46.79,
          distinct_recipient_count: 12
        },
        {
          player_id: 6826,
          player_name: 'Clément Lenglet',
          country: 'France',
          position: 'Left Center Back',
          pass_count: 76,
          avg_pass_minute: 42.41,
          distinct_recipient_count: 9
        },
        {
          player_id: 5203,
          player_name: 'Sergio Busquets i Burgos',
          country: 'Spain',
          position: 'Center Defensive Midfield',
          pass_count: 73,
          avg_pass_minute: 41.66,
          distinct_recipient_count: 12
        },
        {
          player_id: 6374,
          player_name: 'Nélson Cabral Semedo',
          country: 'Portugal',
          position: 'Right Back',
          pass_count: 69,
          avg_pass_minute: 43.75,
          distinct_recipient_count: 11
        },
        {
          player_id: 5213,
          player_name: 'Gerard Piqué Bernabéu',
          country: 'Spain',
          position: 'Right Center Back',
          pass_count: 68,
          avg_pass_minute: 38.93,
          distinct_recipient_count: 12
        }
      ]
    }
  },
  {
    match_id: 303430,
    match_summary: {
      match_date: '2019-09-24',
      home_team: 'Barcelona',
      away_team: 'Villarreal'
    },
    team: {
      team_id: 222,
      team_name: 'Villarreal',
      total_team_passes: 515,
      top_passers: [
        {
          player_id: 24729,
          player_name: 'Xavier Quintillà Guasch',
          country: 'Spain',
          position: 'Left Back',
          pass_count: 66,
          avg_pass_minute: 37.14,
          distinct_recipient_count: 11
        },
        {
          player_id: 6892,
          player_name: 'Pau Francisco Torres',
          country: 'Spain',
          position: 'Left Center Back',
          pass_count: 61,
          avg_pass_minute: 39.26,
          distinct_recipient_count: 12
        },
        {
          player_id: 3497,
          player_name: 'Vicente Iborra De La Fuente',
          country: 'Spain',
          position: 'Left Center Midfield',
          pass_count: 60,
          avg_pass_minute: 41.58,
          distinct_recipient_count: 11
        },
        {
          player_id: 3141,
          player_name: 'André-Frank Zambo Anguissa',
          country: 'Cameroon',
          position: 'Right Center Midfield',
          pass_count: 58,
          avg_pass_minute: 37.36,
          distinct_recipient_count: 9
        },
        {
          player_id: 6710,
          player_name: 'Rubén Peña Jiménez',
          country: 'Spain',
          position: 'Right Back',
          pass_count: 57,
          avg_pass_minute: 36.63,
          distinct_recipient_count: 9
        }
      ]
    }
  },
  {
    match_id: 303451,
    match_summary: {
      match_date: '2019-12-07',
      home_team: 'Barcelona',
      away_team: 'Mallorca'
    },
    team: {
      team_id: 217,
      team_name: 'Barcelona',
      total_team_passes: 746,
      top_passers: [
        {
          player_id: 6379,
          player_name: 'Sergi Roberto Carnicer',
          country: 'Spain',
          position: 'Right Back',
          pass_count: 99,
          avg_pass_minute: 43.76,
          distinct_recipient_count: 13
        },
        {
          player_id: 5203,
          player_name: 'Sergio Busquets i Burgos',
          country: 'Spain',
          position: 'Center Defensive Midfield',
          pass_count: 89,
          avg_pass_minute: 45.88,
          distinct_recipient_count: 12
        },
        {
          player_id: 5503,
          player_name: 'Lionel Andrés Messi Cuccittini',
          country: 'Argentina',
          position: 'Right Wing',
          pass_count: 76,
          avg_pass_minute: 44.62,
          distinct_recipient_count: 12
        },
        {
          player_id: 6826,
          player_name: 'Clément Lenglet',
          country: 'France',
          position: 'Left Center Back',
          pass_count: 74,
          avg_pass_minute: 41.04,
          distinct_recipient_count: 11
        },
        {
          player_id: 5470,
          player_name: 'Ivan Rakitić',
          country: 'Croatia',
          position: 'Right Center Midfield',
          pass_count: 69,
          avg_pass_minute: 31.68,
          distinct_recipient_count: 9
        }
      ]
    }
  },
  {
    match_id: 303451,
    match_summary: {
      match_date: '2019-12-07',
      home_team: 'Barcelona',
      away_team: 'Mallorca'
    },
    team: {
      team_id: 1043,
      team_name: 'Mallorca',
      total_team_passes: 397,
      top_passers: [
        {
          player_id: 24072,
          player_name: 'Salvador Sevilla López',
          country: 'Spain',
          position: 'Left Center Midfield',
          pass_count: 45,
          avg_pass_minute: 28.13,
          distinct_recipient_count: 10
        },
        {
          player_id: 24089,
          player_name: 'Joan Sastre Vanrell',
          country: 'Spain',
          position: 'Left Back',
          pass_count: 40,
          avg_pass_minute: 40.8,
          distinct_recipient_count: 11
        },
        {
          player_id: 24088,
          player_name: 'Daniel José Rodríguez Vázquez',
          country: 'Spain',
          position: 'Left Midfield',
          pass_count: 39,
          avg_pass_minute: 46.72,
          distinct_recipient_count: 9
        },
        {
          player_id: 24083,
          player_name: 'Manuel Reina Rodríguez',
          country: 'Spain',
          position: 'Goalkeeper',
          pass_count: 38,
          avg_pass_minute: 44.95,
          distinct_recipient_count: 11
        },
        {
          player_id: 23986,
          player_name: 'Aleix Febas Pérez',
          country: 'Spain',
          position: 'Right Center Forward',
          pass_count: 37,
          avg_pass_minute: 48.35,
          distinct_recipient_count: 12
        }
      ]
    }
  }
]
```

## Query 14: Shot events with embedded shot profile

- Category: `Category 3: Nested / embedded documents`
- Exit code: `0`

### Output
```text
[
  {
    event_id: 'b86fd82f-2e58-4fed-b2c2-8fac48fe3588',
    team_name: 'Real Betis',
    player_name: 'Nabil Fekir',
    shot_profile: {
      outcome: 'Blocked',
      is_goal: false,
      is_on_target: false,
      minute_band: '00-14',
      location: { x: 109.2, y: 29.3 }
    }
  },
  {
    event_id: 'b6140248-2bed-492c-be40-0e08143ec5ef',
    team_name: 'Real Betis',
    player_name: 'Nabil Fekir',
    shot_profile: {
      outcome: 'Blocked',
      is_goal: false,
      is_on_target: false,
      minute_band: '45-59',
      location: { x: 100.7, y: 39.3 }
    }
  },
  {
    event_id: '46948f80-32be-4c12-b952-ae5cc46d2494',
    team_name: 'Real Sociedad',
    player_name: 'Mikel Merino Zazón',
    shot_profile: {
      outcome: 'Wayward',
      is_goal: false,
      is_on_target: false,
      minute_band: '45-59',
      location: { x: 99.9, y: 32.5 }
    }
  },
  {
    event_id: 'b30c4cff-f9d3-4af0-93d8-f1f1b76fd1b1',
    team_name: 'Real Sociedad',
    player_name: 'Mikel Merino Zazón',
    shot_profile: {
      outcome: 'Saved',
      is_goal: false,
      is_on_target: true,
      minute_band: '60-74',
      location: { x: 110.7, y: 35.7 }
    }
  },
  {
    event_id: 'd81723fe-e37e-423f-b196-dcb98b16b002',
    team_name: 'Espanyol',
    player_name: 'Sergi Darder Moll',
    shot_profile: {
      outcome: 'Off T',
      is_goal: false,
      is_on_target: false,
      minute_band: '75-89',
      location: { x: 99.8, y: 55.7 }
    }
  },
  {
    event_id: '0ad362aa-e40d-4596-8272-d16d441ed2ef',
    team_name: 'Espanyol',
    player_name: 'Sergi Darder Moll',
    shot_profile: {
      outcome: 'Off T',
      is_goal: false,
      is_on_target: false,
      minute_band: '45-59',
      location: { x: 86.3, y: 30.8 }
    }
  },
  {
    event_id: '11d17bfa-e3f0-4a1c-a15c-3f6edda3968d',
    team_name: 'Leganés',
    player_name: 'Guido Marcelo Carrillo',
    shot_profile: {
      outcome: 'Off T',
      is_goal: false,
      is_on_target: false,
      minute_band: '75-89',
      location: { x: 102, y: 35.1 }
    }
  },
  {
    event_id: 'cd788467-ed99-4798-9bf1-b817c440f0a2',
    team_name: 'Deportivo Alavés',
    player_name: 'José Luis Sanmartín Mato',
    shot_profile: {
      outcome: 'Blocked',
      is_goal: false,
      is_on_target: false,
      minute_band: '30-44',
      location: { x: 92, y: 31.6 }
    }
  },
  {
    event_id: '28d5e4a6-b40c-44db-af67-4d9dc5c77836',
    team_name: 'Deportivo Alavés',
    player_name: 'José Luis Sanmartín Mato',
    shot_profile: {
      outcome: 'Off T',
      is_goal: false,
      is_on_target: false,
      minute_band: '75-89',
      location: { x: 102.7, y: 43.8 }
    }
  },
  {
    event_id: 'd206b236-62ee-4728-8954-6f6b4f7fd239',
    team_name: 'Deportivo Alavés',
    player_name: 'José Luis Sanmartín Mato',
    shot_profile: {
      outcome: 'Off T',
      is_goal: false,
      is_on_target: false,
      minute_band: '75-89',
      location: { x: 105.6, y: 22.9 }
    }
  }
]
```

## Query 15: Teams with embedded disciplinary profiles by venue and card type

- Category: `Category 3: Nested / embedded documents`
- Exit code: `0`

### Output
```text
[
  {
    team: { team_id: 217, team_name: 'Barcelona' },
    disciplinary_profile: {
      total_cards: 21,
      yellow_cards: 20,
      red_cards: 1,
      venue_profiles: [
        {
          venue: 'home',
          total_cards: 14,
          yellow_cards: 13,
          red_cards: 1,
          card_breakdown: [
            { card_name: 'Yellow Card', card_events: 13 },
            { card_name: 'Red Card', card_events: 1 }
          ]
        },
        {
          venue: 'away',
          total_cards: 7,
          yellow_cards: 7,
          red_cards: 0,
          card_breakdown: [ { card_name: 'Yellow Card', card_events: 7 } ]
        }
      ]
    }
  },
  {
    team: { team_id: 206, team_name: 'Deportivo Alavés' },
    disciplinary_profile: {
      total_cards: 2,
      yellow_cards: 2,
      red_cards: 0,
      venue_profiles: [
        {
          venue: 'away',
          total_cards: 2,
          yellow_cards: 2,
          red_cards: 0,
          card_breakdown: [ { card_name: 'Yellow Card', card_events: 2 } ]
        }
      ]
    }
  },
  {
    team: { team_id: 322, team_name: 'Eibar' },
    disciplinary_profile: {
      total_cards: 2,
      yellow_cards: 2,
      red_cards: 0,
      venue_profiles: [
        {
          venue: 'away',
          total_cards: 1,
          yellow_cards: 1,
          red_cards: 0,
          card_breakdown: [ { card_name: 'Yellow Card', card_events: 1 } ]
        },
        {
          venue: 'home',
          total_cards: 1,
          yellow_cards: 1,
          red_cards: 0,
          card_breakdown: [ { card_name: 'Yellow Card', card_events: 1 } ]
        }
      ]
    }
  },
  {
    team: { team_id: 214, team_name: 'Espanyol' },
    disciplinary_profile: {
      total_cards: 2,
      yellow_cards: 2,
      red_cards: 0,
      venue_profiles: [
        {
          venue: 'away',
          total_cards: 2,
          yellow_cards: 2,
          red_cards: 0,
          card_breakdown: [ { card_name: 'Yellow Card', card_events: 2 } ]
        }
      ]
    }
  },
  {
    team: { team_id: 218, team_name: 'Real Betis' },
    disciplinary_profile: {
      total_cards: 2,
      yellow_cards: 1,
      red_cards: 1,
      venue_profiles: [
        {
          venue: 'home',
          total_cards: 2,
          yellow_cards: 1,
          red_cards: 1,
          card_breakdown: [
            { card_name: 'Second Yellow', card_events: 1 },
            { card_name: 'Yellow Card', card_events: 1 }
          ]
        }
      ]
    }
  },
  {
    team: { team_id: 209, team_name: 'Celta Vigo' },
    disciplinary_profile: {
      total_cards: 1,
      yellow_cards: 1,
      red_cards: 0,
      venue_profiles: [
        {
          venue: 'home',
          total_cards: 1,
          yellow_cards: 1,
          red_cards: 0,
          card_breakdown: [ { card_name: 'Yellow Card', card_events: 1 } ]
        }
      ]
    }
  },
  {
    team: { team_id: 1049, team_name: 'Granada' },
    disciplinary_profile: {
      total_cards: 1,
      yellow_cards: 1,
      red_cards: 0,
      venue_profiles: [
        {
          venue: 'away',
          total_cards: 1,
          yellow_cards: 1,
          red_cards: 0,
          card_breakdown: [ { card_name: 'Yellow Card', card_events: 1 } ]
        }
      ]
    }
  },
  {
    team: { team_id: 205, team_name: 'Leganés' },
    disciplinary_profile: {
      total_cards: 1,
      yellow_cards: 1,
      red_cards: 0,
      venue_profiles: [
        {
          venue: 'away',
          total_cards: 1,
          yellow_cards: 1,
          red_cards: 0,
          card_breakdown: [ { card_name: 'Yellow Card', card_events: 1 } ]
        }
      ]
    }
  },
  {
    team: { team_id: 422, team_name: 'Osasuna' },
    disciplinary_profile: {
      total_cards: 1,
      yellow_cards: 1,
      red_cards: 0,
      venue_profiles: [
        {
          venue: 'away',
          total_cards: 1,
          yellow_cards: 1,
          red_cards: 0,
          card_breakdown: [ { card_name: 'Yellow Card', card_events: 1 } ]
        }
      ]
    }
  },
  {
    team: { team_id: 220, team_name: 'Real Madrid' },
    disciplinary_profile: {
      total_cards: 1,
      yellow_cards: 1,
      red_cards: 0,
      venue_profiles: [
        {
          venue: 'home',
          total_cards: 1,
          yellow_cards: 1,
          red_cards: 0,
          card_breakdown: [ { card_name: 'Yellow Card', card_events: 1 } ]
        }
      ]
    }
  }
]
```

## Query 16: Player activity profiles as embedded documents

- Category: `Category 3: Nested / embedded documents`
- Exit code: `0`

### Output
```text
[
  {
    player: {
      player_id: 5213,
      player_name: 'Gerard Piqué Bernabéu',
      team_name: 'Barcelona'
    },
    activity_profile: {
      passes: 2282,
      shots: 14,
      carries: 1813,
      fouls_committed: 29,
      pressures: 218
    }
  },
  {
    player: {
      player_id: 5203,
      player_name: 'Sergio Busquets i Burgos',
      team_name: 'Barcelona'
    },
    activity_profile: {
      passes: 2280,
      shots: 8,
      carries: 1700,
      fouls_committed: 47,
      pressures: 451
    }
  },
  {
    player: {
      player_id: 5503,
      player_name: 'Lionel Andrés Messi Cuccittini',
      team_name: 'Barcelona'
    },
    activity_profile: {
      passes: 2142,
      shots: 159,
      carries: 2226,
      fouls_committed: 21,
      pressures: 287
    }
  },
  {
    player: {
      player_id: 6379,
      player_name: 'Sergi Roberto Carnicer',
      team_name: 'Barcelona'
    },
    activity_profile: {
      passes: 1883,
      shots: 6,
      carries: 1556,
      fouls_committed: 16,
      pressures: 212
    }
  },
  {
    player: {
      player_id: 6826,
      player_name: 'Clément Lenglet',
      team_name: 'Barcelona'
    },
    activity_profile: {
      passes: 1762,
      shots: 9,
      carries: 1443,
      fouls_committed: 28,
      pressures: 235
    }
  },
  {
    player: {
      player_id: 5211,
      player_name: 'Jordi Alba Ramos',
      team_name: 'Barcelona'
    },
    activity_profile: {
      passes: 1719,
      shots: 5,
      carries: 1293,
      fouls_committed: 17,
      pressures: 198
    }
  },
  {
    player: {
      player_id: 5470,
      player_name: 'Ivan Rakitić',
      team_name: 'Barcelona'
    },
    activity_profile: {
      passes: 1411,
      shots: 21,
      carries: 1112,
      fouls_committed: 22,
      pressures: 280
    }
  },
  {
    player: {
      player_id: 6374,
      player_name: 'Nélson Cabral Semedo',
      team_name: 'Barcelona'
    },
    activity_profile: {
      passes: 1385,
      shots: 6,
      carries: 1196,
      fouls_committed: 22,
      pressures: 256
    }
  },
  {
    player: {
      player_id: 8118,
      player_name: 'Frenkie de Jong',
      team_name: 'Barcelona'
    },
    activity_profile: {
      passes: 1363,
      shots: 3,
      carries: 1250,
      fouls_committed: 19,
      pressures: 262
    }
  },
  {
    player: {
      player_id: 20055,
      player_name: 'Marc-André ter Stegen',
      team_name: 'Barcelona'
    },
    activity_profile: {
      passes: 1263,
      shots: 0,
      carries: 843,
      fouls_committed: 0,
      pressures: 5
    }
  }
]
```

## Query 17: Match documents normalized into embedded match summaries

- Category: `Category 3: Nested / embedded documents`
- Exit code: `0`

### Output
```text
[
  {
    match_id: 303377,
    match_summary: {
      date: '2020-02-15',
      kick_off: '16:00:00.000',
      season: '2019/2020',
      competition: 'La Liga',
      stage: 'Regular Season'
    },
    teams: {
      home: { team_id: 217, team_name: 'Barcelona', score: 2 },
      away: { team_id: 216, team_name: 'Getafe', score: 1 }
    },
    venue: { stadium_id: 342, stadium_name: 'Spotify Camp Nou' },
    officiating: { referee_id: null, referee_name: 'Unknown referee' }
  },
  {
    match_id: 303400,
    match_summary: {
      date: '2020-01-25',
      kick_off: '16:00:00.000',
      season: '2019/2020',
      competition: 'La Liga',
      stage: 'Regular Season'
    },
    teams: {
      home: { team_id: 207, team_name: 'Valencia', score: 2 },
      away: { team_id: 217, team_name: 'Barcelona', score: 0 }
    },
    venue: { stadium_id: 344, stadium_name: 'Estadio de Mestalla' },
    officiating: { referee_id: 183, referee_name: 'Jesús Gil Manzano' }
  },
  {
    match_id: 303421,
    match_summary: {
      date: '2020-07-19',
      kick_off: '17:00:00.000',
      season: '2019/2020',
      competition: 'La Liga',
      stage: 'Regular Season'
    },
    teams: {
      home: { team_id: 206, team_name: 'Deportivo Alavés', score: 0 },
      away: { team_id: 217, team_name: 'Barcelona', score: 5 }
    },
    venue: { stadium_id: 348, stadium_name: 'Estadio de Mendizorroza' },
    officiating: { referee_id: null, referee_name: 'Unknown referee' }
  },
  {
    match_id: 303430,
    match_summary: {
      date: '2019-09-24',
      kick_off: '21:00:00.000',
      season: '2019/2020',
      competition: 'La Liga',
      stage: 'Regular Season'
    },
    teams: {
      home: { team_id: 217, team_name: 'Barcelona', score: 2 },
      away: { team_id: 222, team_name: 'Villarreal', score: 1 }
    },
    venue: { stadium_id: 342, stadium_name: 'Spotify Camp Nou' },
    officiating: { referee_id: null, referee_name: 'Unknown referee' }
  },
  {
    match_id: 303451,
    match_summary: {
      date: '2019-12-07',
      kick_off: '21:00:00.000',
      season: '2019/2020',
      competition: 'La Liga',
      stage: 'Regular Season'
    },
    teams: {
      home: { team_id: 217, team_name: 'Barcelona', score: 5 },
      away: { team_id: 1043, team_name: 'Mallorca', score: 2 }
    },
    venue: { stadium_id: 342, stadium_name: 'Spotify Camp Nou' },
    officiating: { referee_id: null, referee_name: 'Unknown referee' }
  },
  {
    match_id: 303470,
    match_summary: {
      date: '2020-03-01',
      kick_off: '21:00:00.000',
      season: '2019/2020',
      competition: 'La Liga',
      stage: 'Regular Season'
    },
    teams: {
      home: { team_id: 220, team_name: 'Real Madrid', score: 2 },
      away: { team_id: 217, team_name: 'Barcelona', score: 0 }
    },
    venue: { stadium_id: 353, stadium_name: 'Estadio Santiago Bernabéu' },
    officiating: { referee_id: 180, referee_name: 'Antonio Miguel Mateu Lahoz' }
  },
  {
    match_id: 303473,
    match_summary: {
      date: '2019-10-06',
      kick_off: '21:00:00.000',
      season: '2019/2020',
      competition: 'La Liga',
      stage: 'Regular Season'
    },
    teams: {
      home: { team_id: 217, team_name: 'Barcelona', score: 4 },
      away: { team_id: 213, team_name: 'Sevilla', score: 0 }
    },
    venue: { stadium_id: 342, stadium_name: 'Spotify Camp Nou' },
    officiating: { referee_id: 180, referee_name: 'Antonio Miguel Mateu Lahoz' }
  },
  {
    match_id: 303479,
    match_summary: {
      date: '2020-03-07',
      kick_off: '18:30:00.000',
      season: '2019/2020',
      competition: 'La Liga',
      stage: 'Regular Season'
    },
    teams: {
      home: { team_id: 217, team_name: 'Barcelona', score: 1 },
      away: { team_id: 210, team_name: 'Real Sociedad', score: 0 }
    },
    venue: { stadium_id: 342, stadium_name: 'Spotify Camp Nou' },
    officiating: { referee_id: null, referee_name: 'Unknown referee' }
  },
  {
    match_id: 303487,
    match_summary: {
      date: '2019-11-09',
      kick_off: '21:00:00.000',
      season: '2019/2020',
      competition: 'La Liga',
      stage: 'Regular Season'
    },
    teams: {
      home: { team_id: 217, team_name: 'Barcelona', score: 4 },
      away: { team_id: 209, team_name: 'Celta Vigo', score: 1 }
    },
    venue: { stadium_id: 342, stadium_name: 'Spotify Camp Nou' },
    officiating: { referee_id: null, referee_name: 'Unknown referee' }
  },
  {
    match_id: 303493,
    match_summary: {
      date: '2020-06-23',
      kick_off: '22:00:00.000',
      season: '2019/2020',
      competition: 'La Liga',
      stage: 'Regular Season'
    },
    teams: {
      home: { team_id: 217, team_name: 'Barcelona', score: 1 },
      away: { team_id: 215, team_name: 'Athletic Club', score: 0 }
    },
    venue: { stadium_id: 342, stadium_name: 'Spotify Camp Nou' },
    officiating: { referee_id: 183, referee_name: 'Jesús Gil Manzano' }
  }
]
```

## Query 18: Matches with embedded period statistics arrays

- Category: `Category 3: Nested / embedded documents`
- Exit code: `0`

### Output
```text
[
  {
    period_stats: [
      { period: 1, shots: 15, fouls_committed: 14, cards: 0 },
      { period: 2, shots: 19, fouls_committed: 15, cards: 0 }
    ],
    total_shots: 34,
    match_id: 303451
  },
  {
    period_stats: [
      { period: 1, shots: 11, fouls_committed: 10, cards: 0 },
      { period: 2, shots: 21, fouls_committed: 8, cards: 1 }
    ],
    total_shots: 32,
    match_id: 303682
  },
  {
    period_stats: [
      { period: 2, shots: 16, fouls_committed: 15, cards: 5 },
      { period: 1, shots: 15, fouls_committed: 11, cards: 0 }
    ],
    total_shots: 31,
    match_id: 303473
  },
  {
    period_stats: [
      { period: 1, shots: 16, fouls_committed: 14, cards: 0 },
      { period: 2, shots: 13, fouls_committed: 20, cards: 0 }
    ],
    total_shots: 29,
    match_id: 303524
  },
  {
    period_stats: [
      { period: 2, shots: 13, fouls_committed: 22, cards: 2 },
      { period: 1, shots: 15, fouls_committed: 11, cards: 0 }
    ],
    total_shots: 28,
    match_id: 303516
  },
  {
    period_stats: [
      { period: 2, shots: 17, fouls_committed: 9, cards: 1 },
      { period: 1, shots: 11, fouls_committed: 10, cards: 0 }
    ],
    total_shots: 28,
    match_id: 303664
  },
  {
    period_stats: [
      { period: 2, shots: 14, fouls_committed: 17, cards: 0 },
      { period: 1, shots: 14, fouls_committed: 6, cards: 0 }
    ],
    total_shots: 28,
    match_id: 303725
  },
  {
    period_stats: [
      { period: 2, shots: 12, fouls_committed: 9, cards: 0 },
      { period: 1, shots: 15, fouls_committed: 15, cards: 0 }
    ],
    total_shots: 27,
    match_id: 303600
  },
  {
    period_stats: [
      { period: 2, shots: 14, fouls_committed: 16, cards: 3 },
      { period: 1, shots: 13, fouls_committed: 6, cards: 0 }
    ],
    total_shots: 27,
    match_id: 303634
  },
  {
    period_stats: [
      { period: 1, shots: 15, fouls_committed: 13, cards: 0 },
      { period: 2, shots: 11, fouls_committed: 17, cards: 0 }
    ],
    total_shots: 26,
    match_id: 303596
  }
]
```

## Query 19: Consolidated index catalog with usage totals across all shards

- Category: `Category 4: Indexes / performance`
- Exit code: `0`

### Output
```text
[
  {
    total_access_ops: Long('75'),
    shards_reporting: [ 'shard01rs', 'shard03rs', 'shard02rs' ],
    first_tracked: ISODate('2026-04-20T20:44:46.295Z'),
    index_name: 'ix_events_player_id',
    key: { player_id: 1 },
    shard_count: 3,
    host_count: 3
  },
  {
    total_access_ops: Long('45'),
    shards_reporting: [ 'shard01rs', 'shard03rs', 'shard02rs' ],
    first_tracked: ISODate('2026-04-20T20:44:45.850Z'),
    index_name: 'ix_events_match_id',
    key: { match_id: 1 },
    shard_count: 3,
    host_count: 3
  },
  {
    total_access_ops: Long('45'),
    shards_reporting: [ 'shard02rs', 'shard03rs', 'shard01rs' ],
    first_tracked: ISODate('2026-04-20T20:44:46.755Z'),
    index_name: 'ix_events_team_type',
    key: { team_id: 1, event_type_name: 1 },
    shard_count: 3,
    host_count: 3
  },
  {
    total_access_ops: Long('0'),
    shards_reporting: [ 'shard01rs', 'shard03rs', 'shard02rs' ],
    first_tracked: ISODate('2026-04-20T20:44:27.701Z'),
    index_name: '_id_',
    key: { _id: 1 },
    shard_count: 3,
    host_count: 3
  },
  {
    total_access_ops: Long('0'),
    shards_reporting: [ 'shard02rs', 'shard03rs', 'shard01rs' ],
    first_tracked: ISODate('2026-04-20T20:44:27.722Z'),
    index_name: 'event_id_hashed',
    key: { event_id: 'hashed' },
    shard_count: 3,
    host_count: 3
  },
  {
    total_access_ops: Long('0'),
    shards_reporting: [ 'shard01rs', 'shard03rs', 'shard02rs' ],
    first_tracked: ISODate('2026-04-20T20:44:47.165Z'),
    index_name: 'ix_events_season_minute',
    key: { season: 1, minute: 1 },
    shard_count: 3,
    host_count: 3
  }
]
```

## Query 20: Unused indexes since statistics tracking started

- Category: `Category 4: Indexes / performance`
- Exit code: `0`

### Output
```text
[
  {
    total_access_ops: Long('0'),
    first_tracked: ISODate('2026-04-20T20:44:27.701Z'),
    index_name: '_id_',
    key: { _id: 1 },
    shard_count: 3,
    is_unused_since_tracking_started: true
  },
  {
    total_access_ops: Long('0'),
    first_tracked: ISODate('2026-04-20T20:44:27.722Z'),
    index_name: 'event_id_hashed',
    key: { event_id: 'hashed' },
    shard_count: 3,
    is_unused_since_tracking_started: true
  },
  {
    total_access_ops: Long('0'),
    first_tracked: ISODate('2026-04-20T20:44:47.165Z'),
    index_name: 'ix_events_season_minute',
    key: { season: 1, minute: 1 },
    shard_count: 3,
    is_unused_since_tracking_started: true
  }
]
```

## Query 21: Comparative benchmark of the main analytical indexes

- Category: `Category 4: Indexes / performance`
- Exit code: `0`

### Output
```text
[
  {
    scenario: 'match_id exact filter',
    leaf_stage: 'IXSCAN',
    index_name: 'ix_events_match_id',
    totalDocsExamined: 4068,
    totalKeysExamined: 4068,
    nReturned: 4068,
    keys_per_returned: 1,
    docs_per_returned: 1
  },
  {
    scenario: 'player_id exact filter',
    leaf_stage: 'IXSCAN',
    index_name: 'ix_events_player_id',
    totalDocsExamined: 8137,
    totalKeysExamined: 8137,
    nReturned: 8137,
    keys_per_returned: 1,
    docs_per_returned: 1
  },
  {
    scenario: 'team_id + event_type_name',
    leaf_stage: 'IXSCAN',
    index_name: 'ix_events_team_type',
    totalDocsExamined: 24618,
    totalKeysExamined: 24618,
    nReturned: 24618,
    keys_per_returned: 1,
    docs_per_returned: 1
  },
  {
    scenario: 'season + minute with sort',
    leaf_stage: 'IXSCAN',
    index_name: 'ix_events_season_minute',
    totalDocsExamined: 60,
    totalKeysExamined: 60,
    nReturned: 60,
    keys_per_returned: 1,
    docs_per_returned: 1
  }
]
```

## Query 22: Prefix behavior of the compound `team_id + event_type_name` index

- Category: `Category 4: Indexes / performance`
- Exit code: `0`

### Output
```text
[
  {
    scenario: 'team_id only',
    leaf_stage: 'IXSCAN',
    index_name: 'ix_events_team_type',
    totalDocsExamined: 60,
    totalKeysExamined: 60,
    nReturned: 60
  },
  {
    scenario: 'team_id + event_type_name',
    leaf_stage: 'IXSCAN',
    index_name: 'ix_events_team_type',
    totalDocsExamined: 60,
    totalKeysExamined: 60,
    nReturned: 60
  },
  {
    scenario: 'event_type_name only',
    leaf_stage: 'COLLSCAN',
    index_name: null,
    totalDocsExamined: 228,
    totalKeysExamined: 0,
    nReturned: 60
  }
]
```

## Query 23: Comparison of indexed sorting versus blocking sort

- Category: `Category 4: Indexes / performance`
- Exit code: `0`

### Output
```text
[
  {
    scenario: 'indexed season filter + minute sort',
    leaf_stage: 'IXSCAN',
    index_name: 'ix_events_season_minute',
    has_blocking_sort: false,
    totalDocsExamined: 60,
    totalKeysExamined: 60,
    nReturned: 60
  },
  {
    scenario: 'non-indexed team_name filter + minute sort',
    leaf_stage: 'COLLSCAN',
    index_name: null,
    has_blocking_sort: true,
    totalDocsExamined: 129058,
    totalKeysExamined: 0,
    nReturned: 60
  }
]
```

## Query 24: Per-shard index storage overhead on the `events` collection

- Category: `Category 4: Indexes / performance`
- Exit code: `0`

### Output
```text
[
  {
    shard: 'shard03rs',
    count: 43105,
    size: 28312382,
    avgObjSize: 656,
    totalIndexSize: 5918720,
    index_to_data_ratio_pct: 20.91,
    largest_index_name: 'event_id_hashed',
    largest_index_size: 2650112
  },
  {
    shard: 'shard02rs',
    count: 42589,
    size: 27970848,
    avgObjSize: 656,
    totalIndexSize: 5574656,
    index_to_data_ratio_pct: 19.93,
    largest_index_name: 'event_id_hashed',
    largest_index_size: 2461696
  },
  {
    shard: 'shard01rs',
    count: 43364,
    size: 28476727,
    avgObjSize: 656,
    totalIndexSize: 5095424,
    index_to_data_ratio_pct: 17.89,
    largest_index_name: 'event_id_hashed',
    largest_index_size: 2256896
  }
]
```

## Query 25: Chunk ownership by shard with representative hashed boundaries

- Category: `Category 5: Cluster / sharding / admin`
- Exit code: `0`

### Output
```text
[
  {
    chunk_count: 1,
    first_chunk_min: { event_id: Long('-3074457345618258602') },
    last_chunk_max: { event_id: Long('3074457345618258602') },
    shard: 'shard01rs',
    host: 'shard01rs/shard01a:27018,shard01b:27018,shard01c:27018',
    state: 1
  },
  {
    chunk_count: 1,
    first_chunk_min: { event_id: Long('3074457345618258602') },
    last_chunk_max: { event_id: MaxKey() },
    shard: 'shard02rs',
    host: 'shard02rs/shard02a:27018,shard02b:27018,shard02c:27018',
    state: 1
  },
  {
    chunk_count: 1,
    first_chunk_min: { event_id: MinKey() },
    last_chunk_max: { event_id: Long('-3074457345618258602') },
    shard: 'shard03rs',
    host: 'shard03rs/shard03a:27018,shard03b:27018,shard03c:27018',
    state: 1
  }
]
```

## Query 26: Chunk balance deviation from the ideal equal distribution

- Category: `Category 5: Cluster / sharding / admin`
- Exit code: `0`

### Output
```text
[
  {
    total_chunks: 3,
    shard: 'shard01rs',
    chunk_count: 1,
    ideal_chunks_per_shard: 1,
    share_pct: 33.33,
    deviation_from_ideal_pct: 0
  },
  {
    total_chunks: 3,
    shard: 'shard02rs',
    chunk_count: 1,
    ideal_chunks_per_shard: 1,
    share_pct: 33.33,
    deviation_from_ideal_pct: 0
  },
  {
    total_chunks: 3,
    shard: 'shard03rs',
    chunk_count: 1,
    ideal_chunks_per_shard: 1,
    share_pct: 33.33,
    deviation_from_ideal_pct: 0
  }
]
```

## Query 27: Cluster operation history for collection lifecycle and sharding events

- Category: `Category 5: Cluster / sharding / admin`
- Exit code: `0`

### Output
```text
[
  {
    operations: 5,
    first_seen: ISODate('2026-04-20T20:42:59.226Z'),
    last_seen: ISODate('2026-04-20T20:44:28.418Z'),
    namespaces: [ 'statsbomb.players', 'statsbomb.events', 'statsbomb.matches' ],
    operation: 'dropCollection',
    server: 'shard01a'
  },
  {
    operations: 5,
    first_seen: ISODate('2026-04-20T20:42:59.024Z'),
    last_seen: ISODate('2026-04-20T20:44:28.295Z'),
    namespaces: [ 'statsbomb.matches', 'statsbomb.players', 'statsbomb.events' ],
    operation: 'dropCollection.start',
    server: 'shard01a'
  },
  {
    operations: 2,
    first_seen: ISODate('2026-04-20T20:43:00.471Z'),
    last_seen: ISODate('2026-04-20T20:44:27.890Z'),
    namespaces: [ 'statsbomb.events' ],
    operation: 'shardCollection.end',
    server: 'shard01a'
  },
  {
    operations: 2,
    first_seen: ISODate('2026-04-20T20:43:00.279Z'),
    last_seen: ISODate('2026-04-20T20:44:27.593Z'),
    namespaces: [ 'statsbomb.events' ],
    operation: 'shardCollection.start',
    server: 'shard01a'
  }
]
```

## Query 28: Replication lag and sync-source analysis inside `shard01rs`

- Category: `Category 5: Cluster / sharding / admin`
- Executed on: `shard01b`
- Exit code: `0`

### Output
```text
[
  {
    name: 'shard01a:27018',
    state: 'SECONDARY',
    health: 1,
    sync_source: 'shard01b:27018',
    optimeDate: ISODate('2026-04-20T21:21:02.000Z'),
    replication_lag_seconds: 0
  },
  {
    name: 'shard01b:27018',
    state: 'PRIMARY',
    health: 1,
    sync_source: null,
    optimeDate: ISODate('2026-04-20T21:21:02.000Z'),
    replication_lag_seconds: 0
  },
  {
    name: 'shard01c:27018',
    state: 'SECONDARY',
    health: 1,
    sync_source: 'shard01b:27018',
    optimeDate: ISODate('2026-04-20T21:21:02.000Z'),
    replication_lag_seconds: 0
  }
]
```

## Query 29: Validation schema audit for all application collections

- Category: `Category 5: Cluster / sharding / admin`
- Exit code: `0`

### Output
```text
[
  {
    name: 'events',
    validationLevel: 'strict',
    validationAction: 'error',
    required_fields: [
      'event_id',
      'match_id',
      'season',
      'index',
      'period',
      'timestamp',
      'minute',
      'second',
      'event_type_name'
    ],
    required_field_count: 9,
    validated_property_count: 28
  },
  {
    name: 'matches',
    validationLevel: 'strict',
    validationAction: 'error',
    required_fields: [
      'match_id',
      'match_date',
      'season',
      'competition_id',
      'competition_name',
      'home_team_id',
      'home_team_name',
      'away_team_id',
      'away_team_name'
    ],
    required_field_count: 9,
    validated_property_count: 18
  },
  {
    name: 'players',
    validationLevel: 'strict',
    validationAction: 'error',
    required_fields: [
      'player_id',
      'player_name',
      'jersey_number',
      'country',
      'team_id',
      'team_name',
      'season'
    ],
    required_field_count: 7,
    validated_property_count: 9
  }
]
```

## Query 30: Administrative users expanded into a role matrix

- Category: `Category 5: Cluster / sharding / admin`
- Exit code: `0`

### Output
```text
[
  {
    roles: [ { role: 'root', db: 'admin' } ],
    role_count: 1,
    user: 'admin',
    auth_db: 'admin'
  },
  {
    roles: [ { role: 'readWrite', db: 'statsbomb' } ],
    role_count: 1,
    user: 'statsbomb_user',
    auth_db: 'statsbomb'
  }
]
```
