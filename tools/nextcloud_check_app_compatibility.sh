#!/bin/bash
set -eu

DOCKERFILE=$1
APPS=$2
PLATFORM=$(grep -m 1 'FROM nextcloud' "$DOCKERFILE"  | awk -F ':' '{print $2}' | awk -F '-' '{print $1}')
APP_IDS=$(curl -s https://apps.nextcloud.com/api/v1/platform/"$PLATFORM"/apps.json | jq -r '.[].id')
COMPATIBLE=true

read -ra APPS_ARRAY <<< "$APPS"
for app in "${APPS_ARRAY[@]}"; do
  if ! grep -q "$app" <<< "$APP_IDS"; then
    echo "$app is not compatible with $PLATFORM"
    COMPATIBLE=false
  fi
done

if [ "$COMPATIBLE" = false ]; then
  exit 1
else
  echo "All apps are compatible with $PLATFORM"
fi

