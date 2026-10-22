#!/bin/bash
set -e

test -f /usr/local/share/host-localtime
test ! -L /usr/local/share/host-localtime
test "$TZ" = ":/usr/local/share/host-localtime"
echo "Host timezone mount target and TZ configured"
