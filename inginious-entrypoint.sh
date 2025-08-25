#!/bin/sh

set -eu

TINI_SUBREAPER=1 dockerd-entrypoint.sh &
docker_pid=$!

while ! docker info >/dev/null 2>&1; do
    sleep 1
done

if [ ! -f "$INGINIOUS_WEBAPP_CONFIG" ]; then
cat << EOT > "$INGINIOUS_WEBAPP_CONFIG"
backend: local
backup_directory: $INGINIOUS_BACKUPS_DIR
local-config:
  tmp_dir: /tmp/agent_tmp
mongo_opt:
  database: INGInious
  host: db
plugins: []
session_parameters:
  ignore_change_ip: false
  secret_key: $(openssl rand -hex 32)
  secure: false
  timeout: 86400
tasks_directory: $INGINIOUS_TASKS_DIR
use_minified_js: true
EOT
fi

exec "$@" &
command_pid=$!

signalHandler() {
    kill $command_pid $docker_pid
    wait $command_pid
    exit $?
}

trap signalHandler TERM

wait -n

exit $?
