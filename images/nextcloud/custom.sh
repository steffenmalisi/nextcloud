#!/bin/bash
set -u

##############################################################################################
#                                  FUNCTION DECLARATION                                      #
##############################################################################################

# installOrRemoveApp app
# Param:
#     app - the app to install or remove. If prefixed with a '-' the app gets disabled, otherwise installed and enabled
function installOrRemoveApp {
  app=$1
  if ! echo "$app" | grep -q '^-'; then
    if [ -z "$(find /var/www/html/apps -type d -maxdepth 1 -mindepth 1 -name "$app" )" ]; then
      # If not shipped, install and enable the app
      php /var/www/html/occ app:install "$app"
    else
      # If shipped, enable the app
      php /var/www/html/occ app:enable "$app"
    fi
  else
    app="${app#-}"
    # Disable the app if prefixed with '-'
    php /var/www/html/occ app:disable "$app"
  fi
}

##############################################################################################
#                                         MAIN LOGIC                                         #
##############################################################################################

## Use a simple file flag to check if this script ran successfully already
## If so, do not repeat it on each start
if ! [ -f "$NEXTCLOUD_DATA_DIR/mal1s1-nc.install.done" ]; then

  # admin_audit?
  ADDITIONAL_APPS="calendar contacts facerecognition memories notify_push previewgenerator recognize tasks twofactor_totp -circles -contactsinteraction -dashboard -federation -privacy -support -survey_client -user_ldap -user_status -weather_status"

  read -ra ADDITIONAL_APPS_ARRAY <<< "$ADDITIONAL_APPS"
  for app in "${ADDITIONAL_APPS_ARRAY[@]}"; do
    installOrRemoveApp "$app"
  done

  # facerecognition
  php /var/www/html/occ face:setup -M 2G
  php /var/www/html/occ face:setup -m 1
  php /var/www/html/occ face:setup -m 3
  php /var/www/html/occ face:setup -m 4
  php /var/www/html/occ config:app:set facerecognition analysis_image_area --value="2096400"
  # hint: a cronjob is set up in the Dockerfile to run facerecognition every 30 mins

  # imaginary
  if [ -n "${IMAGINARY_HOST+x}" ]; then
    php /var/www/html/occ config:system:delete enabledPreviewProviders
    php /var/www/html/occ config:system:set enabledPreviewProviders 0 --value="OC\\Preview\\Imaginary"
    php /var/www/html/occ config:system:set enabledPreviewProviders 1 --value="OC\\Preview\\Movie"
    php /var/www/html/occ config:system:set preview_imaginary_url --value="http://$IMAGINARY_HOST"
  fi

  # notify_push
  php /var/www/html/occ config:app:set notify_push base_endpoint --value="https://$SERVER_DOMAIN/push"

  # nextcloud server info token used for nextcloud prometheus exporter
  php /var/www/html/occ config:app:set serverinfo token --value="${NEXTCLOUD_SERVERINFO_TOKEN}"

  # previewgenerator
  php /var/www/html/occ config:system:set preview_max_x --value="2048"
  php /var/www/html/occ config:system:set preview_max_y --value="2048"
  # php /var/www/html/occ preview:generate-all # This may take a long time, so it's better the user does it after first start
  # hint: a cronjob is set up in the Dockerfile to run pre-generation of previews every 10 mins

  # recognize
  php /var/www/html/occ recognize:download-models

  # memories
  php /var/www/html/occ memories:index
  yes | php /var/www/html/occ memories:video-setup

  # additional customizations
  #php /var/www/html/occ config:system:set upgrade.disable-web --type=bool --value=true
  #php /var/www/html/occ config:system:set trashbin_retention_obligation --value="auto, 30"
  #php /var/www/html/occ config:system:set versions_retention_obligation --value="auto, 30"
  #php /var/www/html/occ config:system:set activity_expire_days --value="30"
  #php /var/www/html/occ config:system:set simpleSignUpLink.shown --type=bool --value=false
  #php /var/www/html/occ config:system:set share_folder --value="/Shared"


  touch "$NEXTCLOUD_DATA_DIR/mal1s1-nc.install.done"
else
  echo "Initialization already done once. Initialization will only run again if you delete the file at $NEXTCLOUD_DATA_DIR/mal1s1-nc.install.done"
fi