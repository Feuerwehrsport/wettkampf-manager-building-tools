#!/bin/bash
set -eu

SCRIPT_PATH="$(cd "$(dirname "$0")" && pwd)"

export PATH="$PATH:$SCRIPT_PATH/node/bin"
export BUNDLE_GEMFILE="$SCRIPT_PATH/vendor/Gemfile"
unset BUNDLE_IGNORE_CONFIG

export RAILS_ENV=production

pushd $SCRIPT_PATH/../wettkampf-manager > /dev/null
exec "$SCRIPT_PATH/ruby/bin/ruby" "$SCRIPT_PATH/../wettkampf-manager/bin/$1" "${@:2}"