#!/bin/bash
set -eu

SCRIPT_PATH="$(cd "$(dirname "$0")" && pwd)"

OVERWRITE=1
if [[ -f "$SCRIPT_PATH/wettkampf-manager/db/production.sqlite3" ]] ; then
  OVERWRITE=0
  
  echo -n "Es existiert bereits eine Datenbank. Soll diese Überschrieben werden? [j/n] "
  read REPLY
  if [[ "$REPLY" =~ ^[YyJj]$ ]] ; then
    OVERWRITE=1
    rm -rf "$SCRIPT_PATH/wettkampf-manager/db/production.sqlite3"
  fi
fi

$SCRIPT_PATH/lib/wrapper.sh rake assets:precompile
$SCRIPT_PATH/lib/wrapper.sh rake db:migrate

if [[ OVERWRITE -eq 1 ]] ; then
  $SCRIPT_PATH/lib/wrapper.sh rake db:seed
  $SCRIPT_PATH/lib/wrapper.sh rake import_suggestions
fi