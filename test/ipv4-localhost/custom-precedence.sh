#!/bin/bash
set -euo pipefail

printf '%s\n' 'precedence ::ffff:0:0/96 90' 'precedence ::/0 40' > /etc/gai.conf
cp /etc/gai.conf /tmp/gai.conf.before

installer="$(dirname "$0")/.devcontainer/ipv4-localhost/install.sh"
if sh "$installer" > /tmp/install.log 2>&1; then
    echo "Installation unexpectedly accepted the custom precedence table." >&2
    exit 1
fi

grep -F '/etc/gai.conf already contains active precedence rules.' /tmp/install.log
cmp /tmp/gai.conf.before /etc/gai.conf
