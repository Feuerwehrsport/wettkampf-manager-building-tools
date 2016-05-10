#!/bin/bash

CONFIG_FILE=/home/georf/.wettkampf-manager-config

if [ ! -f "$CONFIG_FILE" ] ; then exit 1 ; fi

source "$CONFIG_FILE"

/home/georf/wettkampf-manager-building-tools/package_builder/build.sh -v "$VERSION" -g "$GIT_COMMIT_ID" -d "$DATE" -c "$CHANGE_FILE" -f