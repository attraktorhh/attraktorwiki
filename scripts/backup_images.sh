#!/bin/bash
# Backup MediaWiki images directory with retry logic and robust error handling.
set -o pipefail

# Allow override via env vars
IMAGEPATH="${IMAGEPATH:-/var/www/html/images}"
BACKUP_DIR="${BACKUP_DIR:-/mnt/backups}"
RETRIES="${BACKUP_RETRIES:-3}"          # Number of attempts
RETRY_DELAY="${BACKUP_RETRY_DELAY:-2}"   # Seconds between attempts

OUTFILE="${BACKUP_DIR}/attraktorwiki.images.tar.gz"
TMPFILE="${OUTFILE}.tmp"
ERRFILE="${OUTFILE}.err"

# Basic validation
if [ ! -d "${IMAGEPATH}" ]; then
    echo "ERROR: Image path does not exist: ${IMAGEPATH}" >&2
    exit 2
fi
if [ ! -r "${IMAGEPATH}" ]; then
    echo "ERROR: Image path not readable: ${IMAGEPATH}" >&2
    exit 3
fi
if [ ! -d "${BACKUP_DIR}" ]; then
    if ! mkdir -p "${BACKUP_DIR}"; then
        echo "ERROR: Cannot create backup directory: ${BACKUP_DIR}" >&2
        exit 4
    fi
fi
if [ ! -w "${BACKUP_DIR}" ]; then
    echo "ERROR: Backup directory not writable: ${BACKUP_DIR}" >&2
    exit 5
fi

echo "Backing up images from '${IMAGEPATH}' to '${OUTFILE}' (retries: ${RETRIES}, delay: ${RETRY_DELAY}s)..."

attempt=1
while [ "${attempt}" -le "${RETRIES}" ]; do
    # Clean any previous temp artifacts
    rm -f "${TMPFILE}" "${ERRFILE}"

    # Perform archive into a temp file to avoid leaving a partial final file
    if tar -czf "${TMPFILE}" -C "${IMAGEPATH}" . 2>"${ERRFILE}"; then
        mv "${TMPFILE}" "${OUTFILE}"
        rm -f "${ERRFILE}"
        echo "Image backup completed: ${OUTFILE}"
        exit 0
    else
        status=$?
        echo "Attempt ${attempt}/${RETRIES} failed (exit ${status})." >&2
        # Show last few lines of error for context
        if [ -s "${ERRFILE}" ]; then
            echo "--- tar error (tail) ---" >&2
            tail -n 5 "${ERRFILE}" >&2
            echo "------------------------" >&2
        fi
        rm -f "${TMPFILE}" 2>/dev/null || true
        if [ "${attempt}" -lt "${RETRIES}" ]; then
            echo "Retrying in ${RETRY_DELAY}s..." >&2
            sleep "${RETRY_DELAY}"
        fi
    fi
    attempt=$((attempt + 1))
done

# Final failure cleanup
rm -f "${TMPFILE}" "${OUTFILE}" 2>/dev/null || true
echo "ERROR: Image backup failed after ${RETRIES} attempts." >&2
if [ -s "${ERRFILE}" ]; then
    echo "Final error output:" >&2
    cat "${ERRFILE}" >&2
fi
rm -f "${ERRFILE}" 2>/dev/null || true
exit 1
