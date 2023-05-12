#!/bin/bash
set -eu

function generate_password {
  openssl rand -hex 32;
}

# copy config
cp -r config /var/config

# generate nextcloud secrets
if ! [ -e /etc/sysconfig/nextcloud ]; then
  sed -e "s/<NEXTCLOUD_ADMIN_PASSWORD>/\"$(generate_password)\"/g" services/nextcloud/.env.template \
    | sed -e "s/<NEXTCLOUD_SERVERINFO_TOKEN>/\"$(generate_password)\"/g" \
    | sed -e "s/<POSTGRES_PASSWORD>/\"$(generate_password)\"/g" \
    | sed -e "s/<REDIS_PASSWORD>/\"$(generate_password)\"/g" \
    | sed -e "s/<GRAFANA_ADMIN_PASSWORD>/\"$(generate_password)\"/g" \
    > /etc/sysconfig/nextcloud
  chmod 400 /etc/sysconfig/nextcloud
fi

# generate monitoring secrets
if ! [ -e /etc/sysconfig/monitoring ]; then
  sed -e "s/<GRAFANA_ADMIN_PASSWORD>/\"$(generate_password)\"/g" services/monitoring/.env.template \
    > /etc/sysconfig/monitoring
  chmod 400 /etc/sysconfig/monitoring
fi

# deploy nextcloud
cp services/nextcloud/*.service /etc/systemd/system/

# deploy monitoring
cp services/monitoring/*.service /etc/systemd/system/