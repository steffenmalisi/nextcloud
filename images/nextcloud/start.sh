#!/bin/bash
set -eu

echo "****************************************************************"
echo "*                       Sanity checks                          *"
echo "****************************************************************"

/sanity.sh;
echo "Sanity checks ok"

echo "****************************************************************"
echo "*                 Starting mal1s1 nextcloud                    *"
echo "****************************************************************"

/entrypoint.sh "$1";

echo "****************************************************************"
echo "* Finished nextcloud setup. Start to execute custom extensions *"
echo "****************************************************************"

su -p www-data -s /bin/sh -c "/custom.sh";

echo "****************************************************************"
echo "*                      Done. Enjoy!!!                          *"
echo "****************************************************************"

# export CPU_ARCH which is used by notify_push's run command in supervisord
CPU_ARCH="$(uname -m)"
export CPU_ARCH
if [ -z "$CPU_ARCH" ]; then
    echo "Could not get processor architecture. Exiting."
    exit 1
elif [ "$CPU_ARCH" != "x86_64" ]; then
    export CPU_ARCH="aarch64"
fi

exec "$@"