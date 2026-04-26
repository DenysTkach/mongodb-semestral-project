#!/bin/sh
set -eu

log() {
    printf '%s\n' "$1"
}

mongo_eval() {
    container="$1"
    port="$2"
    eval_code="$3"
    username="${4:-}"
    password="${5:-}"
    auth_db="${6:-}"

    if [ -n "$username" ]; then
        docker exec "$container" mongosh \
            --quiet \
            --port "$port" \
            --username "$username" \
            --password "$password" \
            --authenticationDatabase "$auth_db" \
            --eval "$eval_code"
    else
        docker exec "$container" mongosh \
            --quiet \
            --port "$port" \
            --eval "$eval_code"
    fi
}

wait_for_mongo() {
    container="$1"
    port="$2"
    attempts="${3:-60}"
    i=1

    while [ "$i" -le "$attempts" ]; do
        if output="$(docker exec "$container" mongosh --quiet --port "$port" --eval 'db.runCommand({ ping: 1 }).ok' 2>/dev/null)" &&
            printf '%s' "$output" | grep -q '1'; then
            log "Mongo container ready: $container"
            return 0
        fi

        i=$((i + 1))
        sleep 2
    done

    log "Timed out waiting for Mongo container '$container' on port $port."
    exit 1
}

find_primary() {
    port="$1"
    shift

    for container in "$@"; do
        output="$(docker exec "$container" mongosh --quiet --port "$port" --eval 'const hello = db.hello(); print(hello.isWritablePrimary || hello.ismaster ? "PRIMARY" : "NOT_PRIMARY");' 2>/dev/null || true)"
        if printf '%s' "$output" | grep -q 'PRIMARY'; then
            printf '%s\n' "$container"
            return 0
        fi
    done

    return 1
}

wait_for_primary() {
    port="$1"
    shift
    attempts="${1:-60}"
    shift
    i=1

    while [ "$i" -le "$attempts" ]; do
        if primary="$(find_primary "$port" "$@" 2>/dev/null)" && [ -n "$primary" ]; then
            printf '%s\n' "$primary"
            return 0
        fi

        i=$((i + 1))
        sleep 2
    done

    log "Timed out waiting for a writable primary on port $port."
    exit 1
}

docker_exec() {
    docker "$@"
}

config_rs_init="$(cat <<'EOF'
try {
  rs.status();
} catch (e) {
  const message = String(e);
  if (message.includes('not authorized') || message.includes('requires authentication')) {
    print('configReplSet already protected by auth.');
  } else {
    rs.initiate({
      _id: 'configReplSet',
      configsvr: true,
      members: [
        { _id: 0, host: 'configsvr01:27017' },
        { _id: 1, host: 'configsvr02:27017' },
        { _id: 2, host: 'configsvr03:27017' }
      ]
    });
  }
}
EOF
)"

shard01_init="$(cat <<'EOF'
try {
  rs.status();
} catch (e) {
  const message = String(e);
  if (message.includes('not authorized') || message.includes('requires authentication')) {
    print('shard01rs already protected by auth.');
  } else {
    rs.initiate({
      _id: 'shard01rs',
      members: [
        { _id: 0, host: 'shard01a:27018' },
        { _id: 1, host: 'shard01b:27018' },
        { _id: 2, host: 'shard01c:27018' }
      ]
    });
  }
}
EOF
)"

shard02_init="$(cat <<'EOF'
try {
  rs.status();
} catch (e) {
  const message = String(e);
  if (message.includes('not authorized') || message.includes('requires authentication')) {
    print('shard02rs already protected by auth.');
  } else {
    rs.initiate({
      _id: 'shard02rs',
      members: [
        { _id: 0, host: 'shard02a:27018' },
        { _id: 1, host: 'shard02b:27018' },
        { _id: 2, host: 'shard02c:27018' }
      ]
    });
  }
}
EOF
)"

shard03_init="$(cat <<'EOF'
try {
  rs.status();
} catch (e) {
  const message = String(e);
  if (message.includes('not authorized') || message.includes('requires authentication')) {
    print('shard03rs already protected by auth.');
  } else {
    rs.initiate({
      _id: 'shard03rs',
      members: [
        { _id: 0, host: 'shard03a:27018' },
        { _id: 1, host: 'shard03b:27018' },
        { _id: 2, host: 'shard03c:27018' }
      ]
    });
  }
}
EOF
)"

ensure_root_user="$(cat <<EOF
const adminDb = db.getSiblingDB('admin');
try {
  adminDb.createUser({
    user: '$MONGO_ROOT_USERNAME',
    pwd: '$MONGO_ROOT_PASSWORD',
    roles: [{ role: 'root', db: 'admin' }]
  });
} catch (e) {
  const message = String(e);
  if (
    !message.includes('already exists') &&
    !message.includes('DuplicateKey') &&
    !message.includes('not authorized') &&
    !message.includes('requires authentication')
  ) {
    throw e;
  }
}
print('Root user ensured on config server.');
EOF
)"

add_shards="$(cat <<'EOF'
const existing = db.adminCommand({ listShards: 1 }).shards.map(shard => shard._id);
if (!existing.includes('shard01rs')) {
  sh.addShard('shard01rs/shard01a:27018,shard01b:27018,shard01c:27018');
}
if (!existing.includes('shard02rs')) {
  sh.addShard('shard02rs/shard02a:27018,shard02b:27018,shard02c:27018');
}
if (!existing.includes('shard03rs')) {
  sh.addShard('shard03rs/shard03a:27018,shard03b:27018,shard03c:27018');
}
printjson(db.adminCommand({ listShards: 1 }));
EOF
)"

create_app_user="$(cat <<EOF
const appDb = db.getSiblingDB('$MONGO_APP_DB');
if (!appDb.getUser('$MONGO_APP_USERNAME')) {
  appDb.createUser({
    user: '$MONGO_APP_USERNAME',
    pwd: '$MONGO_APP_PASSWORD',
    roles: [{ role: 'readWrite', db: '$MONGO_APP_DB' }]
  });
}
print('Application user ensured.');
EOF
)"

data_state_eval="$(cat <<EOF
const appDb = db.getSiblingDB('$MONGO_APP_DB');
const matches = appDb.matches.countDocuments();
const players = appDb.players.countDocuments();
const events = appDb.events.countDocuments();
if (matches === 0 && players === 0 && events === 0) {
  print('EMPTY');
} else if (matches > 0 && players > 0 && events > 0) {
  print('READY');
} else {
  print('PARTIAL');
}
EOF
)"

prepare_events_collection="$(cat <<EOF
const dbName = '$MONGO_APP_DB';
const appDb = db.getSiblingDB(dbName);

try {
  appDb.events.drop();
} catch (e) {
  const message = String(e);
  if (
    !message.includes('ns not found') &&
    !message.includes('NamespaceNotFound')
  ) {
    throw e;
  }
}

sh.enableSharding(dbName);
sh.shardCollection(
  dbName + '.events',
  { event_id: 'hashed' }
);
EOF
)"

for service in \
    configsvr01 configsvr02 configsvr03 \
    shard01a shard01b shard01c \
    shard02a shard02b shard02c \
    shard03a shard03b shard03c
do
    case "$service" in
        configsvr*)
            wait_for_mongo "$service" 27017
            ;;
        *)
            wait_for_mongo "$service" 27018
            ;;
    esac
done

mongo_eval "configsvr01" 27017 "$config_rs_init"
mongo_eval "shard01a" 27018 "$shard01_init"
mongo_eval "shard02a" 27018 "$shard02_init"
mongo_eval "shard03a" 27018 "$shard03_init"

config_primary="$(wait_for_primary 27017 60 configsvr01 configsvr02 configsvr03)"
log "Replica set primary ready: $config_primary"
log "Replica set primary ready: $(wait_for_primary 27018 60 shard01a shard01b shard01c)"
log "Replica set primary ready: $(wait_for_primary 27018 60 shard02a shard02b shard02c)"
log "Replica set primary ready: $(wait_for_primary 27018 60 shard03a shard03b shard03c)"

root_user_ensured="false"
i=1
while [ "$i" -le 30 ]; do
    for config_server in configsvr01 configsvr02 configsvr03; do
        if mongo_eval "$config_server" 27017 "$ensure_root_user" >/dev/null 2>&1; then
            root_user_ensured="true"
            break
        fi
    done

    if [ "$root_user_ensured" = "true" ]; then
        break
    fi

    i=$((i + 1))
    sleep 2
done

if [ "$root_user_ensured" != "true" ]; then
    log "Failed to create the root user on config replica set primary."
    exit 1
fi
log "Root user ensured on config server."

sleep 5
wait_for_mongo "mongos-router" 27017

mongo_eval "mongos-router" 27017 "$add_shards" "$MONGO_ROOT_USERNAME" "$MONGO_ROOT_PASSWORD" "admin"
mongo_eval "mongos-router" 27017 "$create_app_user" "$MONGO_ROOT_USERNAME" "$MONGO_ROOT_PASSWORD" "admin"

data_state="$(mongo_eval "mongos-router" 27017 "$data_state_eval" "$MONGO_ROOT_USERNAME" "$MONGO_ROOT_PASSWORD" "admin" | tail -n 1)"

if [ "$data_state" = "EMPTY" ] || [ "$data_state" = "PARTIAL" ]; then
    log "Starting initial data import."

    docker_exec exec mongos-router mongoimport \
        --host localhost \
        --port 27017 \
        --username "$MONGO_ROOT_USERNAME" \
        --password "$MONGO_ROOT_PASSWORD" \
        --authenticationDatabase admin \
        --db "$MONGO_APP_DB" \
        --collection matches \
        --file /import/matches.json \
        --jsonArray \
        --drop

    docker_exec exec mongos-router mongoimport \
        --host localhost \
        --port 27017 \
        --username "$MONGO_ROOT_USERNAME" \
        --password "$MONGO_ROOT_PASSWORD" \
        --authenticationDatabase admin \
        --db "$MONGO_APP_DB" \
        --collection players \
        --file /import/players.json \
        --jsonArray \
        --drop

    mongo_eval "mongos-router" 27017 "$prepare_events_collection" "$MONGO_ROOT_USERNAME" "$MONGO_ROOT_PASSWORD" "admin"

    docker_exec exec mongos-router mongoimport \
        --host localhost \
        --port 27017 \
        --username "$MONGO_ROOT_USERNAME" \
        --password "$MONGO_ROOT_PASSWORD" \
        --authenticationDatabase admin \
        --db "$MONGO_APP_DB" \
        --collection events \
        --file /import/events.json \
        --jsonArray
else
    log "Datasets already present, skipping import."
fi

docker_exec exec mongos-router mongosh \
    --quiet \
    --port 27017 \
    --username "$MONGO_ROOT_USERNAME" \
    --password "$MONGO_ROOT_PASSWORD" \
    --authenticationDatabase admin \
    --eval "globalThis.APP_DB = '$MONGO_APP_DB';" \
    /workspace/scripts/mongo/post-import-setup.js

log ""
log "Cluster bootstrap completed automatically."
log "Collections: matches, players, events"
