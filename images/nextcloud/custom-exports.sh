#!/bin/bash

# Use an 'oc_' prefixed database user.
# This is the way nextcloud AIO creates a new user with limited priviledges
# https://github.com/nextcloud/all-in-one/blob/main/Containers/postgresql/init-user-db.sh
#
# When using a DB user without the permission to create roles,
# nextcloud itself does not create a new user with password but uses the supplied one
# https://github.com/nextcloud/server/blob/master/lib/private/Setup/PostgreSQL.php
POSTGRES_USER="oc_$POSTGRES_USER"
export POSTGRES_USER

# export CPU_ARCH which is used by notify_push's run command in supervisord
CPU_ARCH="$(uname -m)"
export CPU_ARCH
if [ -z "$CPU_ARCH" ]; then
    echo "Could not get processor architecture. Exiting."
    exit 1
elif [ "$CPU_ARCH" != "x86_64" ]; then
    export CPU_ARCH="aarch64"
fi