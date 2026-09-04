#!/bin/sh
set -eu

state_root=/var/lib/devcontainer-persistent-home

fail() {
    echo "persistent-home: $*" >&2
    exit 1
}

uid=$(id -u)
gid=$(id -g)
owner=$(stat -c '%u:%g' "$state_root") || fail "unable to determine ownership of persistent volume"

[ "$owner" = "$uid:$gid" ] && exit 0

if [ "$uid" -eq 0 ]; then
    chown -R "$uid:$gid" "$state_root"
elif command -v sudo >/dev/null 2>&1; then
    sudo -n chown -R "$uid:$gid" "$state_root" || fail "passwordless sudo is required to correct persistent volume ownership"
else
    fail "passwordless sudo is required to correct persistent volume ownership"
fi
