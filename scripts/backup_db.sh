#!/bin/bash
# Safely back up a MariaDB database with error handling.
set -o pipefail

echo "Backing up database '${MYSQL_DATABASE}'..."

OUTFILE="/mnt/backups/${MYSQL_DATABASE}.sql.gz"

if mariadb-dump \
    -u "${MYSQL_USER}" \
    -h "${MYSQL_HOST}" \
    -p"${MYSQL_PASSWORD}" \
    "${MYSQL_DATABASE}" \
    --default-character-set=binary \
    --single-transaction | gzip > "${OUTFILE}"; 
then
    echo "Database backup completed: ${OUTFILE}"
    exit 0
else
    dump_status=${PIPESTATUS[0]}
    gzip_status=${PIPESTATUS[1]}
    # Remove incomplete/corrupt file if gzip or dump failed
    [ -f "${OUTFILE}" ] && rm -f "${OUTFILE}"
    echo "ERROR: Database backup failed (mariadb-dump exit ${dump_status}, gzip exit ${gzip_status})." >&2
    exit 1
fi
