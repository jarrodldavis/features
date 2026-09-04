#!/bin/sh
set -eu

state_root=/var/lib/devcontainer-persistent-home
on_create=/usr/local/bin/devcontainer-persistent-home-on-create

fail() {
    echo "persistent-home: $*" >&2
    exit 1
}

home=${_REMOTE_USER_HOME:-}
user=${_REMOTE_USER:-}

if [ -z "$home" ] || [ -z "$user" ]; then
    fail "unable to determine the remote user and home directory"
fi

uid=$(id -u "$user") || fail "unable to resolve remote user: $user"
gid=$(id -g "$user") || fail "unable to resolve remote user: $user"

ensure_parent() {
    path=$1
    parent=${path%/*}

    [ "$parent" != "$path" ] || return 0

    current=$home
    parent_ifs=$IFS
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

    IFS=$parent_ifs
}

paths=
old_ifs=$IFS
IFS=:
set -f

for path in ${PATHS:-}; do
    [ -n "$path" ] || continue

    case "$path" in
        /* | "~" | "~"/* | . | .. | ./* | ../* | */. | */.. | */./* | */../* | */ | *//*)
            fail "invalid path: $path"
            ;;
    esac

    duplicate=false
    for existing in $paths; do
        if [ "$path" = "$existing" ]; then
            duplicate=true
            break
        fi

        case "$path" in
            "$existing"/*)
                fail "paths overlap: $existing and $path"
                ;;
        esac
        case "$existing" in
            "$path"/*)
                fail "paths overlap: $path and $existing"
                ;;
        esac
    done

    [ "$duplicate" = true ] && continue

    if [ -z "$paths" ]; then
        paths=$path
    else
        paths=$paths:$path
    fi
done

mkdir -p "$state_root"

for path in $paths; do
    source=$home/$path
    target=$state_root/$path

    ensure_parent "$path"
    mkdir -p "${target%/*}"

    if [ -L "$source" ]; then
        link=$(readlink "$source")
        [ "$link" = "$target" ] || fail "path is already a symlink: $source -> $link"

        if [ ! -e "$target" ]; then
            mkdir "$target"
            chown "$uid:$gid" "$target"
        else
            [ -d "$target" ] || fail "persistent target is not a directory: $target"
        fi
        continue
    fi

    [ ! -e "$target" ] || fail "persistent target already exists: $target"

    if [ -e "$source" ]; then
        [ -d "$source" ] || fail "path is not a directory: $source"
        mv "$source" "$target"
    else
        mkdir "$target"
        chown "$uid:$gid" "$target"
    fi

    ln -s "$target" "$source"
done

mkdir -p "${on_create%/*}"
cp "$(dirname "$0")/on-create.sh" "$on_create"
chmod 0755 "$on_create"

set +f
IFS=$old_ifs
