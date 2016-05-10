#!/bin/bash
set -eu

SCRIPT_PATH="$(cd "$(dirname "$0")" && pwd)"

echo "Console starten"

$SCRIPT_PATH/lib/wrapper.sh rails c
