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
