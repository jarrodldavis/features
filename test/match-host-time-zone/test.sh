#!/bin/bash
set -euo pipefail

test -f /usr/local/share/host-localtime
test "$(readlink /etc/localtime)" = /usr/local/share/host-localtime
cmp /etc/localtime /usr/local/share/host-localtime

# Reinstalling tzdata exercises its real post-installation script and the
# apt hook. The resulting /etc/localtime must still follow the host.
if command -v apt-get >/dev/null 2>&1 && dpkg-query -W tzdata >/dev/null 2>&1; then
    apt-get update
    DEBIAN_FRONTEND=noninteractive apt-get install -y --reinstall tzdata
    test "$(readlink /etc/localtime)" = /usr/local/share/host-localtime
    cmp /etc/localtime /usr/local/share/host-localtime
fi
echo "Host timezone survived tzdata reinstall"
