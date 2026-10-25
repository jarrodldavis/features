#!/bin/sh
set -eu

state_root=/var/lib/devcontainer-persistent-home
on_create=/usr/local/bin/devcontainer-persistent-home-on-create
entrypoint=/usr/local/bin/devcontainer-persistent-home-entrypoint
config=/etc/devcontainer-persistent-home.conf

fail() {
    echo "persistent-home: $*" >&2
    exit 1
}

home=${_REMOTE_USER_HOME:-}
user=${_REMOTE_USER:-}
[ -n "$home" ] && [ -n "$user" ] || fail "unable to determine the remote user and home directory"
uid=$(id -u "$user") || fail "unable to resolve remote user: $user"
gid=$(id -g "$user") || fail "unable to resolve remote user: $user"

# Entries are stored as type|path records (one per line); paths cannot contain
# newlines, colons, or pipes, so both config and shell iteration are unambiguous.
entries=
add_path() {
    type=$1
    path=$2
    [ -n "$path" ] || return 0
    case "$path" in
        /* | "~" | "~"/* | . | .. | ./* | ../* | */. | */.. | */./* | */../* | */ | *//* | *'|'* | *'
'* | *':'*)
            fail "invalid path: $path" ;;
    esac
    old_ifs=$IFS
    IFS='
'
    for record in $entries; do
        existing=${record#*|}
        if [ "$path" = "$existing" ]; then
            IFS=$old_ifs
            return 0
        fi
        case "$path" in "$existing"/*) fail "paths overlap: $existing and $path" ;; esac
        case "$existing" in "$path"/*) fail "paths overlap: $path and $existing" ;; esac
    done
    IFS=$old_ifs
    if [ -n "$entries" ]; then entries="$entries
$type|$path"; else entries="$type|$path"; fi
}

# Backward compatible: arbitrary paths are still colon-separated, and entries
# that do not yet exist are treated as directories.
old_ifs=$IFS
IFS=:
set -f
for path in ${PATHS:-}; do
    [ -n "$path" ] || continue
    if [ -f "$home/$path" ]; then add_path f "$path"; else add_path d "$path"; fi
done
IFS=$old_ifs

case "${CODEX:-false}" in true) add_path d .codex ;; esac
case "${GITHUBCOPILOT:-false}" in
    true)
        add_path d .copilot
        add_path d .vscode-server/data/agentSessionData
        add_path f .vscode-server/data/User/globalStorage/agent-host.db
        add_path f .vscode-server/data/User/globalStorage/agent-host-config.json
        add_path f .vscode-server/data/User/globalStorage/agent-host-storage.json
        add_path f .vscode-server/data/User/globalStorage/agent-host.db-wal
        add_path f .vscode-server/data/User/globalStorage/agent-host.db-shm
        add_path d .vscode-server/data/User/globalStorage/github.copilot-chat
        ;;
esac

ensure_parent() {
    path=$1
    parent=${path%/*}
    [ "$parent" != "$path" ] || return 0
    current=$home
    old_ifs=$IFS
    IFS=/
    for component in $parent; do
        current=$current/$component
        if [ -L "$current" ]; then
            fail "parent path is a symlink: $current"
        elif [ -e "$current" ]; then
            [ -d "$current" ] || fail "parent path is not a directory: $current"
        else
            mkdir "$current"
            chown "$uid:$gid" "$current"
        fi
    done
    IFS=$old_ifs
}

mkdir -p "$state_root"
IFS='
'
for record in $entries; do
    type=${record%%|*}
    path=${record#*|}
    source=$home/$path
    target=$state_root/$path
    ensure_parent "$path"
    mkdir -p "${target%/*}"

    if [ -L "$source" ]; then
        link=$(readlink "$source")
        [ "$link" = "$target" ] || fail "path is already a symlink: $source -> $link"
        [ -e "$target" ] || fail "persistent target missing: $target"
        continue
    fi

    # Existing volume data takes precedence on rebuilt containers.
    if [ -e "$target" ]; then
        [ ! -e "$source" ] || fail "both source and persistent target exist: $source"
    elif [ -e "$source" ]; then
        if [ "$type" = d ]; then [ -d "$source" ] || fail "path is not a directory: $source"
        else [ -f "$source" ] || fail "path is not a regular file: $source"; fi
        mv "$source" "$target"
    elif [ "$type" = d ]; then
        mkdir "$target"
        chown "$uid:$gid" "$target"
    else
        : > "$target"
        chown "$uid:$gid" "$target"
    fi
    ln -s "$target" "$source"
done
IFS=$old_ifs
set +f

# Store a line-oriented manifest, with the owner on the first line.
{ printf '%s\n' "$uid:$gid"; printf '%s\n' "$entries"; } > "$config"
chmod 0644 "$config"
mkdir -p "${on_create%/*}"
cp "$(dirname "$0")/entrypoint.sh" "$entrypoint"
chmod 0755 "$entrypoint"
cp "$(dirname "$0")/on-create.sh" "$on_create"
chmod 0755 "$on_create"
