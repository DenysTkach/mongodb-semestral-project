# MongoDB Queries

 ## Category 1: Join / lookup

### Query 1: Players with the highest number of pass events
Task:
Find the players with the highest number of pass events and enrich the result with player metadata from the `players` collection.

Command:
```javascript
db.getSiblingDB("statsbomb").events.aggregate([
  { $match: { event_type_name: "Pass", player_id: { $ne: null } } },
  { $group: { _id: "$player_id", pass_count: { $sum: 1 } } },
  { $sort: { pass_count: -1, _id: 1 } },
  { $limit: 10 },
  {
    $lookup: {
      from: "players",
      localField: "_id",
      foreignField: "player_id",
      as: "player"
    }
  },
  { $unwind: "$player" },
  {
    $project: {
      _id: 0,
      player_id: "$_id",
      player_name: "$player.player_name",
      team_name: "$player.team_name",
      country: "$player.country",
      pass_count: 1
    }
  }
])
```

Comment:
In general, this aggregation filters all pass events, groups them by player, counts them, sorts the result, and then uses `$lookup` to attach descriptive data from another collection.
In this project, the query works over the La Liga 2019/2020 event data and shows which players appear most often as the passer. During validation on the current dataset, the top rows were dominated by Barcelona players such as Gerard Pique, Sergio Busquets, and Lionel Messi.

### Query 2: Most frequent passer-recipient combinations
Task:
Find the most frequent passing combinations and enrich both the passer and the recipient using the `players` collection.

Command:
```javascript
db.getSiblingDB("statsbomb").events.aggregate([
  {
    $match: {
      event_type_name: "Pass",
      player_id: { $ne: null },
      pass_recipient_id: { $ne: null }
    }
  },
  {
    $group: {
      _id: {
        passer_id: "$player_id",
        recipient_id: "$pass_recipient_id"
      },
      successful_passes: { $sum: 1 }
    }
  },
  { $sort: { successful_passes: -1, "_id.passer_id": 1, "_id.recipient_id": 1 } },
  { $limit: 10 },
  {
    $lookup: {
      from: "players",
      localField: "_id.passer_id",
      foreignField: "player_id",
      as: "passer"
    }
  },
  {
    $lookup: {
      from: "players",
      localField: "_id.recipient_id",
      foreignField: "player_id",
      as: "recipient"
    }
  },
  { $unwind: "$passer" },
  { $unwind: "$recipient" },
  {
    $project: {
      _id: 0,
      passer_name: "$passer.player_name",
      recipient_name: "$recipient.player_name",
      passer_team: "$passer.team_name",
      recipient_team: "$recipient.team_name",
      successful_passes: 1
    }
  }
])
```

Comment:
In general, this query groups pairs of related identifiers, ranks them by frequency, and then performs two joins so the raw ids become readable names.
In this project, it identifies the strongest passing links in the season. On the current data, combinations between Sergio Busquets, Sergi Roberto, Messi, Lenglet, and Pique appear at the top, which reflects Barcelona's heavy ball-possession structure in the selected matches.

### Query 3: Matches with the highest number of shots
Task:
Find the matches with the highest number of shot events and join them with the `matches` collection to obtain match metadata.

Command:
```javascript
db.getSiblingDB("statsbomb").events.aggregate([
  { $match: { event_type_name: "Shot" } },
  { $group: { _id: "$match_id", shot_count: { $sum: 1 } } },
  { $sort: { shot_count: -1, _id: 1 } },
  { $limit: 10 },
  {
    $lookup: {
      from: "matches",
      localField: "_id",
      foreignField: "match_id",
      as: "match"
    }
  },
  { $unwind: "$match" },
  {
    $project: {
      _id: 0,
      match_id: "$_id",
      match_date: "$match.match_date",
      home_team: "$match.home_team_name",
      away_team: "$match.away_team_name",
      shot_count: 1
    }
  }
])
```

Comment:
In general, the query aggregates event-level facts to match level and then joins a dimension-like collection to display the result in a readable business form.
In this project, it shows which La Liga matches in the selected dataset generated the most shot events. In the current data, one of the top rows is Barcelona vs Mallorca, which confirms that the join with `matches` makes the aggregated event counts understandable.

### Query 4: Home teams with the earliest average first shot
Task:
For every match, find the minute of the first shot, join the match metadata, and then compute which home teams tend to produce an early first shot on average.

Command:
```javascript
db.getSiblingDB("statsbomb").events.aggregate([
  { $match: { event_type_name: "Shot" } },
  { $group: { _id: "$match_id", first_shot_minute: { $min: "$minute" } } },
  {
    $lookup: {
      from: "matches",
      localField: "_id",
      foreignField: "match_id",
      as: "match"
    }
  },
  { $unwind: "$match" },
  {
    $group: {
      _id: "$match.home_team_name",
      avg_first_shot_minute: { $avg: "$first_shot_minute" },
      matches_count: { $sum: 1 }
    }
  },
  { $sort: { avg_first_shot_minute: 1, _id: 1 } },
  { $limit: 10 },
  {
    $project: {
      _id: 0,
      home_team_name: "$_id",
      avg_first_shot_minute: { $round: ["$avg_first_shot_minute", 2] },
      matches_count: 1
    }
  }
])
```

Comment:
In general, this pipeline performs a two-stage aggregation: first it computes a match-level metric, then after joining match metadata it rolls the result up to team level.
In this project, the metric is the earliest shot minute in a match. The query helps compare how quickly home teams become offensively active. Because the dataset is limited to one season and one selected set of matches, some teams appear with only one home match in the result, which should be mentioned in the interpretation.

### Query 5: Card events by team and venue
Task:
Join card-related events with `matches`, determine whether the team played at home or away, and then count card events by team, venue, and card type.

Command:
```javascript
db.getSiblingDB("statsbomb").events.aggregate([
  {
    $match: {
      card_name: { $ne: null },
      team_id: { $ne: null },
      match_id: { $ne: null }
    }
  },
  {
    $lookup: {
      from: "matches",
      localField: "match_id",
      foreignField: "match_id",
      as: "match"
    }
  },
  { $unwind: "$match" },
  {
    $project: {
      team_name: 1,
      card_name: 1,
      venue: {
        $cond: [
          { $eq: ["$team_id", "$match.home_team_id"] },
          "home",
          "away"
        ]
      }
    }
  },
  {
    $group: {
      _id: {
        team_name: "$team_name",
        venue: "$venue",
        card_name: "$card_name"
      },
      card_events: { $sum: 1 }
    }
  },
  { $sort: { card_events: -1, "_id.team_name": 1 } },
  { $limit: 10 },
  {
    $project: {
      _id: 0,
      team_name: "$_id.team_name",
      venue: "$_id.venue",
      card_name: "$_id.card_name",
      card_events: 1
    }
  }
])
```

Comment:
In general, this query enriches fact records with contextual data from another collection and uses a derived field computed with `$cond` before aggregation.
In this project, the join with `matches` makes it possible to classify each card event as home or away. On the current dataset, Barcelona home yellow cards are among the most frequent rows returned by the query.

### Query 6: Referees with the highest average number of fouls per match
Task:
Count foul committed events per match, join the match record, and then compute the average number of fouls for each referee.

Command:
```javascript
db.getSiblingDB("statsbomb").events.aggregate([
  {
    $match: {
      event_type_name: "Foul Committed",
      match_id: { $ne: null }
    }
  },
  { $group: { _id: "$match_id", foul_count: { $sum: 1 } } },
  {
    $lookup: {
      from: "matches",
      localField: "_id",
      foreignField: "match_id",
      as: "match"
    }
  },
  { $unwind: "$match" },
  {
    $group: {
      _id: "$match.referee_name",
      avg_fouls_per_match: { $avg: "$foul_count" },
      matches_officiated: { $sum: 1 }
    }
  },
  { $match: { _id: { $ne: null } } },
  { $sort: { avg_fouls_per_match: -1, _id: 1 } },
  { $limit: 10 },
  {
    $project: {
      _id: 0,
      referee_name: "$_id",
      avg_fouls_per_match: { $round: ["$avg_fouls_per_match", 2] },
      matches_officiated: 1
    }
  }
])
```

Comment:
In general, this is another two-level analytical join: first a match-level metric is computed from the fact table, then the dimension table is used to attribute that metric to referees.
In this project, the query shows which referees are associated with the highest average foul counts in the selected matches. Some match records contain `null` referee values, so the pipeline explicitly removes them before the final ranking.

## Category 2: Aggregation / statistics

### Query 7: Teams with the highest number of shot events
Task:
Count shot events for each team and rank the teams by total shot volume.

Command:
```javascript
db.getSiblingDB("statsbomb").events.aggregate([
  { $match: { event_type_name: "Shot", team_name: { $ne: null } } },
  {
    $group: {
      _id: "$team_name",
      shot_count: { $sum: 1 },
      avg_shot_minute: { $avg: "$minute" }
    }
  },
  { $sort: { shot_count: -1, _id: 1 } },
  { $limit: 10 },
  {
    $project: {
      _id: 0,
      team_name: "$_id",
      shot_count: 1,
      avg_shot_minute: { $round: ["$avg_shot_minute", 2] }
    }
  }
])
```

Comment:
In general, this aggregation filters a specific event type, groups rows by team, computes both a count and an average, and then ranks the result.
In this project, the query shows which teams generated the highest shot volume in the selected La Liga matches. During validation, Barcelona was far above the rest of the dataset, which is expected because the project data is centered around Barcelona matches.

### Query 8: Players with the longest average carry duration
Task:
Find the players with the highest average carry duration, but only among players with at least 30 carry events.

Command:
```javascript
db.getSiblingDB("statsbomb").events.aggregate([
  {
    $match: {
      event_type_name: "Carry",
      duration: { $ne: null },
      player_id: { $ne: null }
    }
  },
  {
    $group: {
      _id: {
        player_id: "$player_id",
        player_name: "$player_name",
        team_name: "$team_name"
      },
      carries: { $sum: 1 },
      avg_duration: { $avg: "$duration" }
    }
  },
  { $match: { carries: { $gte: 30 } } },
  { $sort: { avg_duration: -1, carries: -1, "_id.player_name": 1 } },
  { $limit: 10 },
  {
    $project: {
      _id: 0,
      player_id: "$_id.player_id",
      player_name: "$_id.player_name",
      team_name: "$_id.team_name",
      carries: 1,
      avg_duration: { $round: ["$avg_duration", 3] }
    }
  }
])
```

Comment:
In general, this pipeline measures an average metric per player and uses an additional threshold filter so that very small samples do not distort the ranking.
In this project, the query highlights which players tend to carry the ball for the longest time. The threshold of 30 carry events removes one-off outliers and keeps the result analytically meaningful.

### Query 9: Matches with the highest number of possession sequences
Task:
For each match, count how many distinct possession ids appear and rank the matches by that number.

Command:
```javascript
db.getSiblingDB("statsbomb").events.aggregate([
  {
    $match: {
      possession: { $ne: null },
      match_id: { $ne: null }
    }
  },
  {
    $group: {
      _id: {
        match_id: "$match_id",
        possession: "$possession"
      },
      teams_in_possession: { $addToSet: "$possession_team_name" }
    }
  },
  {
    $group: {
      _id: "$_id.match_id",
      possession_sequences: { $sum: 1 },
      teams_involved: { $push: "$teams_in_possession" }
    }
  },
  { $sort: { possession_sequences: -1, _id: 1 } },
  { $limit: 10 },
  {
    $project: {
      _id: 0,
      match_id: "$_id",
      possession_sequences: 1,
      distinct_teams_involved: { $size: { $setUnion: "$teams_involved" } }
    }
  }
])
```

Comment:
In general, this is a two-level aggregation: first it identifies unique possession sequences within a match, then it rolls those intermediate results up to the match level.
In this project, the query serves as a simple tempo indicator. On the current data, the top matches contain around two hundred possession sequences, which suggests a very fragmented game flow with many changes of control.

### Query 10: Distribution of shot outcomes
Task:
Summarize all non-null shot outcomes and compute their percentage share of total shots.

Command:
```javascript
db.getSiblingDB("statsbomb").events.aggregate([
  {
    $match: {
      event_type_name: "Shot",
      shot_outcome_name: { $ne: null }
    }
  },
  { $group: { _id: "$shot_outcome_name", shots: { $sum: 1 } } },
  {
    $group: {
      _id: null,
      total_shots: { $sum: "$shots" },
      outcomes: {
        $push: {
          shot_outcome_name: "$_id",
          shots: "$shots"
        }
      }
    }
  },
  { $unwind: "$outcomes" },
  {
    $project: {
      _id: 0,
      shot_outcome_name: "$outcomes.shot_outcome_name",
      shots: "$outcomes.shots",
      share_pct: {
        $round: [
          {
            $multiply: [
              { $divide: ["$outcomes.shots", "$total_shots"] },
              100
            ]
          },
          2
        ]
      }
    }
  },
  { $sort: { shots: -1, shot_outcome_name: 1 } }
])
```

Comment:
In general, this aggregation first computes counts for each outcome, then computes the global denominator, and finally derives percentage shares for each category.
In this project, the largest shot outcome groups were `Off T`, `Saved`, and `Blocked`, while goals formed a smaller subset. This makes the attacking profile of the selected matches easy to interpret without exporting the data elsewhere.

### Query 11: Teams with the best shot conversion rate
Task:
For teams with at least 10 shots, calculate how many of those shots became goals and rank the teams by conversion rate.

Command:
```javascript
db.getSiblingDB("statsbomb").events.aggregate([
  { $match: { event_type_name: "Shot", team_name: { $ne: null } } },
  {
    $group: {
      _id: "$team_name",
      total_shots: { $sum: 1 },
      goals_scored: {
        $sum: {
          $cond: [
            { $eq: ["$shot_outcome_name", "Goal"] },
            1,
            0
          ]
        }
      }
    }
  },
  { $match: { total_shots: { $gte: 10 } } },
  {
    $project: {
      _id: 0,
      team_name: "$_id",
      total_shots: 1,
      goals_scored: 1,
      conversion_rate_pct: {
        $round: [
          {
            $multiply: [
              { $divide: ["$goals_scored", "$total_shots"] },
              100
            ]
          },
          2
        ]
      }
    }
  },
  { $sort: { conversion_rate_pct: -1, goals_scored: -1, team_name: 1 } },
  { $limit: 10 }
])
```

Comment:
In general, this query demonstrates conditional aggregation: the total number of shots is counted for every team, and goals are counted only when a row satisfies a condition.
In this project, the query reveals which teams were the most clinically efficient in the selected sample. Smaller teams can rank highly here even with fewer total shots, so the minimum threshold helps keep the comparison fairer.

### Query 12: Goal events by 15-minute interval
Task:
Place goal events into 15-minute bands and count how many goals fall into each interval.

Command:
```javascript
db.getSiblingDB("statsbomb").events.aggregate([
  {
    $match: {
      $or: [
        { shot_outcome_name: "Goal" },
        { event_type_name: "Own Goal For" }
      ]
    }
  },
  {
    $addFields: {
      minute_band: {
        $switch: {
          branches: [
            { case: { $lt: ["$minute", 15] }, then: "00-14" },
            { case: { $lt: ["$minute", 30] }, then: "15-29" },
            { case: { $lt: ["$minute", 45] }, then: "30-44" },
            { case: { $lt: ["$minute", 60] }, then: "45-59" },
            { case: { $lt: ["$minute", 75] }, then: "60-74" },
            { case: { $lt: ["$minute", 90] }, then: "75-89" }
          ],
          default: "90+"
        }
      }
    }
  },
  { $group: { _id: "$minute_band", goals: { $sum: 1 } } },
  { $sort: { _id: 1 } },
  {
    $project: {
      _id: 0,
      minute_band: "$_id",
      goals: 1
    }
  }
])
```

Comment:
In general, this query derives a new categorical field from a numeric one and then aggregates by the derived buckets.
In this project, the query makes it easy to see when goals are concentrated across the selected matches. During validation, the `30-44` interval was the strongest band, while stoppage time contained the fewest goals.

## Category 3: Nested / embedded documents

### Query 13: Match passing leaders as embedded team documents
Task:
For each match and team, identify the most active passers, enrich them with player metadata, and build an embedded `top_passers` array inside a compact match-team document.

Command:
```javascript
db.getSiblingDB("statsbomb").events.aggregate([
  {
    $match: {
      event_type_name: "Pass",
      match_id: { $ne: null },
      team_id: { $ne: null },
      player_id: { $ne: null }
    }
  },
  {
    $group: {
      _id: {
        match_id: "$match_id",
        team_id: "$team_id",
        team_name: "$team_name",
        player_id: "$player_id"
      },
      pass_count: { $sum: 1 },
      avg_pass_minute: { $avg: "$minute" },
      distinct_recipients: { $addToSet: "$pass_recipient_id" }
    }
  },
  {
    $lookup: {
      from: "players",
      localField: "_id.player_id",
      foreignField: "player_id",
      as: "player"
    }
  },
  { $unwind: "$player" },
  { $sort: { "_id.match_id": 1, "_id.team_name": 1, pass_count: -1, "_id.player_id": 1 } },
  {
    $group: {
      _id: {
        match_id: "$_id.match_id",
        team_id: "$_id.team_id",
        team_name: "$_id.team_name"
      },
      top_passers: {
        $push: {
          player_id: "$_id.player_id",
          player_name: "$player.player_name",
          country: "$player.country",
          position: "$player.position",
          pass_count: "$pass_count",
          avg_pass_minute: { $round: ["$avg_pass_minute", 2] },
          distinct_recipient_count: {
            $size: {
              $filter: {
                input: "$distinct_recipients",
                as: "recipient",
                cond: { $ne: ["$$recipient", null] }
              }
            }
          }
        }
      },
      total_team_passes: { $sum: "$pass_count" }
    }
  },
  {
    $lookup: {
      from: "matches",
      localField: "_id.match_id",
      foreignField: "match_id",
      as: "match"
    }
  },
  { $unwind: "$match" },
  {
    $project: {
      _id: 0,
      match_id: "$_id.match_id",
      match_summary: {
        match_date: "$match.match_date",
        home_team: "$match.home_team_name",
        away_team: "$match.away_team_name"
      },
      team: {
        team_id: "$_id.team_id",
        team_name: "$_id.team_name",
        total_team_passes: "$total_team_passes",
        top_passers: { $slice: ["$top_passers", 5] }
      }
    }
  },
  { $sort: { match_id: 1, "team.team_name": 1 } },
  { $limit: 10 }
])
```

Comment:
In general, this query combines analytical aggregation with document-oriented output construction. It first computes player-level passing metrics, then enriches them with a join to `players`, and finally regroups the result into embedded `top_passers` arrays per match and team.
In this project, the pipeline produces match-level team documents that are much closer to how a document database is often consumed by applications. It is stronger than a simple reshape because it mixes `$group`, `$lookup`, multi-level aggregation, derived metrics, and nested arrays in one result.

### Query 14: Shot events with embedded shot profile
Task:
For shot events, create a nested `shot_profile` subdocument that contains derived flags such as whether the shot was a goal, whether it was on target, and in which minute band it occurred.

Command:
```javascript
db.getSiblingDB("statsbomb").events.aggregate([
  {
    $match: {
      event_type_name: "Shot",
      player_id: { $ne: null },
      location_x: { $ne: null },
      location_y: { $ne: null }
    }
  },
  {
    $set: {
      is_goal: { $eq: ["$shot_outcome_name", "Goal"] },
      is_on_target: {
        $in: [
          "$shot_outcome_name",
          ["Goal", "Saved", "Saved to Post"]
        ]
      },
      minute_band: {
        $switch: {
          branches: [
            { case: { $lt: ["$minute", 15] }, then: "00-14" },
            { case: { $lt: ["$minute", 30] }, then: "15-29" },
            { case: { $lt: ["$minute", 45] }, then: "30-44" },
            { case: { $lt: ["$minute", 60] }, then: "45-59" },
            { case: { $lt: ["$minute", 75] }, then: "60-74" },
            { case: { $lt: ["$minute", 90] }, then: "75-89" }
          ],
          default: "90+"
        }
      }
    }
  },
  {
    $project: {
      _id: 0,
      event_id: 1,
      team_name: 1,
      player_name: 1,
      shot_profile: {
        outcome: "$shot_outcome_name",
        is_goal: "$is_goal",
        is_on_target: "$is_on_target",
        minute_band: "$minute_band",
        location: {
          x: "$location_x",
          y: "$location_y"
        }
      }
    }
  },
  { $limit: 10 }
])
```

Comment:
In general, this pipeline uses `$set` to derive new analytical fields and then embeds them into a compact nested subdocument.
In this project, the query produces a reusable shot-oriented structure that is easier to inspect than the raw flat event rows. It also demonstrates conditional document enrichment directly inside MongoDB.

### Query 15: Teams with embedded disciplinary profiles by venue and card type
Task:
Join card-related events with match metadata, classify them as home or away, and build a nested disciplinary profile for each team that contains both overall totals and an embedded venue breakdown.

Command:
```javascript
db.getSiblingDB("statsbomb").events.aggregate([
  {
    $match: {
      card_name: { $ne: null },
      team_id: { $ne: null },
      match_id: { $ne: null }
    }
  },
  {
    $lookup: {
      from: "matches",
      localField: "match_id",
      foreignField: "match_id",
      as: "match"
    }
  },
  { $unwind: "$match" },
  {
    $project: {
      team_id: 1,
      team_name: 1,
      card_name: 1,
      venue: {
        $cond: [
          { $eq: ["$team_id", "$match.home_team_id"] },
          "home",
          "away"
        ]
      }
    }
  },
  {
    $group: {
      _id: {
        team_id: "$team_id",
        team_name: "$team_name",
        venue: "$venue",
        card_name: "$card_name"
      },
      card_events: { $sum: 1 }
    }
  },
  { $sort: { "_id.team_name": 1, "_id.venue": 1, card_events: -1, "_id.card_name": 1 } },
  {
    $group: {
      _id: {
        team_id: "$_id.team_id",
        team_name: "$_id.team_name",
        venue: "$_id.venue"
      },
      total_cards_at_venue: { $sum: "$card_events" },
      card_breakdown: {
        $push: {
          card_name: "$_id.card_name",
          card_events: "$card_events"
        }
      },
      yellow_cards_at_venue: {
        $sum: {
          $cond: [{ $eq: ["$_id.card_name", "Yellow Card"] }, "$card_events", 0]
        }
      },
      red_cards_at_venue: {
        $sum: {
          $cond: [
            { $in: ["$_id.card_name", ["Red Card", "Second Yellow"]] },
            "$card_events",
            0
          ]
        }
      }
    }
  },
  { $sort: { "_id.team_name": 1, total_cards_at_venue: -1, "_id.venue": 1 } },
  {
    $group: {
      _id: {
        team_id: "$_id.team_id",
        team_name: "$_id.team_name"
      },
      venue_profiles: {
        $push: {
          venue: "$_id.venue",
          total_cards: "$total_cards_at_venue",
          yellow_cards: "$yellow_cards_at_venue",
          red_cards: "$red_cards_at_venue",
          card_breakdown: "$card_breakdown"
        }
      },
      total_cards: { $sum: "$total_cards_at_venue" },
      yellow_cards: { $sum: "$yellow_cards_at_venue" },
      red_cards: { $sum: "$red_cards_at_venue" }
    }
  },
  { $sort: { total_cards: -1, "_id.team_name": 1 } },
  { $limit: 10 },
  {
    $project: {
      _id: 0,
      team: {
        team_id: "$_id.team_id",
        team_name: "$_id.team_name"
      },
      disciplinary_profile: {
        total_cards: "$total_cards",
        yellow_cards: "$yellow_cards",
        red_cards: "$red_cards",
        venue_profiles: "$venue_profiles"
      }
    }
  }
])
```

Comment:
In general, this query is a much richer embedded-document example than a simple per-team summary. It enriches event data with match context, derives a venue attribute, aggregates twice, and then produces a nested `disciplinary_profile` with embedded `venue_profiles` and card-type arrays.
In this project, the result gives a compact but analytically useful disciplinary document per team. It is stronger because it shows nested document construction after a real multi-stage aggregation workflow rather than only projecting a few counters into one subdocument.

### Query 16: Player activity profiles as embedded documents
Task:
Build an embedded activity profile for each player that summarizes passes, shots, carries, fouls committed, and pressures.

Command:
```javascript
db.getSiblingDB("statsbomb").events.aggregate([
  {
    $match: {
      player_id: { $ne: null },
      event_type_name: {
        $in: ["Pass", "Shot", "Carry", "Foul Committed", "Pressure"]
      }
    }
  },
  {
    $group: {
      _id: {
        player_id: "$player_id",
        player_name: "$player_name",
        team_name: "$team_name"
      },
      passes: {
        $sum: { $cond: [{ $eq: ["$event_type_name", "Pass"] }, 1, 0] }
      },
      shots: {
        $sum: { $cond: [{ $eq: ["$event_type_name", "Shot"] }, 1, 0] }
      },
      carries: {
        $sum: { $cond: [{ $eq: ["$event_type_name", "Carry"] }, 1, 0] }
      },
      fouls_committed: {
        $sum: {
          $cond: [{ $eq: ["$event_type_name", "Foul Committed"] }, 1, 0]
        }
      },
      pressures: {
        $sum: { $cond: [{ $eq: ["$event_type_name", "Pressure"] }, 1, 0] }
      }
    }
  },
  { $sort: { passes: -1, carries: -1, shots: -1, "_id.player_name": 1 } },
  { $limit: 10 },
  {
    $project: {
      _id: 0,
      player: {
        player_id: "$_id.player_id",
        player_name: "$_id.player_name",
        team_name: "$_id.team_name"
      },
      activity_profile: {
        passes: "$passes",
        shots: "$shots",
        carries: "$carries",
        fouls_committed: "$fouls_committed",
        pressures: "$pressures"
      }
    }
  }
])
```

Comment:
In general, this is an example of building a rich embedded profile from several conditional counters collected in one grouping stage.
In this project, the query shows how a flat event log can be turned into player-centric documents. The top results are dominated by Barcelona players because they appear most heavily in the selected season sample.

### Query 17: Match documents normalized into embedded match summaries
Task:
Transform match records into nested summaries that group match metadata, both teams, venue information, and referee information, while replacing missing referee values with a readable default.

Command:
```javascript
db.getSiblingDB("statsbomb").matches.aggregate([
  {
    $project: {
      _id: 0,
      match_id: 1,
      match_summary: {
        date: "$match_date",
        kick_off: "$kick_off",
        season: "$season",
        competition: "$competition_name",
        stage: "$competition_stage_name"
      },
      teams: {
        home: {
          team_id: "$home_team_id",
          team_name: "$home_team_name",
          score: "$home_score"
        },
        away: {
          team_id: "$away_team_id",
          team_name: "$away_team_name",
          score: "$away_score"
        }
      },
      venue: {
        stadium_id: "$stadium_id",
        stadium_name: "$stadium_name"
      },
      officiating: {
        referee_id: "$referee_id",
        referee_name: { $ifNull: ["$referee_name", "Unknown referee"] }
      }
    }
  },
  { $sort: { match_id: 1 } },
  { $limit: 10 }
])
```

Comment:
In general, this query demonstrates document normalization for presentation: related fields are grouped into embedded blocks and null values are handled with `$ifNull`.
In this project, many match records contain a missing referee, so replacing it with `Unknown referee` makes the output much easier to read and more suitable for downstream presentation.

### Query 18: Matches with embedded period statistics arrays
Task:
For each match, build an array of embedded per-period statistic documents containing shots, fouls committed, and cards.

Command:
```javascript
db.getSiblingDB("statsbomb").events.aggregate([
  {
    $match: {
      match_id: { $ne: null },
      period: { $in: [1, 2] }
    }
  },
  {
    $group: {
      _id: {
        match_id: "$match_id",
        period: "$period"
      },
      shots: {
        $sum: { $cond: [{ $eq: ["$event_type_name", "Shot"] }, 1, 0] }
      },
      fouls_committed: {
        $sum: {
          $cond: [{ $eq: ["$event_type_name", "Foul Committed"] }, 1, 0]
        }
      },
      cards: {
        $sum: { $cond: [{ $ne: ["$card_name", null] }, 1, 0] }
      }
    }
  },
  {
    $group: {
      _id: "$_id.match_id",
      period_stats: {
        $push: {
          period: "$_id.period",
          shots: "$shots",
          fouls_committed: "$fouls_committed",
          cards: "$cards"
        }
      },
      total_shots: { $sum: "$shots" }
    }
  },
  { $sort: { total_shots: -1, _id: 1 } },
  { $limit: 10 },
  {
    $project: {
      _id: 0,
      match_id: "$_id",
      total_shots: 1,
      period_stats: 1
    }
  }
])
```

Comment:
In general, this pipeline first computes period-level statistics and then embeds those results into an array of subdocuments per match.
In this project, the query clearly shows how match flow differs between the first and second half. It is also a strong example of using MongoDB to construct embedded arrays for analytical reporting.

## Category 4: Indexes / performance

### Query 19: Consolidated index catalog with usage totals across all shards
Task:
Merge `$indexStats` output across the whole sharded cluster and rank indexes by total access count, while also showing how many shards reported usage data for each index.

Command:
```javascript
db.getSiblingDB("statsbomb").events.aggregate([
  { $indexStats: {} },
  {
    $group: {
      _id: {
        name: "$name",
        key: "$key"
      },
      total_access_ops: { $sum: "$accesses.ops" },
      shards_reporting: { $addToSet: "$shard" },
      hosts: { $addToSet: "$host" },
      first_tracked: { $min: "$accesses.since" }
    }
  },
  {
    $project: {
      _id: 0,
      index_name: "$_id.name",
      key: "$_id.key",
      total_access_ops: 1,
      shards_reporting: 1,
      shard_count: { $size: "$shards_reporting" },
      host_count: { $size: "$hosts" },
      first_tracked: 1
    }
  },
  { $sort: { total_access_ops: -1, index_name: 1 } }
])
```

Comment:
In general, this query goes beyond a raw `getIndexes()` listing because it joins logical index definitions with actual runtime usage statistics. It uses `$group` to consolidate per-shard counters into one cluster-wide view.
In this project, the result shows which analytical indexes are really being exercised by the queries. During validation, the `ix_events_player_id`, `ix_events_match_id`, and `ix_events_team_type` indexes had non-zero counters, while some others were still unused since tracking started.

### Query 20: Unused indexes since statistics tracking started
Task:
Identify indexes on the `events` collection that have recorded zero accesses across all shards since MongoDB started tracking index usage.

Command:
```javascript
db.getSiblingDB("statsbomb").events.aggregate([
  { $indexStats: {} },
  {
    $group: {
      _id: {
        name: "$name",
        key: "$key"
      },
      total_access_ops: { $sum: "$accesses.ops" },
      shards_reporting: { $addToSet: "$shard" },
      first_tracked: { $min: "$accesses.since" }
    }
  },
  {
    $project: {
      _id: 0,
      index_name: "$_id.name",
      key: "$_id.key",
      total_access_ops: 1,
      shard_count: { $size: "$shards_reporting" },
      is_unused_since_tracking_started: {
        $eq: ["$total_access_ops", NumberLong("0")]
      },
      first_tracked: 1
    }
  },
  { $match: { is_unused_since_tracking_started: true } },
  { $sort: { index_name: 1 } }
])
```

Comment:
In general, this query is a performance audit for index maintenance overhead. It uses usage statistics to find indexes that currently consume storage and write-maintenance cost without contributing to read performance.
In this project, the query helps justify whether every created index is still necessary. On the current validation run, indexes such as `_id_`, `event_id_hashed`, and sometimes `ix_events_season_minute` can appear as unused simply because no matching workload has been executed since the counters started.

### Query 21: Comparative benchmark of the main analytical indexes
Task:
Run `explain("executionStats")` for several representative analytical workloads and compare which index each workload uses and how much work MongoDB performs per returned document.

Command:
```javascript
function summarize(label, cursorFactory) {
  const exp = cursorFactory().explain("executionStats");

  function findLeaf(node) {
    if (!node || typeof node !== "object") return null;
    if (node.stage === "IXSCAN" || node.stage === "COLLSCAN") return node;

    if (Array.isArray(node.shards)) {
      for (const shard of node.shards) {
        const found = findLeaf(shard.winningPlan || shard);
        if (found) return found;
      }
    }

    for (const key of ["inputStage", "inputStages", "queryPlan", "winningPlan"]) {
      const val = node[key];
      if (Array.isArray(val)) {
        for (const item of val) {
          const found = findLeaf(item);
          if (found) return found;
        }
      } else if (val) {
        const found = findLeaf(val);
        if (found) return found;
      }
    }

    return null;
  }

  const leaf = findLeaf(exp.queryPlanner.winningPlan);

  return {
    scenario: label,
    leaf_stage: leaf ? leaf.stage : null,
    index_name: leaf && leaf.indexName ? leaf.indexName : null,
    totalDocsExamined: exp.executionStats.totalDocsExamined,
    totalKeysExamined: exp.executionStats.totalKeysExamined,
    nReturned: exp.executionStats.nReturned,
    keys_per_returned: exp.executionStats.nReturned
      ? Number((exp.executionStats.totalKeysExamined / exp.executionStats.nReturned).toFixed(3))
      : null,
    docs_per_returned: exp.executionStats.nReturned
      ? Number((exp.executionStats.totalDocsExamined / exp.executionStats.nReturned).toFixed(3))
      : null
  };
}

[
  summarize(
    "match_id exact filter",
    () => db.getSiblingDB("statsbomb").events.find({ match_id: 303451 })
  ),
  summarize(
    "player_id exact filter",
    () => db.getSiblingDB("statsbomb").events.find({ player_id: 5503 })
  ),
  summarize(
    "team_id + event_type_name",
    () => db.getSiblingDB("statsbomb").events.find({ team_id: 217, event_type_name: "Pass" })
  ),
  summarize(
    "season + minute with sort",
    () => db.getSiblingDB("statsbomb").events.find({ season: "2019/2020", minute: { $gte: 75 } }).sort({ minute: 1 }).limit(20)
  )
]
```

Comment:
In general, this command turns multiple `explain` plans into one comparative benchmark table. Instead of looking at one query in isolation, it compares several realistic workloads and derives normalized metrics such as `keys_per_returned` and `docs_per_returned`.
In this project, all four representative scenarios used their intended indexes and achieved a near `1:1` ratio between examined keys, examined documents, and returned documents. That is a strong sign that the chosen index design matches the actual analytical workload.

### Query 22: Prefix behavior of the compound `team_id + event_type_name` index
Task:
Compare how the compound index `ix_events_team_type` behaves for a left-prefix query, a full compound query, and a query that ignores the leftmost indexed field.

Command:
```javascript
function summarize(label, query) {
  const exp = db.getSiblingDB("statsbomb")
    .events
    .find(query)
    .limit(20)
    .explain("executionStats");

  function findLeaf(node) {
    if (!node || typeof node !== "object") return null;
    if (node.stage === "IXSCAN" || node.stage === "COLLSCAN") return node;

    if (Array.isArray(node.shards)) {
      for (const shard of node.shards) {
        const found = findLeaf(shard.winningPlan || shard);
        if (found) return found;
      }
    }

    for (const key of ["inputStage", "inputStages", "queryPlan", "winningPlan"]) {
      const val = node[key];
      if (Array.isArray(val)) {
        for (const item of val) {
          const found = findLeaf(item);
          if (found) return found;
        }
      } else if (val) {
        const found = findLeaf(val);
        if (found) return found;
      }
    }

    return null;
  }

  const leaf = findLeaf(exp.queryPlanner.winningPlan);

  return {
    scenario: label,
    leaf_stage: leaf ? leaf.stage : null,
    index_name: leaf && leaf.indexName ? leaf.indexName : null,
    totalDocsExamined: exp.executionStats.totalDocsExamined,
    totalKeysExamined: exp.executionStats.totalKeysExamined,
    nReturned: exp.executionStats.nReturned
  };
}

[
  summarize("team_id only", { team_id: 217 }),
  summarize("team_id + event_type_name", { team_id: 217, event_type_name: "Pass" }),
  summarize("event_type_name only", { event_type_name: "Pass" })
]
```

Comment:
In general, this query demonstrates the left-prefix rule for compound indexes. MongoDB can usually use the compound index when the query starts with the leftmost field, but not when the leftmost field is skipped.
In this project, both `team_id only` and `team_id + event_type_name` used `ix_events_team_type`, while `event_type_name only` fell back to `COLLSCAN`. This makes the design trade-off of the compound index easy to explain in the documentation.

### Query 23: Comparison of indexed sorting versus blocking sort
Task:
Compare an indexed sort supported by `ix_events_season_minute` with a non-indexed workload that requires a blocking sort stage.

Command:
```javascript
function summarize(label, query, sortSpec) {
  let cursor = db.getSiblingDB("statsbomb").events.find(query);
  if (sortSpec) {
    cursor = cursor.sort(sortSpec);
  }

  const exp = cursor.limit(20).explain("executionStats");

  function hasStage(node, stageName) {
    if (!node || typeof node !== "object") return false;
    if (node.stage === stageName) return true;
    if (Array.isArray(node.shards)) {
      return node.shards.some(shard => hasStage(shard.winningPlan || shard, stageName));
    }

    return Object.values(node).some(val =>
      Array.isArray(val)
        ? val.some(item => hasStage(item, stageName))
        : hasStage(val, stageName)
    );
  }

  function findLeaf(node) {
    if (!node || typeof node !== "object") return null;
    if (node.stage === "IXSCAN" || node.stage === "COLLSCAN") return node;
    if (Array.isArray(node.shards)) {
      for (const shard of node.shards) {
        const found = findLeaf(shard.winningPlan || shard);
        if (found) return found;
      }
    }

    for (const val of Object.values(node)) {
      if (Array.isArray(val)) {
        for (const item of val) {
          const found = findLeaf(item);
          if (found) return found;
        }
      } else if (val && typeof val === "object") {
        const found = findLeaf(val);
        if (found) return found;
      }
    }

    return null;
  }

  const leaf = findLeaf(exp.queryPlanner.winningPlan);

  return {
    scenario: label,
    leaf_stage: leaf ? leaf.stage : null,
    index_name: leaf && leaf.indexName ? leaf.indexName : null,
    has_blocking_sort: hasStage(exp.queryPlanner.winningPlan, "SORT"),
    totalDocsExamined: exp.executionStats.totalDocsExamined,
    totalKeysExamined: exp.executionStats.totalKeysExamined,
    nReturned: exp.executionStats.nReturned
  };
}

[
  summarize(
    "indexed season filter + minute sort",
    { season: "2019/2020", minute: { $gte: 75 } },
    { minute: 1 }
  ),
  summarize(
    "non-indexed team_name filter + minute sort",
    { team_name: "Barcelona" },
    { minute: 1 }
  )
]
```

Comment:
In general, this command compares two sorting scenarios and explicitly checks whether a blocking `SORT` stage appears in the winning plan. That is one of the clearest ways to explain the performance value of a compound index that supports both filtering and sorting.
In this project, the indexed scenario used `ix_events_season_minute` without a blocking sort, while the non-indexed `team_name` workload required `COLLSCAN` and a blocking `SORT`. The difference in examined documents is large enough to be convincing during defense.

### Query 24: Per-shard index storage overhead on the `events` collection
Task:
Use `collStats` to compare how much index storage each shard consumes for the `events` collection and determine which index is the largest on each shard.

Command:
```javascript
const stats = db.getSiblingDB("statsbomb").runCommand({ collStats: "events" });

Object.entries(stats.shards)
  .map(([shard, shardStats]) => ({
    shard,
    count: shardStats.count,
    size: shardStats.size,
    avgObjSize: shardStats.avgObjSize,
    totalIndexSize: shardStats.totalIndexSize,
    index_to_data_ratio_pct: Number(((shardStats.totalIndexSize / shardStats.size) * 100).toFixed(2)),
    largest_index_name: Object.entries(shardStats.indexSizes).sort((a, b) => b[1] - a[1])[0][0],
    largest_index_size: Object.entries(shardStats.indexSizes).sort((a, b) => b[1] - a[1])[0][1]
  }))
  .sort((a, b) => b.totalIndexSize - a.totalIndexSize || a.shard.localeCompare(b.shard));
```

Comment:
In general, this command looks at the storage cost of indexing, not only at read plans. It reshapes sharded `collStats` output into a per-shard comparison and derives an index-to-data ratio that is useful for capacity planning.
In this project, the result shows that index overhead is very similar across all three shards and that the largest index on every shard is the hashed shard-key index on `event_id`. This is a good argument that the distribution and index maintenance cost are balanced across the cluster.

## Category 5: Cluster / sharding / admin

### Query 25: Chunk ownership by shard with representative hashed boundaries
Task:
Analyze how the sharded `statsbomb.events` collection is split into chunks in MongoDB 8.0 metadata, enrich each shard with `config.shards`, and show representative lower and upper chunk bounds.

Command:
```javascript
db.getSiblingDB("config").collections.aggregate([
  { $match: { _id: "statsbomb.events", dropped: { $ne: true } } },
  {
    $lookup: {
      from: "chunks",
      localField: "uuid",
      foreignField: "uuid",
      as: "chunks"
    }
  },
  { $unwind: "$chunks" },
  { $sort: { "chunks.shard": 1, "chunks.min.event_id": 1 } },
  {
    $group: {
      _id: "$chunks.shard",
      chunk_count: { $sum: 1 },
      first_chunk_min: { $first: "$chunks.min" },
      last_chunk_max: { $last: "$chunks.max" }
    }
  },
  {
    $lookup: {
      from: "shards",
      localField: "_id",
      foreignField: "_id",
      as: "shard_meta"
    }
  },
  { $unwind: "$shard_meta" },
  {
    $project: {
      _id: 0,
      shard: "$_id",
      host: "$shard_meta.host",
      state: "$shard_meta.state",
      chunk_count: 1,
      first_chunk_min: 1,
      last_chunk_max: 1
    }
  },
  { $sort: { chunk_count: -1, shard: 1 } }
])
```

Comment:
In general, this pipeline works with MongoDB sharding metadata by first resolving the collection UUID from `config.collections` and then joining the physical chunk documents from `config.chunks`. This is important in newer MongoDB versions where chunk metadata is linked by UUID rather than by namespace.
In this project, the query proves that `statsbomb.events` is not only marked as sharded, but is physically split into chunks owned by all three shard replica sets. Showing the hashed lower and upper bounds per shard makes the distribution more concrete than a simple `sh.status()` output.

### Query 26: Chunk balance deviation from the ideal equal distribution
Task:
Measure how evenly the `statsbomb.events` chunks are distributed by shard and compute each shard's percentage share and deviation from the ideal equal distribution.

Command:
```javascript
db.getSiblingDB("config").collections.aggregate([
  { $match: { _id: "statsbomb.events", dropped: { $ne: true } } },
  {
    $lookup: {
      from: "chunks",
      localField: "uuid",
      foreignField: "uuid",
      as: "chunks"
    }
  },
  { $unwind: "$chunks" },
  { $group: { _id: "$chunks.shard", chunk_count: { $sum: 1 } } },
  {
    $group: {
      _id: null,
      total_chunks: { $sum: "$chunk_count" },
      shard_count: { $sum: 1 },
      shard_stats: {
        $push: {
          shard: "$_id",
          chunk_count: "$chunk_count"
        }
      }
    }
  },
  { $unwind: "$shard_stats" },
  {
    $project: {
      _id: 0,
      shard: "$shard_stats.shard",
      chunk_count: "$shard_stats.chunk_count",
      total_chunks: 1,
      ideal_chunks_per_shard: {
        $round: [{ $divide: ["$total_chunks", "$shard_count"] }, 2]
      },
      share_pct: {
        $round: [
          {
            $multiply: [
              { $divide: ["$shard_stats.chunk_count", "$total_chunks"] },
              100
            ]
          },
          2
        ]
      },
      deviation_from_ideal_pct: {
        $round: [
          {
            $multiply: [
              {
                $divide: [
                  {
                    $subtract: [
                      "$shard_stats.chunk_count",
                      { $divide: ["$total_chunks", "$shard_count"] }
                    ]
                  },
                  { $divide: ["$total_chunks", "$shard_count"] }
                ]
              },
              100
            ]
          },
          2
        ]
      }
    }
  },
  { $sort: { chunk_count: -1, shard: 1 } }
])
```

Comment:
In general, this is a two-level administrative aggregation built on top of collection UUID to chunk metadata resolution. First it counts chunks per shard, then it computes the global denominator and derives normalized balance metrics for each shard.
In this project, the query is stronger than simply listing shard ownership because it quantifies whether the balancer and hashed shard key produce a near-even chunk layout. This is exactly the kind of evidence that supports the sharding design choices described in the architecture chapter.

### Query 27: Cluster operation history for collection lifecycle and sharding events
Task:
Aggregate the operational history stored in `config.changelog` and summarize how often key events such as sharding a collection and dropping collections occurred for the project datasets.

Command:
```javascript
db.getSiblingDB("config").changelog.aggregate([
  {
    $match: {
      what: {
        $in: [
          "addShard",
          "shardCollection.start",
          "shardCollection.end",
          "dropCollection.start",
          "dropCollection"
        ]
      },
      ns: { $in: ["statsbomb.events", "statsbomb.players", "statsbomb.matches"] }
    }
  },
  {
    $group: {
      _id: {
        operation: "$what",
        server: "$server"
      },
      operations: { $sum: 1 },
      first_seen: { $min: "$time" },
      last_seen: { $max: "$time" },
      namespaces: { $addToSet: "$ns" }
    }
  },
  {
    $project: {
      _id: 0,
      operation: "$_id.operation",
      server: "$_id.server",
      operations: 1,
      first_seen: 1,
      last_seen: 1,
      namespaces: 1
    }
  },
  { $sort: { last_seen: -1, operations: -1, operation: 1 } }
])
```

Comment:
In general, `config.changelog` is an operational history collection for cluster administration. This query filters the events that are actually present in the current MongoDB 8.0 cluster metadata and then groups them by operation type and server to reconstruct what happened during dataset import and sharding setup.
In this project, the output documents that the cluster really performed administrative actions such as dropping collections during reload and creating the sharded `statsbomb.events` collection. That makes the deployment more auditable and gives stronger evidence than a static snapshot command.

### Query 28: Replication lag and sync-source analysis inside `shard01rs`
Task:
Compute a concise replication health view for all replica set members of `shard01rs`, including replication lag against the current primary and the sync source used by each secondary.

Command:
```javascript
const status = rs.status();
const primary = status.members.find(member => member.stateStr === "PRIMARY");

status.members
  .filter(member => ["PRIMARY", "SECONDARY"].includes(member.stateStr))
  .map(member => ({
    name: member.name,
    state: member.stateStr,
    health: member.health,
    sync_source: member.syncSourceHost || null,
    optimeDate: member.optimeDate,
    replication_lag_seconds:
      primary && member.optimeDate
        ? Math.max(0, Math.round((primary.optimeDate - member.optimeDate) / 1000))
        : null
  }))
  .sort((a, b) =>
    a.replication_lag_seconds === b.replication_lag_seconds
      ? a.name.localeCompare(b.name)
      : a.replication_lag_seconds - b.replication_lag_seconds
  );
```

Comment:
In general, this command transforms the verbose result of `rs.status()` into an analytical summary. Instead of only listing states, it computes a derived metric, namely replication lag in seconds relative to the current primary.
In this project, the query should be executed on the primary of `shard01rs`. It is much stronger than a basic replica-set status dump because it directly shows whether secondaries are catching up correctly and from which source they replicate, which is useful both for the replication chapter and for a failover demonstration.

### Query 29: Validation schema audit for all application collections
Task:
Inspect all main project collections and summarize whether strict validation is enabled, how many required fields each validator contains, and how many properties are governed by the schema.

Command:
```javascript
const collInfos = db.getSiblingDB("statsbomb").runCommand({
  listCollections: 1,
  filter: { name: { $in: ["matches", "players", "events"] } }
}).cursor.firstBatch;

collInfos
  .map(function(collection) {
    const schema =
      (collection.options &&
        collection.options.validator &&
        collection.options.validator.$jsonSchema) || {};
    const required = schema.required || [];
    const properties = schema.properties || {};

    return {
      name: collection.name,
      validationLevel: collection.options.validationLevel,
      validationAction: collection.options.validationAction,
      required_fields: required,
      required_field_count: required.length,
      validated_property_count: Object.keys(properties).length
    };
  })
  .sort(function(a, b) {
    return (
      b.required_field_count - a.required_field_count ||
      a.name.localeCompare(b.name)
    );
  });
```

Comment:
In general, this command reads collection metadata rather than business data and then reshapes the nested validator definition into a compact audit view. It is an administrative query focused on schema governance.
In this project, the assignment explicitly requires MongoDB validation schema. This query proves that `matches`, `players`, and `events` are all protected by validators applied through `collMod`, and it also shows that validation runs in strict/error mode instead of being merely decorative.

### Query 30: Administrative users expanded into a role matrix
Task:
Expand the internal user definitions in `admin.system.users` and show a normalized user-role matrix with the number of roles assigned to each user.

Command:
```javascript
db.getSiblingDB("admin").system.users.aggregate([
  { $unwind: "$roles" },
  {
    $group: {
      _id: {
        user: "$user",
        auth_db: "$db"
      },
      roles: {
        $addToSet: {
          role: "$roles.role",
          db: "$roles.db"
        }
      },
      role_count: { $sum: 1 }
    }
  },
  {
    $project: {
      _id: 0,
      user: "$_id.user",
      auth_db: "$_id.auth_db",
      role_count: 1,
      roles: 1
    }
  },
  { $sort: { role_count: -1, user: 1 } }
])
```

Comment:
In general, this aggregation normalizes MongoDB user metadata by expanding the embedded `roles` array and regrouping the result into one readable record per user.
In this project, the query is a stronger replacement for `getUsers()` because it explicitly demonstrates role expansion and aggregation over security metadata. It is also useful for documenting that authentication and authorization are active and that the administrative user has the expected privileges.
