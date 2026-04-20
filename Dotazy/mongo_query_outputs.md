# Mongo Query Outputs

Source: `c:\Users\deniz\Desktop\mongodb-semestral-project\Dotazy\mongo_queries.md`
Total queries executed: `31`

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

## Query 13: Pass events reshaped into nested documents

- Category: `Category 3: Nested / embedded documents`
- Exit code: `0`

### Output
```text
[
  {
    event_id: 'f482387a-fce6-41b2-8cbc-326acbf78030',
    match_context: {
      match_id: 303707,
      season: '2019/2020',
      period: 1,
      minute: 7,
      second: 15
    },
    player_info: {
      player_id: 2948,
      player_name: 'Nabil Fekir',
      team_id: 218,
      team_name: 'Real Betis',
      position_name: 'Left Midfield'
    },
    pass_context: {
      recipient_id: 11538,
      recipient_name: 'Alejandro Moreno Lopera',
      play_pattern_name: 'Regular Play',
      duration: 0.351893
    },
    location: { x: 39.6, y: 3.4 }
  },
  {
    event_id: '4cd5c32d-71c4-4979-8eb9-6c42899c4bbb',
    match_context: {
      match_id: 303707,
      season: '2019/2020',
      period: 1,
      minute: 15,
      second: 53
    },
    player_info: {
      player_id: 2948,
      player_name: 'Nabil Fekir',
      team_id: 218,
      team_name: 'Real Betis',
      position_name: 'Left Midfield'
    },
    pass_context: {
      recipient_id: 23522,
      recipient_name: 'Emerson Aparecido Leite de Souza Junior',
      play_pattern_name: 'From Throw In',
      duration: 0.587587
    },
    location: { x: 55.7, y: 69.7 }
  },
  {
    event_id: '4d7ed2b0-c99a-46bb-9935-25acc2a27236',
    match_context: {
      match_id: 303707,
      season: '2019/2020',
      period: 1,
      minute: 18,
      second: 1
    },
    player_info: {
      player_id: 2948,
      player_name: 'Nabil Fekir',
      team_id: 218,
      team_name: 'Real Betis',
      position_name: 'Left Midfield'
    },
    pass_context: {
      recipient_id: 6673,
      recipient_name: 'Sergio Canales Madrazo',
      play_pattern_name: 'From Free Kick',
      duration: 0.802897
    },
    location: { x: 47.3, y: 73.7 }
  },
  {
    event_id: '2fb0df6f-3d46-433c-9aea-0512c80027e0',
    match_context: {
      match_id: 303707,
      season: '2019/2020',
      period: 1,
      minute: 24,
      second: 36
    },
    player_info: {
      player_id: 2948,
      player_name: 'Nabil Fekir',
      team_id: 218,
      team_name: 'Real Betis',
      position_name: 'Left Midfield'
    },
    pass_context: {
      recipient_id: 26404,
      recipient_name: 'Guido Rodríguez',
      play_pattern_name: 'From Free Kick',
      duration: 1.046214
    },
    location: { x: 75.4, y: 18.8 }
  },
  {
    event_id: 'ef14ec20-b423-400c-84e0-50ff12dcc649',
    match_context: {
      match_id: 303707,
      season: '2019/2020',
      period: 1,
      minute: 24,
      second: 45
    },
    player_info: {
      player_id: 2948,
      player_name: 'Nabil Fekir',
      team_id: 218,
      team_name: 'Real Betis',
      position_name: 'Left Midfield'
    },
    pass_context: {
      recipient_id: 13599,
      recipient_name: 'Carles Aleña Castillo',
      play_pattern_name: 'From Free Kick',
      duration: 0.886468
    },
    location: { x: 77.5, y: 48.3 }
  },
  {
    event_id: '430f0604-d10c-4329-9e98-2ca2be96949d',
    match_context: {
      match_id: 303707,
      season: '2019/2020',
      period: 1,
      minute: 25,
      second: 11
    },
    player_info: {
      player_id: 2948,
      player_name: 'Nabil Fekir',
      team_id: 218,
      team_name: 'Real Betis',
      position_name: 'Left Midfield'
    },
    pass_context: {
      recipient_id: 13599,
      recipient_name: 'Carles Aleña Castillo',
      play_pattern_name: 'From Throw In',
      duration: 0.479623
    },
    location: { x: 94.4, y: 62.6 }
  },
  {
    event_id: 'a7073dbb-9234-456d-b30b-1cf240e0494a',
    match_context: {
      match_id: 303707,
      season: '2019/2020',
      period: 1,
      minute: 39,
      second: 47
    },
    player_info: {
      player_id: 2948,
      player_name: 'Nabil Fekir',
      team_id: 218,
      team_name: 'Real Betis',
      position_name: 'Left Midfield'
    },
    pass_context: {
      recipient_id: 11538,
      recipient_name: 'Alejandro Moreno Lopera',
      play_pattern_name: 'From Throw In',
      duration: 1.650838
    },
    location: { x: 117.1, y: 3.8 }
  },
  {
    event_id: 'de09d35e-2493-4f73-afcf-87448d8ee305',
    match_context: {
      match_id: 303707,
      season: '2019/2020',
      period: 1,
      minute: 40,
      second: 28
    },
    player_info: {
      player_id: 2948,
      player_name: 'Nabil Fekir',
      team_id: 218,
      team_name: 'Real Betis',
      position_name: 'Left Midfield'
    },
    pass_context: {
      recipient_id: 11391,
      recipient_name: 'Borja Iglesias Quintas',
      play_pattern_name: 'Regular Play',
      duration: 1.54499
    },
    location: { x: 105.3, y: 20.9 }
  },
  {
    event_id: 'b6031500-a90d-415f-8ef8-734365767a55',
    match_context: {
      match_id: 303707,
      season: '2019/2020',
      period: 1,
      minute: 41,
      second: 23
    },
    player_info: {
      player_id: 2948,
      player_name: 'Nabil Fekir',
      team_id: 218,
      team_name: 'Real Betis',
      position_name: 'Left Midfield'
    },
    pass_context: {
      recipient_id: 13599,
      recipient_name: 'Carles Aleña Castillo',
      play_pattern_name: 'Regular Play',
      duration: 0.60823
    },
    location: { x: 77.1, y: 1.9 }
  },
  {
    event_id: 'e64300dd-d79d-4a2b-b2c4-1ed12de9c04d',
    match_context: {
      match_id: 303707,
      season: '2019/2020',
      period: 2,
      minute: 45,
      second: 19
    },
    player_info: {
      player_id: 2948,
      player_name: 'Nabil Fekir',
      team_id: 218,
      team_name: 'Real Betis',
      position_name: 'Left Midfield'
    },
    pass_context: {
      recipient_id: 6673,
      recipient_name: 'Sergio Canales Madrazo',
      play_pattern_name: 'From Kick Off',
      duration: 1.788192
    },
    location: { x: 56, y: 7.1 }
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

## Query 15: Teams with embedded disciplinary summaries

- Category: `Category 3: Nested / embedded documents`
- Exit code: `0`

### Output
```text
[
  {
    team_name: 'Barcelona',
    card_summary: { yellow_cards: 20, red_cards: 1, total_cards: 21 }
  },
  {
    team_name: 'Deportivo Alavés',
    card_summary: { yellow_cards: 2, red_cards: 0, total_cards: 2 }
  },
  {
    team_name: 'Eibar',
    card_summary: { yellow_cards: 2, red_cards: 0, total_cards: 2 }
  },
  {
    team_name: 'Espanyol',
    card_summary: { yellow_cards: 2, red_cards: 0, total_cards: 2 }
  },
  {
    team_name: 'Real Betis',
    card_summary: { yellow_cards: 1, red_cards: 1, total_cards: 2 }
  },
  {
    team_name: 'Celta Vigo',
    card_summary: { yellow_cards: 1, red_cards: 0, total_cards: 1 }
  },
  {
    team_name: 'Granada',
    card_summary: { yellow_cards: 1, red_cards: 0, total_cards: 1 }
  },
  {
    team_name: 'Leganés',
    card_summary: { yellow_cards: 1, red_cards: 0, total_cards: 1 }
  },
  {
    team_name: 'Osasuna',
    card_summary: { yellow_cards: 1, red_cards: 0, total_cards: 1 }
  },
  {
    team_name: 'Real Madrid',
    card_summary: { yellow_cards: 1, red_cards: 0, total_cards: 1 }
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
      { period: 2, shots: 19, fouls_committed: 15, cards: 0 },
      { period: 1, shots: 15, fouls_committed: 14, cards: 0 }
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
      { period: 1, shots: 15, fouls_committed: 11, cards: 0 },
      { period: 2, shots: 16, fouls_committed: 15, cards: 5 }
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
      { period: 1, shots: 13, fouls_committed: 6, cards: 0 },
      { period: 2, shots: 14, fouls_committed: 16, cards: 3 }
    ],
    total_shots: 27,
    match_id: 303634
  },
  {
    period_stats: [
      { period: 2, shots: 11, fouls_committed: 17, cards: 0 },
      { period: 1, shots: 15, fouls_committed: 13, cards: 0 }
    ],
    total_shots: 26,
    match_id: 303596
  }
]
```

## Query 19: Overview of indexes on the events collection

- Category: `Category 4: Indexes / performance`
- Exit code: `0`

### Output
```text
[
  { name: '_id_', key: { _id: 1 }, version: 2 },
  { name: 'event_id_hashed', key: { event_id: 'hashed' }, version: 2 },
  { name: 'ix_events_match_id', key: { match_id: 1 }, version: 2 },
  { name: 'ix_events_player_id', key: { player_id: 1 }, version: 2 },
  {
    name: 'ix_events_team_type',
    key: { team_id: 1, event_type_name: 1 },
    version: 2
  },
  {
    name: 'ix_events_season_minute',
    key: { season: 1, minute: 1 },
    version: 2
  }
]
```

## Query 20: Index usage statistics across shards

- Category: `Category 4: Indexes / performance`
- Exit code: `0`

### Output
```text
[
  {
    name: 'ix_events_player_id',
    key: { player_id: 1 },
    host: 'shard01a:27018',
    shard: 'shard01rs',
    access_ops: Long('13'),
    tracked_since: ISODate('2026-04-20T12:34:47.270Z')
  },
  {
    name: 'ix_events_player_id',
    key: { player_id: 1 },
    host: 'shard02c:27018',
    shard: 'shard02rs',
    access_ops: Long('13'),
    tracked_since: ISODate('2026-04-20T12:34:47.272Z')
  },
  {
    name: 'ix_events_player_id',
    key: { player_id: 1 },
    host: 'shard03c:27018',
    shard: 'shard03rs',
    access_ops: Long('13'),
    tracked_since: ISODate('2026-04-20T12:34:47.278Z')
  },
  {
    name: 'ix_events_match_id',
    key: { match_id: 1 },
    host: 'shard01a:27018',
    shard: 'shard01rs',
    access_ops: Long('6'),
    tracked_since: ISODate('2026-04-20T12:34:47.085Z')
  },
  {
    name: 'ix_events_match_id',
    key: { match_id: 1 },
    host: 'shard02c:27018',
    shard: 'shard02rs',
    access_ops: Long('6'),
    tracked_since: ISODate('2026-04-20T12:34:47.089Z')
  },
  {
    name: 'ix_events_match_id',
    key: { match_id: 1 },
    host: 'shard03c:27018',
    shard: 'shard03rs',
    access_ops: Long('6'),
    tracked_since: ISODate('2026-04-20T12:34:47.089Z')
  },
  {
    name: 'ix_events_team_type',
    key: { team_id: 1, event_type_name: 1 },
    host: 'shard01a:27018',
    shard: 'shard01rs',
    access_ops: Long('2'),
    tracked_since: ISODate('2026-04-20T12:34:47.463Z')
  },
  {
    name: 'ix_events_team_type',
    key: { team_id: 1, event_type_name: 1 },
    host: 'shard02c:27018',
    shard: 'shard02rs',
    access_ops: Long('2'),
    tracked_since: ISODate('2026-04-20T12:34:47.460Z')
  },
  {
    name: 'ix_events_team_type',
    key: { team_id: 1, event_type_name: 1 },
    host: 'shard03c:27018',
    shard: 'shard03rs',
    access_ops: Long('2'),
    tracked_since: ISODate('2026-04-20T12:34:47.466Z')
  },
  {
    name: '_id_',
    key: { _id: 1 },
    host: 'shard01a:27018',
    shard: 'shard01rs',
    access_ops: Long('0'),
    tracked_since: ISODate('2026-04-20T12:34:33.763Z')
  },
  {
    name: '_id_',
    key: { _id: 1 },
    host: 'shard02c:27018',
    shard: 'shard02rs',
    access_ops: Long('0'),
    tracked_since: ISODate('2026-04-20T12:34:33.920Z')
  },
  {
    name: '_id_',
    key: { _id: 1 },
    host: 'shard03c:27018',
    shard: 'shard03rs',
    access_ops: Long('0'),
    tracked_since: ISODate('2026-04-20T12:34:33.922Z')
  },
  {
    name: 'event_id_hashed',
    key: { event_id: 'hashed' },
    host: 'shard01a:27018',
    shard: 'shard01rs',
    access_ops: Long('0'),
    tracked_since: ISODate('2026-04-20T12:34:33.785Z')
  },
  {
    name: 'event_id_hashed',
    key: { event_id: 'hashed' },
    host: 'shard02c:27018',
    shard: 'shard02rs',
    access_ops: Long('0'),
    tracked_since: ISODate('2026-04-20T12:34:33.958Z')
  },
  {
    name: 'event_id_hashed',
    key: { event_id: 'hashed' },
    host: 'shard03c:27018',
    shard: 'shard03rs',
    access_ops: Long('0'),
    tracked_since: ISODate('2026-04-20T12:34:33.944Z')
  },
  {
    name: 'ix_events_season_minute',
    key: { season: 1, minute: 1 },
    host: 'shard01a:27018',
    shard: 'shard01rs',
    access_ops: Long('0'),
    tracked_since: ISODate('2026-04-20T12:34:47.672Z')
  },
  {
    name: 'ix_events_season_minute',
    key: { season: 1, minute: 1 },
    host: 'shard02c:27018',
    shard: 'shard02rs',
    access_ops: Long('0'),
    tracked_since: ISODate('2026-04-20T12:34:47.673Z')
  },
  {
    name: 'ix_events_season_minute',
    key: { season: 1, minute: 1 },
    host: 'shard03c:27018',
    shard: 'shard03rs',
    access_ops: Long('0'),
    tracked_since: ISODate('2026-04-20T12:34:47.674Z')
  }
]
```

## Query 21: Execution plan for filtering by match id

- Category: `Category 4: Indexes / performance`
- Exit code: `0`

### Output
```text
{
  winningPlan: {
    stage: 'SHARD_MERGE',
    shards: [
      {
        explainVersion: '1',
        shardName: 'shard02rs',
        connectionString: 'shard02rs/shard02a:27018,shard02b:27018,shard02c:27018',
        serverInfo: {
          host: 'shard02c',
          port: 27018,
          version: '8.0.20',
          gitVersion: '28927c60881a488fcbc5fd4d925b410f33258827'
        },
        namespace: 'statsbomb.events',
        parsedQuery: {
          match_id: {
            '$eq': 303451
          }
        },
        indexFilterSet: false,
        queryHash: '18F01999',
        planCacheShapeHash: '18F01999',
        planCacheKey: 'E34ACC34',
        optimizationTimeMillis: 0,
        maxIndexedOrSolutionsReached: false,
        maxIndexedAndSolutionsReached: false,
        maxScansToExplodeReached: false,
        prunedSimilarIndexes: false,
        winningPlan: {
          isCached: false,
          stage: 'SHARDING_FILTER',
          inputStage: {
            stage: 'FETCH',
            inputStage: {
              stage: 'IXSCAN',
              keyPattern: {
                match_id: 1
              },
              indexName: 'ix_events_match_id',
              isMultiKey: false,
              multiKeyPaths: {
                match_id: []
              },
              isUnique: false,
              isSparse: false,
              isPartial: false,
              indexVersion: 2,
              direction: 'forward',
              indexBounds: {
                match_id: [
                  '[303451, 303451]'
                ]
              }
            }
          }
        },
        rejectedPlans: []
      },
      {
        explainVersion: '1',
        shardName: 'shard01rs',
        connectionString: 'shard01rs/shard01a:27018,shard01b:27018,shard01c:27018',
        serverInfo: {
          host: 'shard01a',
          port: 27018,
          version: '8.0.20',
          gitVersion: '28927c60881a488fcbc5fd4d925b410f33258827'
        },
        namespace: 'statsbomb.events',
        parsedQuery: {
          match_id: {
            '$eq': 303451
          }
        },
        indexFilterSet: false,
        queryHash: '18F01999',
        planCacheShapeHash: '18F01999',
        planCacheKey: 'E34ACC34',
        optimizationTimeMillis: 0,
        maxIndexedOrSolutionsReached: false,
        maxIndexedAndSolutionsReached: false,
        maxScansToExplodeReached: false,
        prunedSimilarIndexes: false,
        winningPlan: {
          isCached: false,
          stage: 'SHARDING_FILTER',
          inputStage: {
            stage: 'FETCH',
            inputStage: {
              stage: 'IXSCAN',
              keyPattern: {
                match_id: 1
              },
              indexName: 'ix_events_match_id',
              isMultiKey: false,
              multiKeyPaths: {
                match_id: []
              },
              isUnique: false,
              isSparse: false,
              isPartial: false,
              indexVersion: 2,
              direction: 'forward',
              indexBounds: {
                match_id: [
                  '[303451, 303451]'
                ]
              }
            }
          }
        },
        rejectedPlans: []
      },
      {
        explainVersion: '1',
        shardName: 'shard03rs',
        connectionString: 'shard03rs/shard03a:27018,shard03b:27018,shard03c:27018',
        serverInfo: {
          host: 'shard03c',
          port: 27018,
          version: '8.0.20',
          gitVersion: '28927c60881a488fcbc5fd4d925b410f33258827'
        },
        namespace: 'statsbomb.events',
        parsedQuery: {
          match_id: {
            '$eq': 303451
          }
        },
        indexFilterSet: false,
        queryHash: '18F01999',
        planCacheShapeHash: '18F01999',
        planCacheKey: 'E34ACC34',
        optimizationTimeMillis: 0,
        maxIndexedOrSolutionsReached: false,
        maxIndexedAndSolutionsReached: false,
        maxScansToExplodeReached: false,
        prunedSimilarIndexes: false,
        winningPlan: {
          isCached: false,
          stage: 'SHARDING_FILTER',
          inputStage: {
            stage: 'FETCH',
            inputStage: {
              stage: 'IXSCAN',
              keyPattern: {
                match_id: 1
              },
              indexName: 'ix_events_match_id',
              isMultiKey: false,
              multiKeyPaths: {
                match_id: []
              },
              isUnique: false,
              isSparse: false,
              isPartial: false,
              indexVersion: 2,
              direction: 'forward',
              indexBounds: {
                match_id: [
                  '[303451, 303451]'
                ]
              }
            }
          }
        },
        rejectedPlans: []
      }
    ]
  },
  totalDocsExamined: 4068,
  totalKeysExamined: 4068,
  nReturned: 4068
}
```

## Query 22: Execution plan for the compound team and event-type index

- Category: `Category 4: Indexes / performance`
- Exit code: `0`

### Output
```text
{
  winningPlan: {
    stage: 'SHARD_MERGE',
    shards: [
      {
        explainVersion: '1',
        shardName: 'shard02rs',
        connectionString: 'shard02rs/shard02a:27018,shard02b:27018,shard02c:27018',
        serverInfo: {
          host: 'shard02c',
          port: 27018,
          version: '8.0.20',
          gitVersion: '28927c60881a488fcbc5fd4d925b410f33258827'
        },
        namespace: 'statsbomb.events',
        parsedQuery: {
          '$and': [
            {
              event_type_name: {
                '$eq': 'Pass'
              }
            },
            {
              team_id: {
                '$eq': 217
              }
            }
          ]
        },
        indexFilterSet: false,
        queryHash: '57BF4386',
        planCacheShapeHash: '57BF4386',
        planCacheKey: 'DAF189E5',
        optimizationTimeMillis: 0,
        maxIndexedOrSolutionsReached: false,
        maxIndexedAndSolutionsReached: false,
        maxScansToExplodeReached: false,
        prunedSimilarIndexes: false,
        winningPlan: {
          isCached: false,
          stage: 'SHARDING_FILTER',
          inputStage: {
            stage: 'FETCH',
            inputStage: {
              stage: 'IXSCAN',
              keyPattern: {
                team_id: 1,
                event_type_name: 1
              },
              indexName: 'ix_events_team_type',
              isMultiKey: false,
              multiKeyPaths: {
                team_id: [],
                event_type_name: []
              },
              isUnique: false,
              isSparse: false,
              isPartial: false,
              indexVersion: 2,
              direction: 'forward',
              indexBounds: {
                team_id: [
                  '[217, 217]'
                ],
                event_type_name: [
                  '["Pass", "Pass"]'
                ]
              }
            }
          }
        },
        rejectedPlans: []
      },
      {
        explainVersion: '1',
        shardName: 'shard03rs',
        connectionString: 'shard03rs/shard03a:27018,shard03b:27018,shard03c:27018',
        serverInfo: {
          host: 'shard03c',
          port: 27018,
          version: '8.0.20',
          gitVersion: '28927c60881a488fcbc5fd4d925b410f33258827'
        },
        namespace: 'statsbomb.events',
        parsedQuery: {
          '$and': [
            {
              event_type_name: {
                '$eq': 'Pass'
              }
            },
            {
              team_id: {
                '$eq': 217
              }
            }
          ]
        },
        indexFilterSet: false,
        queryHash: '57BF4386',
        planCacheShapeHash: '57BF4386',
        planCacheKey: 'DAF189E5',
        optimizationTimeMillis: 0,
        maxIndexedOrSolutionsReached: false,
        maxIndexedAndSolutionsReached: false,
        maxScansToExplodeReached: false,
        prunedSimilarIndexes: false,
        winningPlan: {
          isCached: false,
          stage: 'SHARDING_FILTER',
          inputStage: {
            stage: 'FETCH',
            inputStage: {
              stage: 'IXSCAN',
              keyPattern: {
                team_id: 1,
                event_type_name: 1
              },
              indexName: 'ix_events_team_type',
              isMultiKey: false,
              multiKeyPaths: {
                team_id: [],
                event_type_name: []
              },
              isUnique: false,
              isSparse: false,
              isPartial: false,
              indexVersion: 2,
              direction: 'forward',
              indexBounds: {
                team_id: [
                  '[217, 217]'
                ],
                event_type_name: [
                  '["Pass", "Pass"]'
                ]
              }
            }
          }
        },
        rejectedPlans: []
      },
      {
        explainVersion: '1',
        shardName: 'shard01rs',
        connectionString: 'shard01rs/shard01a:27018,shard01b:27018,shard01c:27018',
        serverInfo: {
          host: 'shard01a',
          port: 27018,
          version: '8.0.20',
          gitVersion: '28927c60881a488fcbc5fd4d925b410f33258827'
        },
        namespace: 'statsbomb.events',
        parsedQuery: {
          '$and': [
            {
              event_type_name: {
                '$eq': 'Pass'
              }
            },
            {
              team_id: {
                '$eq': 217
              }
            }
          ]
        },
        indexFilterSet: false,
        queryHash: '57BF4386',
        planCacheShapeHash: '57BF4386',
        planCacheKey: 'DAF189E5',
        optimizationTimeMillis: 0,
        maxIndexedOrSolutionsReached: false,
        maxIndexedAndSolutionsReached: false,
        maxScansToExplodeReached: false,
        prunedSimilarIndexes: false,
        winningPlan: {
          isCached: false,
          stage: 'SHARDING_FILTER',
          inputStage: {
            stage: 'FETCH',
            inputStage: {
              stage: 'IXSCAN',
              keyPattern: {
                team_id: 1,
                event_type_name: 1
              },
              indexName: 'ix_events_team_type',
              isMultiKey: false,
              multiKeyPaths: {
                team_id: [],
                event_type_name: []
              },
              isUnique: false,
              isSparse: false,
              isPartial: false,
              indexVersion: 2,
              direction: 'forward',
              indexBounds: {
                team_id: [
                  '[217, 217]'
                ],
                event_type_name: [
                  '["Pass", "Pass"]'
                ]
              }
            }
          }
        },
        rejectedPlans: []
      }
    ]
  },
  totalDocsExamined: 24618,
  totalKeysExamined: 24618,
  nReturned: 24618
}
```

## Query 23: Execution plan for season filtering with minute sorting

- Category: `Category 4: Indexes / performance`
- Exit code: `0`

### Output
```text
{
  winningPlan: {
    stage: 'SHARD_MERGE_SORT',
    shards: [
      {
        explainVersion: '1',
        shardName: 'shard02rs',
        connectionString: 'shard02rs/shard02a:27018,shard02b:27018,shard02c:27018',
        serverInfo: {
          host: 'shard02c',
          port: 27018,
          version: '8.0.20',
          gitVersion: '28927c60881a488fcbc5fd4d925b410f33258827'
        },
        namespace: 'statsbomb.events',
        parsedQuery: {
          '$and': [
            {
              season: {
                '$eq': '2019/2020'
              }
            },
            {
              minute: {
                '$gte': 75
              }
            }
          ]
        },
        indexFilterSet: false,
        queryHash: '71E7FA4B',
        planCacheShapeHash: '71E7FA4B',
        planCacheKey: '536F5C36',
        optimizationTimeMillis: 0,
        maxIndexedOrSolutionsReached: false,
        maxIndexedAndSolutionsReached: false,
        maxScansToExplodeReached: false,
        prunedSimilarIndexes: false,
        winningPlan: {
          isCached: false,
          stage: 'LIMIT',
          limitAmount: 20,
          inputStage: {
            stage: 'SHARDING_FILTER',
            inputStage: {
              stage: 'FETCH',
              inputStage: {
                stage: 'IXSCAN',
                keyPattern: {
                  season: 1,
                  minute: 1
                },
                indexName: 'ix_events_season_minute',
                isMultiKey: false,
                multiKeyPaths: {
                  season: [],
                  minute: []
                },
                isUnique: false,
                isSparse: false,
                isPartial: false,
                indexVersion: 2,
                direction: 'forward',
                indexBounds: {
                  season: [
                    '["2019/2020", "2019/2020"]'
                  ],
                  minute: [
                    '[75, inf.0]'
                  ]
                }
              }
            }
          }
        },
        rejectedPlans: []
      },
      {
        explainVersion: '1',
        shardName: 'shard01rs',
        connectionString: 'shard01rs/shard01a:27018,shard01b:27018,shard01c:27018',
        serverInfo: {
          host: 'shard01a',
          port: 27018,
          version: '8.0.20',
          gitVersion: '28927c60881a488fcbc5fd4d925b410f33258827'
        },
        namespace: 'statsbomb.events',
        parsedQuery: {
          '$and': [
            {
              season: {
                '$eq': '2019/2020'
              }
            },
            {
              minute: {
                '$gte': 75
              }
            }
          ]
        },
        indexFilterSet: false,
        queryHash: '71E7FA4B',
        planCacheShapeHash: '71E7FA4B',
        planCacheKey: '536F5C36',
        optimizationTimeMillis: 0,
        maxIndexedOrSolutionsReached: false,
        maxIndexedAndSolutionsReached: false,
        maxScansToExplodeReached: false,
        prunedSimilarIndexes: false,
        winningPlan: {
          isCached: false,
          stage: 'LIMIT',
          limitAmount: 20,
          inputStage: {
            stage: 'SHARDING_FILTER',
            inputStage: {
              stage: 'FETCH',
              inputStage: {
                stage: 'IXSCAN',
                keyPattern: {
                  season: 1,
                  minute: 1
                },
                indexName: 'ix_events_season_minute',
                isMultiKey: false,
                multiKeyPaths: {
                  season: [],
                  minute: []
                },
                isUnique: false,
                isSparse: false,
                isPartial: false,
                indexVersion: 2,
                direction: 'forward',
                indexBounds: {
                  season: [
                    '["2019/2020", "2019/2020"]'
                  ],
                  minute: [
                    '[75, inf.0]'
                  ]
                }
              }
            }
          }
        },
        rejectedPlans: []
      },
      {
        explainVersion: '1',
        shardName: 'shard03rs',
        connectionString: 'shard03rs/shard03a:27018,shard03b:27018,shard03c:27018',
        serverInfo: {
          host: 'shard03c',
          port: 27018,
          version: '8.0.20',
          gitVersion: '28927c60881a488fcbc5fd4d925b410f33258827'
        },
        namespace: 'statsbomb.events',
        parsedQuery: {
          '$and': [
            {
              season: {
                '$eq': '2019/2020'
              }
            },
            {
              minute: {
                '$gte': 75
              }
            }
          ]
        },
        indexFilterSet: false,
        queryHash: '71E7FA4B',
        planCacheShapeHash: '71E7FA4B',
        planCacheKey: '536F5C36',
        optimizationTimeMillis: 0,
        maxIndexedOrSolutionsReached: false,
        maxIndexedAndSolutionsReached: false,
        maxScansToExplodeReached: false,
        prunedSimilarIndexes: false,
        winningPlan: {
          isCached: false,
          stage: 'LIMIT',
          limitAmount: 20,
          inputStage: {
            stage: 'SHARDING_FILTER',
            inputStage: {
              stage: 'FETCH',
              inputStage: {
                stage: 'IXSCAN',
                keyPattern: {
                  season: 1,
                  minute: 1
                },
                indexName: 'ix_events_season_minute',
                isMultiKey: false,
                multiKeyPaths: {
                  season: [],
                  minute: []
                },
                isUnique: false,
                isSparse: false,
                isPartial: false,
                indexVersion: 2,
                direction: 'forward',
                indexBounds: {
                  season: [
                    '["2019/2020", "2019/2020"]'
                  ],
                  minute: [
                    '[75, inf.0]'
                  ]
                }
              }
            }
          }
        },
        rejectedPlans: []
      }
    ]
  },
  totalDocsExamined: 60,
  totalKeysExamined: 60,
  nReturned: 60
}
```

## Query 24: Execution plan for a non-indexed field

- Category: `Category 4: Indexes / performance`
- Exit code: `0`

### Output
```text
{
  winningPlan: {
    stage: 'SHARD_MERGE',
    shards: [
      {
        explainVersion: '1',
        shardName: 'shard02rs',
        connectionString: 'shard02rs/shard02a:27018,shard02b:27018,shard02c:27018',
        serverInfo: {
          host: 'shard02c',
          port: 27018,
          version: '8.0.20',
          gitVersion: '28927c60881a488fcbc5fd4d925b410f33258827'
        },
        namespace: 'statsbomb.events',
        parsedQuery: {
          team_name: {
            '$eq': 'Barcelona'
          }
        },
        indexFilterSet: false,
        queryHash: 'C9D5779B',
        planCacheShapeHash: 'C9D5779B',
        planCacheKey: '09D08647',
        optimizationTimeMillis: 0,
        maxIndexedOrSolutionsReached: false,
        maxIndexedAndSolutionsReached: false,
        maxScansToExplodeReached: false,
        prunedSimilarIndexes: false,
        winningPlan: {
          isCached: false,
          stage: 'SHARDING_FILTER',
          inputStage: {
            stage: 'COLLSCAN',
            filter: {
              team_name: {
                '$eq': 'Barcelona'
              }
            },
            direction: 'forward'
          }
        },
        rejectedPlans: []
      },
      {
        explainVersion: '1',
        shardName: 'shard03rs',
        connectionString: 'shard03rs/shard03a:27018,shard03b:27018,shard03c:27018',
        serverInfo: {
          host: 'shard03c',
          port: 27018,
          version: '8.0.20',
          gitVersion: '28927c60881a488fcbc5fd4d925b410f33258827'
        },
        namespace: 'statsbomb.events',
        parsedQuery: {
          team_name: {
            '$eq': 'Barcelona'
          }
        },
        indexFilterSet: false,
        queryHash: 'C9D5779B',
        planCacheShapeHash: 'C9D5779B',
        planCacheKey: '09D08647',
        optimizationTimeMillis: 0,
        maxIndexedOrSolutionsReached: false,
        maxIndexedAndSolutionsReached: false,
        maxScansToExplodeReached: false,
        prunedSimilarIndexes: false,
        winningPlan: {
          isCached: false,
          stage: 'SHARDING_FILTER',
          inputStage: {
            stage: 'COLLSCAN',
            filter: {
              team_name: {
                '$eq': 'Barcelona'
              }
            },
            direction: 'forward'
          }
        },
        rejectedPlans: []
      },
      {
        explainVersion: '1',
        shardName: 'shard01rs',
        connectionString: 'shard01rs/shard01a:27018,shard01b:27018,shard01c:27018',
        serverInfo: {
          host: 'shard01a',
          port: 27018,
          version: '8.0.20',
          gitVersion: '28927c60881a488fcbc5fd4d925b410f33258827'
        },
        namespace: 'statsbomb.events',
        parsedQuery: {
          team_name: {
            '$eq': 'Barcelona'
          }
        },
        indexFilterSet: false,
        queryHash: 'C9D5779B',
        planCacheShapeHash: 'C9D5779B',
        planCacheKey: '09D08647',
        optimizationTimeMillis: 0,
        maxIndexedOrSolutionsReached: false,
        maxIndexedAndSolutionsReached: false,
        maxScansToExplodeReached: false,
        prunedSimilarIndexes: false,
        winningPlan: {
          isCached: false,
          stage: 'SHARDING_FILTER',
          inputStage: {
            stage: 'COLLSCAN',
            filter: {
              team_name: {
                '$eq': 'Barcelona'
              }
            },
            direction: 'forward'
          }
        },
        rejectedPlans: []
      }
    ]
  },
  totalDocsExamined: 129058,
  totalKeysExamined: 0,
  nReturned: 80857
}
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

## Query 26: Sharded collection metadata with chunk counts and shard coverage

- Category: `Category 5: Cluster / sharding / admin`
- Exit code: `0`

### Output
```text
[
  {
    unique: false,
    namespace: 'statsbomb.events',
    shard_key: { event_id: 'hashed' },
    balancing_enabled: true,
    chunk_count: 3,
    shards_involved: 3,
    shard_names: [ 'shard01rs', 'shard02rs', 'shard03rs' ]
  }
]
```

## Query 27: Chunk balance deviation from the ideal equal distribution

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

## Query 28: Cluster operation history for collection lifecycle and sharding events

- Category: `Category 5: Cluster / sharding / admin`
- Exit code: `0`

### Output
```text
[
  {
    operations: 1,
    first_seen: ISODate('2026-04-20T12:34:34.119Z'),
    last_seen: ISODate('2026-04-20T12:34:34.119Z'),
    namespaces: [ 'statsbomb.events' ],
    operation: 'shardCollection.end',
    server: 'shard01a'
  },
  {
    operations: 1,
    first_seen: ISODate('2026-04-20T12:34:33.704Z'),
    last_seen: ISODate('2026-04-20T12:34:33.704Z'),
    namespaces: [ 'statsbomb.events' ],
    operation: 'shardCollection.start',
    server: 'shard01a'
  },
  {
    operations: 2,
    first_seen: ISODate('2026-04-20T12:34:32.865Z'),
    last_seen: ISODate('2026-04-20T12:34:33.651Z'),
    namespaces: [ 'statsbomb.events', 'statsbomb.players' ],
    operation: 'dropCollection',
    server: 'shard01a'
  },
  {
    operations: 2,
    first_seen: ISODate('2026-04-20T12:34:32.547Z'),
    last_seen: ISODate('2026-04-20T12:34:33.546Z'),
    namespaces: [ 'statsbomb.players', 'statsbomb.events' ],
    operation: 'dropCollection.start',
    server: 'shard01a'
  }
]
```

## Query 29: Replication lag and sync-source analysis inside `shard01rs`

- Category: `Category 5: Cluster / sharding / admin`
- Exit code: `0`

### Output
```text
[
  {
    name: 'shard01a:27018',
    state: 'PRIMARY',
    health: 1,
    sync_source: null,
    optimeDate: ISODate('2026-04-20T12:47:04.000Z'),
    replication_lag_seconds: 0
  },
  {
    name: 'shard01b:27018',
    state: 'SECONDARY',
    health: 1,
    sync_source: 'shard01a:27018',
    optimeDate: ISODate('2026-04-20T12:47:04.000Z'),
    replication_lag_seconds: 0
  },
  {
    name: 'shard01c:27018',
    state: 'SECONDARY',
    health: 1,
    sync_source: 'shard01a:27018',
    optimeDate: ISODate('2026-04-20T12:47:04.000Z'),
    replication_lag_seconds: 0
  }
]
```

## Query 30: Validation schema audit for all application collections

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

## Query 31: Administrative users expanded into a role matrix

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
