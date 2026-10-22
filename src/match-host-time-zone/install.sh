#!/bin/sh
set -eu

echo "Preparing separate host timezone mount target"

# tzdata must be free to replace /etc/localtime during package upgrades.
# Mount the host zoneinfo file elsewhere and select it using TZ instead.
touch /usr/local/share/host-localtime
