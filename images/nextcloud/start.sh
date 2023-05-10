#!/bin/bash
set -eu

# shellcheck disable=SC1091
. /custom-exports.sh

echo "****************************************************************"
echo "*                       Sanity checks                          *"
echo "****************************************************************"

/sanity.sh;

echo "****************************************************************"
echo "*                 Starting mal1s1 nextcloud                    *"
echo "****************************************************************"

# Invoke the original nextcloud entrypoint
/entrypoint.sh "$1";

echo "****************************************************************"
echo "* Finished nextcloud setup. Start to execute custom extensions *"
echo "****************************************************************"

su -p www-data -s /bin/sh -c "/custom.sh";

echo "****************************************************************"
echo "*                      Done. Enjoy!!!                          *"
echo "****************************************************************"

exec "$@"