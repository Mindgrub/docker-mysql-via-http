#!/bin/sh
set -e

# Send heartbeat
if [ -n "$SFN_TASK_TOKEN" ]; then
  aws stepfunctions send-task-heartbeat --task-token "$SFN_TASK_TOKEN"
fi

# Variable defaults
: "${DB_PORT:=3306}"

# Download the file
destination=$(mktemp -p /data)
echo "About to download $SQL_FILE_URL to $destination"
curl -s -o "$destination" "$SQL_FILE_URL"

# Send heartbeat
if [ -n "$SFN_TASK_TOKEN" ]; then
  aws stepfunctions send-task-heartbeat --task-token "$SFN_TASK_TOKEN"
fi

# Test the file
mime_type=$(file -b --mime-type "$destination")
echo "Detected MIME type of $destination: $mime_type"

# Run the file
set -- -h "$DB_HOST" -u "$DB_USER" --password="$DB_PASS" -P "$DB_PORT" --comments
if [ -n "$MYSQL_NET_BUFFER_LENGTH" ]; then
  set -- "$@" --net-buffer-length="$MYSQL_NET_BUFFER_LENGTH"
fi
if [ -n "$MYSQL_OPTS" ]; then
  set -- "$@" $MYSQL_OPTS
fi
set -- "$@" "$DB_NAME"
mysql_opts=$(printf ' %s' "$@")
echo "About to import $destination to mysql://$DB_HOST:$DB_PORT/$DB_NAME"
if [ "$mime_type" = "application/gzip" ]; then
  zcat "$destination" | eval "mysql $mysql_opts"
else
  eval "mysql $mysql_opts" < "$destination"
fi
echo "Import from $destination completed"

# Invoke webhook
if [ -n "$COMPLETED_WEBHOOK" ]; then
  echo "About to make a POST request to $COMPLETED_WEBHOOK"
  webhook_payload=$(jq -cn --arg host "$DB_HOST" --arg status complete '{"host":$host,"status":$status}')
  curl -L -v -H "Content-Type: application/json" --data "$webhook_payload" -X POST "$COMPLETED_WEBHOOK"
fi

# Send activity success
if [ -n "$SFN_TASK_TOKEN" ]; then
  json_output=$(jq -cn --arg host "$DB_HOST" --arg status complete '{"host":$host,"status":$status}')
  aws stepfunctions send-task-success --task-token "$SFN_TASK_TOKEN" --task-output "$json_output"
fi
