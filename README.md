# docker-mysql-via-http

An Alpine-based Docker image for downloading a file and executing it with the `mysql` client.

There are tags for Alpine 3.20, 3.19, 3.18, and 3.17. This image is available on both the `linux/amd64` and `linux/arm64` platforms.

```bash
# The "latest" tag will always point to the most recent version of Alpine.
# Assuming 3.20.2 is most recent, these three commands all pull the same image.
docker pull @mindgrub/mysql-via-http:latest
docker pull @mindgrub/mysql-via-http:1-alpine-3.20
docker pull @mindgrub/mysql-via-http:1-alpine-3.20.2

# Pull other versions or architectures.
docker pull --platform linux/arm64 @mindgrub/mysql-via-http:1-alpine-3.18
```

## Environment Variables

- `SQL_FILE_URL` – Required. The URL of the `.sql` or `.sql.gz` to ingest.
- `DB_HOST` – Required. The hostname to which `mysql` will connect.
- `DB_PORT` – Optional. The TCP port to which `mysql` will connect (Default: "3306").
- `DB_NAME` – Required. The name of the database to dump.
- `DB_USER` – Required. The username to use to connect.
- `DB_PASS` – Required. The password to use to connect.
- `MYSQL_OPTS` – Optional. Additional command line options to provide to `mysql`.
- `COMPLETED_WEBHOOK` – Optional. A URL to receive a POST request containing JSON content once ingestion completes.
- `SFN_TASK_TOKEN` – Optional. A Step Functions [Task Token](https://docs.aws.amazon.com/step-functions/latest/apireference/API_GetActivityTask.html#StepFunctions-GetActivityTask-response-taskToken). If present, this token will be used to call [`SendTaskHeartbeat`](https://docs.aws.amazon.com/step-functions/latest/apireference/API_SendTaskHeartbeat.html) and [`SendTaskSuccess`](https://docs.aws.amazon.com/step-functions/latest/apireference/API_SendTaskSuccess.html). The task output sent to `SendTaskSuccess` will consist of a JSON object with a single property: `uri` (containing the S3 URI of the database dump).
- `MYSQL_NET_BUFFER_LENGTH` – _[Deprecated]_ Optional. The `net_buffer_length` setting for `mysqldump`.

## Technical Details

Since this image is based on Alpine, the version of `mysql` in this image is actually MariaDB.

The following CLI arguments are included in the call to `mysql`: `--comments`. Use the `MYSQL_OPTS` environment variable to specify additional options.
