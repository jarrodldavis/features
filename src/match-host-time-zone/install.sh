#!/bin/sh
set -eu

echo "Preparing /etc/localtime for a host timezone bind mount"

# Debian and other images may link /etc/localtime into /usr/share/zoneinfo.
# Docker follows that symlink when applying the bind mount, overlaying a
# tzdata-managed file and causing package upgrades to fail with EXDEV.
if [ -L /etc/localtime ]; then
    zoneinfo_file="$(readlink -f /etc/localtime)"
    if [ ! -f "$zoneinfo_file" ]; then
        echo "Cannot resolve /etc/localtime to a regular timezone file" >&2
        exit 1
    fi
    cp --remove-destination "$zoneinfo_file" /etc/localtime
fi
