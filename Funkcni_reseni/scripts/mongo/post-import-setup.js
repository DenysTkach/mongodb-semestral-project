const dbName = globalThis.APP_DB || "statsbomb";
const appDb = db.getSiblingDB(dbName);

function numericTypes(nullable = false) {
  const types = ["int", "long", "double"];
  if (nullable) {
    types.push("null");
  }
  return types;
}

function stringTypes(nullable = false) {
  return nullable ? ["string", "null"] : "string";
}

function applyValidator(collectionName, schema) {
  const collectionInfo = appDb.getCollectionInfos({ name: collectionName });
  if (!collectionInfo.length) {
    throw new Error("Collection '" + collectionName + "' does not exist after import.");
  }

  const result = appDb.runCommand({
    collMod: collectionName,
    validator: { $jsonSchema: schema },
    validationLevel: "strict",
    validationAction: "error",
  });

  if (!result.ok) {
    throw new Error(
      "Failed to apply validator for '" + collectionName + "': " + tojson(result)
    );
  }
}

applyValidator("matches", {
  bsonType: "object",
  required: [
    "match_id",
    "match_date",
    "season",
    "competition_id",
    "competition_name",
    "home_team_id",
    "home_team_name",
    "away_team_id",
    "away_team_name",
  ],
  properties: {
    match_id: { bsonType: numericTypes() },
    match_date: { bsonType: stringTypes() },
    kick_off: { bsonType: stringTypes() },
    season: { bsonType: stringTypes() },
    competition_id: { bsonType: numericTypes() },
    competition_name: { bsonType: stringTypes() },
    home_team_id: { bsonType: numericTypes() },
    home_team_name: { bsonType: stringTypes() },
    away_team_id: { bsonType: numericTypes() },
    away_team_name: { bsonType: stringTypes() },
    home_score: { bsonType: numericTypes() },
    away_score: { bsonType: numericTypes() },
    stadium_id: { bsonType: numericTypes(true) },
    stadium_name: { bsonType: stringTypes(true) },
    referee_id: { bsonType: numericTypes(true) },
    referee_name: { bsonType: stringTypes(true) },
    competition_stage_id: { bsonType: numericTypes(true) },
    competition_stage_name: { bsonType: stringTypes(true) },
  },
});

applyValidator("players", {
  bsonType: "object",
  required: [
    "player_id",
    "player_name",
    "jersey_number",
    "country",
    "team_id",
    "team_name",
    "season",
  ],
  properties: {
    player_id: { bsonType: numericTypes() },
    player_name: { bsonType: stringTypes() },
    player_nickname: { bsonType: stringTypes(true) },
    jersey_number: { bsonType: numericTypes() },
    country: { bsonType: stringTypes() },
    team_id: { bsonType: numericTypes() },
    team_name: { bsonType: stringTypes() },
    position: { bsonType: stringTypes(true) },
    season: { bsonType: stringTypes() },
  },
});

applyValidator("events", {
  bsonType: "object",
  required: [
    "event_id",
    "match_id",
    "season",
    "index",
    "period",
    "timestamp",
    "minute",
    "second",
    "event_type_name",
  ],
  properties: {
    event_id: { bsonType: stringTypes() },
    match_id: { bsonType: numericTypes() },
    season: { bsonType: stringTypes() },
    index: { bsonType: numericTypes() },
    period: { bsonType: numericTypes() },
    timestamp: { bsonType: stringTypes() },
    minute: { bsonType: numericTypes() },
    second: { bsonType: numericTypes() },
    possession: { bsonType: numericTypes(true) },
    possession_team_id: { bsonType: numericTypes(true) },
    possession_team_name: { bsonType: stringTypes(true) },
    team_id: { bsonType: numericTypes(true) },
    team_name: { bsonType: stringTypes(true) },
    player_id: { bsonType: numericTypes(true) },
    player_name: { bsonType: stringTypes(true) },
    position_id: { bsonType: numericTypes(true) },
    position_name: { bsonType: stringTypes(true) },
    event_type_id: { bsonType: numericTypes(true) },
    event_type_name: { bsonType: stringTypes() },
    play_pattern_id: { bsonType: numericTypes(true) },
    play_pattern_name: { bsonType: stringTypes(true) },
    location_x: { bsonType: numericTypes(true) },
    location_y: { bsonType: numericTypes(true) },
    pass_recipient_id: { bsonType: numericTypes(true) },
    pass_recipient_name: { bsonType: stringTypes(true) },
    shot_outcome_name: { bsonType: stringTypes(true) },
    card_name: { bsonType: stringTypes(true) },
    duration: { bsonType: numericTypes(true) },
  },
});

appDb.matches.createIndex({ match_id: 1 }, { unique: true, name: "ux_match_id" });
appDb.players.createIndex({ player_id: 1 }, { unique: true, name: "ux_player_id" });
appDb.events.createIndex({ match_id: 1 }, { name: "ix_events_match_id" });
appDb.events.createIndex({ player_id: 1 }, { name: "ix_events_player_id" });
appDb.events.createIndex(
  { team_id: 1, event_type_name: 1 },
  { name: "ix_events_team_type" }
);
appDb.events.createIndex({ season: 1, minute: 1 }, { name: "ix_events_season_minute" });

printjson({
  validators: appDb.getCollectionInfos().map((collection) => ({
    name: collection.name,
    validator: collection.options.validator || null,
  })),
  eventsStats: appDb.runCommand({ collStats: "events" }),
});
