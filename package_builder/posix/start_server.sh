#!/bin/bash
set -eu

SCRIPT_PATH="$(cd "$(dirname "$0")" && pwd)"

echo "Server starten"
echo "Zum Beenden bitte STRG + C drücken"
echo "Zum Beenden bitte STRG + C drücken"
echo "Zum Beenden bitte STRG + C drücken"

$SCRIPT_PATH/lib/wrapper.sh rails s -b 0.0.0.0
