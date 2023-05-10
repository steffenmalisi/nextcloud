#!/bin/bash
set -eu

# Only start container if database is available
# Nextcloud crashed with some strange behaviours if it tries to upgrade but the database is not available
while ! nc -z "$POSTGRES_HOST" 5432; do
    echo "Waiting for database to start..."
    sleep 5
done
echo "Database is available."

# The nextcloud installer does not check if user www-data can write into the directory supplied via NEXTCLOUD_DATA_DIR
# Check for the right permissions
DATA_DIR_PERMISSION="$(stat -c "%a:%U:%G" "$NEXTCLOUD_DATA_DIR")"
if [ "$DATA_DIR_PERMISSION" != "750:www-data:root" ]; then
    echo "Fix current permissions $DATA_DIR_PERMISSION on $NEXTCLOUD_DATA_DIR to 750:www-data:root"
    chown -R www-data:root "$NEXTCLOUD_DATA_DIR"
    chmod 750 -R "$NEXTCLOUD_DATA_DIR"
fi

echo "Sanity checks ok"