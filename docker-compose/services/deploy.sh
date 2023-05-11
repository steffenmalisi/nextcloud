#!/bin/bash
set -eu

function generate_password {
  openssl rand -base64 32 | sed -e '$s/[]\/$*.^[]/\\&/g';
}

# generate secrets
# docker secrets https://docs.docker.com/compose/compose-file/compose-file-v3/#secrets
# are not used intentionally because of https://github.com/docker/compose/issues/9648
# without being able to set the right permissions independent of the host, it's less secure then the .env file
if ! [ -e .env ]; then
  sed -e "s/<NEXTCLOUD_ADMIN_PASSWORD>/\"$(generate_password)\"/g" .env.template \
    | sed -e "s/<NEXTCLOUD_SERVERINFO_TOKEN>/\"$(generate_password)\"/g" \
    | sed -e "s/<POSTGRES_PASSWORD>/\"$(generate_password)\"/g" \
    | sed -e "s/<REDIS_PASSWORD>/\"$(openssl rand -hex 32)\"/g" \
    | sed -e "s/<GRAFANA_ADMIN_PASSWORD>/\"$(generate_password)\"/g" \
    > .env
  chmod 400 .env
fi

docker compose build
docker compose up -d