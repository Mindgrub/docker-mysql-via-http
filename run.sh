#!/bin/sh
set -e

# Variable defaults
: "${MYSQL_NET_BUFFER_LENGTH:=16384}"
: "${DB_PORT:=3306}"

# Download the file
destination=$(mktemp -p /data)
echo "About to download $SQL_FILE_URL to $destination"
curl -s -o "$destination" "$SQL_FILE_URL"

# Test the file
mime_type=$(file -b --mime-type "$destination")
echo "Detected MIME type of $destination: $mime_type"

# Run the file
echo "About to import $destination to mysql://$DB_HOST:$DB_PORT/$DB_NAME"
if [ "$mime_type" = "application/gzip" ]; then
  zcat "$destination" | mysql -h "$DB_HOST" -u "$DB_USER" --password="$DB_PASS" -P "$DB_PORT" --comments --net-buffer-length="$MYSQL_NET_BUFFER_LENGTH" "$DB_NAME"
else
  mysql -h "$DB_HOST" -u "$DB_USER" --password="$DB_PASS" -P "$DB_PORT" --comments --net-buffer-length="$MYSQL_NET_BUFFER_LENGTH" "$DB_NAME" < "$destination"
fi
echo "Import from $destination completed"

if [ -n "$COMPLETED_WEBHOOK" ]; then
  echo "About to make a POST request to $COMPLETED_WEBHOOK"
  webhook_payload=$(jq -cn --arg host "$DB_HOST" --arg status complete '{"host":$host,"status":$status}')
  curl -v -H "Content-Type: application/json" --data "$webhook_payload" -X POST "$COMPLETED_WEBHOOK"
fi
