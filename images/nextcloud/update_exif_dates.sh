#!/bin/bash
set -eu

# E.g.
# /mnt/ncdata/alice/files/Pictures/Wonderland/20180717_192103.jpg
ABSOLUTE_PATH=$1

# E.g.
# alice/files/Pictures/Wonderland/20180717_192103.jpg
RELATIVE_PATH=$2

EXIFTOOL_BIN=/usr/bin/exiftool
OCC_BIN=/var/www/html/occ

cd "$(dirname "$(readlink -f "$0")")"

# echo "Updating EXIF Info for: $ABSOLUTE_PATH ($RELATIVE_PATH)" >> "$0".log

# shellcheck disable=SC2016
$EXIFTOOL_BIN '-allDates<${filename;s/-WA.*\./000000./}' '-FileModifyDate<${filename;s/-WA.*\./000000./}' -overwrite_original "$ABSOLUTE_PATH"

$OCC_BIN files:scan --path="$RELATIVE_PATH" --quiet --no-interaction