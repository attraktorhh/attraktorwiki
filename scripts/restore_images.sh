#!/bin/bash
# Safely back up a MariaDB database with error handling.
set -o pipefail

INFILE="/mnt/backups/attraktorwiki.images.tar.gz"

echo "Restoring images from '${INFILE}'..."

if tar -xvzf "${INFILE}" -C /var/www/html/images && \
    chown -R www-data:www-data /var/www/html/images; 
then
    echo "Images restore completed: ${INFILE}"
    exit 0
else
    echo "ERROR: Images restore failed."
    exit 1
fi
