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

### Query 13: Pass events reshaped into nested documents
Task:
Transform pass events from the flat event schema into a nested document structure that groups match context, player information, pass information, and coordinates.

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
    $project: {
      _id: 0,
      event_id: 1,
      match_context: {
        match_id: "$match_id",
        season: "$season",
        period: "$period",
        minute: "$minute",
        second: "$second"
      },
      player_info: {
        player_id: "$player_id",
        player_name: "$player_name",
        team_id: "$team_id",
        team_name: "$team_name",
        position_name: "$position_name"
      },
      pass_context: {
        recipient_id: "$pass_recipient_id",
        recipient_name: "$pass_recipient_name",
        play_pattern_name: "$play_pattern_name",
        duration: "$duration"
      },
      location: {
        x: "$location_x",
        y: "$location_y"
      }
    }
  },
  { $limit: 10 }
])
```

Comment:
In general, this query does not aggregate counts; instead it reshapes flat source documents into a nested output that is closer to a document-oriented domain model.
In this project, the prepared StatsBomb events are mostly flattened, so this pipeline demonstrates how to reconstruct a more natural embedded structure for pass analysis without changing the stored data itself.

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

### Query 15: Teams with embedded disciplinary summaries
Task:
For each team, create a nested card summary document that contains yellow cards, red cards, and total card events.

Command:
```javascript
db.getSiblingDB("statsbomb").events.aggregate([
  { $match: { card_name: { $ne: null }, team_name: { $ne: null } } },
  {
    $group: {
      _id: "$team_name",
      yellow_cards: {
        $sum: {
          $cond: [{ $eq: ["$card_name", "Yellow Card"] }, 1, 0]
        }
      },
      red_cards: {
        $sum: {
          $cond: [
            { $in: ["$card_name", ["Red Card", "Second Yellow"]] },
            1,
            0
          ]
        }
      },
      total_cards: { $sum: 1 }
    }
  },
  { $sort: { total_cards: -1, _id: 1 } },
  { $limit: 10 },
  {
    $project: {
      _id: 0,
      team_name: "$_id",
      card_summary: {
        yellow_cards: "$yellow_cards",
        red_cards: "$red_cards",
        total_cards: "$total_cards"
      }
    }
  }
])
```

Comment:
In general, this query combines conditional aggregation with document reshaping, so the final result is a compact embedded summary instead of a flat list of metrics.
In this project, the pipeline produces a nested disciplinary profile per team. Barcelona clearly dominates the selected sample because the dataset contains many Barcelona matches.

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

### Query 19: Overview of indexes on the events collection
Task:
List all indexes defined on the `events` collection together with their key patterns.

Command:
```javascript
db.getSiblingDB("statsbomb").events.getIndexes().map(index => ({
  name: index.name,
  key: index.key,
  version: index.v
}))
```

Comment:
In general, this command inspects the collection metadata and returns the index definitions that MongoDB can use during query planning.
In this project, the `events` collection contains the default `_id` index, the hashed shard key index on `event_id`, and several analytical indexes such as `match_id`, `player_id`, `team_id + event_type_name`, and `season + minute`. This query is the starting point for explaining later performance-related commands.

### Query 20: Index usage statistics across shards
Task:
Show index usage counters for the `events` collection and include the shard on which each counter was recorded.

Command:
```javascript
db.getSiblingDB("statsbomb").events.aggregate([
  { $indexStats: {} },
  {
    $project: {
      _id: 0,
      name: 1,
      key: 1,
      shard: 1,
      host: 1,
      access_ops: "$accesses.ops",
      tracked_since: "$accesses.since"
    }
  },
  { $sort: { access_ops: -1, name: 1, shard: 1 } }
])
```

Comment:
In general, `$indexStats` returns per-index usage counters collected by MongoDB since the node started tracking them.
In this project, the output shows the counters separately for each shard replica set. During validation, the `player_id` and `match_id` indexes already had non-zero usage, which confirms that some of our analytical queries were using them.

### Query 21: Execution plan for filtering by match id
Task:
Use `explain("executionStats")` to verify that filtering events by `match_id` uses the dedicated `ix_events_match_id` index.

Command:
```javascript
const exp = db.getSiblingDB("statsbomb")
  .events
  .find({ match_id: 303451 })
  .explain("executionStats");

printjson({
  winningPlan: exp.queryPlanner.winningPlan,
  totalDocsExamined: exp.executionStats.totalDocsExamined,
  totalKeysExamined: exp.executionStats.totalKeysExamined,
  nReturned: exp.executionStats.nReturned
});
```

Comment:
In general, `explain("executionStats")` shows both the winning execution plan and how much work the server had to do, including examined keys and examined documents.
In this project, the plan used `IXSCAN` on `ix_events_match_id` on every shard and then merged the results. That is exactly what we want for frequent match-scoped analytical queries.

### Query 22: Execution plan for the compound team and event-type index
Task:
Verify that a query filtering by both `team_id` and `event_type_name` uses the compound index `ix_events_team_type`.

Command:
```javascript
const exp = db.getSiblingDB("statsbomb")
  .events
  .find({ team_id: 217, event_type_name: "Pass" })
  .explain("executionStats");

printjson({
  winningPlan: exp.queryPlanner.winningPlan,
  totalDocsExamined: exp.executionStats.totalDocsExamined,
  totalKeysExamined: exp.executionStats.totalKeysExamined,
  nReturned: exp.executionStats.nReturned
});
```

Comment:
In general, this command is used to confirm that a compound predicate can exploit a matching compound index instead of scanning the collection.
In this project, the plan used `IXSCAN` on `ix_events_team_type`, which is important because many football analytics queries naturally filter by team and event type together.

### Query 23: Execution plan for season filtering with minute sorting
Task:
Check whether a query filtered by `season` and sorted by `minute` can use the `ix_events_season_minute` index efficiently.

Command:
```javascript
const exp = db.getSiblingDB("statsbomb")
  .events
  .find({ season: "2019/2020", minute: { $gte: 75 } })
  .sort({ minute: 1 })
  .limit(20)
  .explain("executionStats");

printjson({
  winningPlan: exp.queryPlanner.winningPlan,
  totalDocsExamined: exp.executionStats.totalDocsExamined,
  totalKeysExamined: exp.executionStats.totalKeysExamined,
  nReturned: exp.executionStats.nReturned
});
```

Comment:
In general, this query tests whether an index can support both filtering and sorting, which is one of the key reasons to create compound indexes.
In this project, the winning plan used `IXSCAN` on `ix_events_season_minute` and applied a limit very early. This is a good sign for time-window analyses over the event stream.

### Query 24: Execution plan for a non-indexed field
Task:
Use `explain("executionStats")` on a filter by `team_name` to show what happens when the query uses a non-indexed field.

Command:
```javascript
const exp = db.getSiblingDB("statsbomb")
  .events
  .find({ team_name: "Barcelona" })
  .explain("executionStats");

printjson({
  winningPlan: exp.queryPlanner.winningPlan,
  totalDocsExamined: exp.executionStats.totalDocsExamined,
  totalKeysExamined: exp.executionStats.totalKeysExamined,
  nReturned: exp.executionStats.nReturned
});
```

Comment:
In general, this query is useful as a contrast case: when there is no suitable index, MongoDB falls back to `COLLSCAN`, which is more expensive on larger collections.
In this project, the explain output showed `COLLSCAN` on every shard, `0` examined keys, and examination of the full collection. That makes this query a clear example of why index design matters for performance.

## Category 5: Cluster / sharding / admin

### Query 25: Sharding status overview
Task:
Inspect the overall sharded cluster state, including shards, balancer, chunk metadata, and distribution of sharded collections.

Command:
```javascript
sh.status()
```

Comment:
In general, `sh.status()` is the standard MongoDB command for inspecting the global state of a sharded cluster.
In this project, the output confirms that the cluster contains three shards, that the `statsbomb.events` collection is sharded by hashed `event_id`, and that the balancer is enabled. It also shows that the event data is distributed across all three shards.

### Query 26: Database statistics summary
Task:
Show a compact summary of database-level statistics for the `statsbomb` database.

Command:
```javascript
const s = db.getSiblingDB("statsbomb").stats();

printjson({
  db: s.db,
  collections: s.collections,
  objects: s.objects,
  avgObjSize: s.avgObjSize,
  dataSize: s.dataSize,
  storageSize: s.storageSize,
  indexes: s.indexes,
  indexSize: s.indexSize,
  totalSize: s.totalSize
});
```

Comment:
In general, `db.stats()` provides database-level storage and object statistics aggregated over the whole database.
In this project, the command is useful for proving the overall scale of the loaded data and for documenting how much storage and indexing overhead the deployed solution currently uses.

### Query 27: Shard key metadata from the config database
Task:
Read shard key metadata for sharded collections from the `config.collections` metadata collection.

Command:
```javascript
db.getSiblingDB("config")
  .collections
  .find(
    {},
    { _id: 1, key: 1, unique: 1, lastmodEpoch: 1 }
  )
  .toArray()
```

Comment:
In general, the `config` database stores cluster metadata, and `config.collections` contains the shard-key definitions for sharded collections.
In this project, the command confirms that `statsbomb.events` is sharded by `{ event_id: "hashed" }`. This is an important administrative proof that the actual cluster metadata matches the intended architecture described in the documentation.

### Query 28: Document distribution across shards
Task:
Display how the `events` collection is physically distributed across the shards.

Command:
```javascript
db.getSiblingDB("statsbomb").events.getShardDistribution()
```

Comment:
In general, `getShardDistribution()` summarizes how many documents and how much data each shard owns for the selected sharded collection.
In this project, the result shows that the `events` collection is distributed almost evenly across all three shards, with about one third of the documents on each shard. That is exactly the kind of balance expected from a hashed shard key.

### Query 29: Replica set member states on a shard
Task:
Inspect the state of all members of the `shard01rs` replica set.

Command:
```javascript
rs.status().members.map(member => ({
  name: member.name,
  stateStr: member.stateStr,
  health: member.health,
  uptime: member.uptime
}))
```

Comment:
In general, `rs.status()` is the main command for checking replica set health, role assignment, and node availability.
In this project, the query was executed on the primary of `shard01rs` and showed one `PRIMARY` and two `SECONDARY` members, all with `health: 1`. This is a direct proof that shard replication is configured and functioning correctly.

### Query 30: Administrative users and roles
Task:
List users defined in the `admin` database together with their assigned roles.

Command:
```javascript
db.getSiblingDB("admin").getUsers()
```

Comment:
In general, `getUsers()` is an administrative security command that shows which users exist in the selected database and which roles they hold.
In this project, the command confirms that an administrative user exists and that authentication and authorization are active in the cluster. This is relevant because the assignment explicitly requires MongoDB security to be configured.
