#!/bin/sh
set -eu
state_root=/var/lib/devcontainer-persistent-home
config=/etc/devcontainer-persistent-home.conf
if [ -f "$config" ] && [ -d "$state_root" ]; then
    owner=$(sed -n '1p' "$config")
    # File entries may not have existed when the image was built.
    sed '1d' "$config" | while IFS='|' read -r type path; do
        [ -n "$path" ] || continue
        target=$state_root/$path
        if [ -L "$target" ]; then
            echo "persistent-home: symlink target: $target" >&2
            exit 1
        fi
        if [ -e "$target" ]; then
            if [ "$type" = d ]; then test -d "$target"
            else test -f "$target"; fi || exit 1
        else
            mkdir -p "${target%/*}"
            if [ "$type" = d ]; then mkdir "$target"; else : > "$target"; fi
            chown "$owner" "$target"
        fi
    done
fi
exec "$@"
