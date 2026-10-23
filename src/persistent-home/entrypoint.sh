#!/bin/sh
set -eu

state_root=/var/lib/devcontainer-persistent-home
config=/etc/devcontainer-persistent-home.conf

if [ -f "$config" ] && [ -d "$state_root" ]; then
    owner=$(sed -n '1p' "$config")
    paths=$(sed -n '2p' "$config")

    old_ifs=$IFS
    IFS=:
    set -f

    for path in $paths; do
        [ -n "$path" ] || continue
        target=$state_root/$path

        # A mounted, previously existing volume may not contain paths
        # introduced by a newer image. Create them before VS Code connects.
        [ -L "$target" ] && { echo "persistent-home: symlink target: $target" >&2; exit 1; }
        if [ -e "$target" ]; then
            [ -d "$target" ] || { echo "persistent-home: target is not a directory: $target" >&2; exit 1; }
        else
            mkdir -p "$target"
            chown -R "$owner" "$target"
        fi
    done

    IFS=$old_ifs
    set +f
fi

exec "$@"
