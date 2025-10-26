#!/bin/bash
# Safely back up a MariaDB database with error handling.
set -o pipefail

echo "Restoring database '${MYSQL_DATABASE}'..."

INFILE="/mnt/backups/${MYSQL_DATABASE}.sql.gz"

if gunzip < "${INFILE}" | \
    mariadb \
    -u "${MYSQL_USER}" \
    -h "${MYSQL_HOST}" \
    -p"${MYSQL_PASSWORD}" \
    "${MYSQL_DATABASE}"; 
then
    echo "Database restore completed: ${INFILE}"
    exit 0
else
    gzip_status=${PIPESTATUS[0]}
    dump_status=${PIPESTATUS[1]}
    echo "ERROR: Database restore failed (mariadb exit ${dump_status}, gzip exit ${gzip_status})." >&2
    exit 1
fi
