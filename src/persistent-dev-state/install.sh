#!/bin/sh
set -e

echo "Activating feature 'persistent-dev-state'"

STATE_ROOT="/var/lib/devcontainer-state"
PERSISTED_PATHS_ROOT="$STATE_ROOT/paths"
REMOTE_HOME="$_REMOTE_USER_HOME"
CONTAINER_HOME="$_CONTAINER_USER_HOME"

ensure_dir() {
    dir="$1"
    mkdir -p "$dir"
}

ensure_writable_dir() {
    dir="$1"
    ensure_dir "$dir"
    chmod 0777 "$dir"
}

trim() {
    printf '%s' "$1" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//'
}

resolve_remote_home() {
    if [ -n "$REMOTE_HOME" ]; then
        return 0
    fi

    if [ -z "$_REMOTE_USER" ]; then
        return 0
    fi

    if command -v getent >/dev/null 2>&1; then
        REMOTE_HOME="$(getent passwd "$_REMOTE_USER" | cut -d: -f6)"
    else
        REMOTE_HOME="$(awk -F: -v user="$_REMOTE_USER" '$1==user {print $6; exit}' /etc/passwd)"
    fi

    if [ -z "$REMOTE_HOME" ] && [ -n "$CONTAINER_HOME" ]; then
        REMOTE_HOME="$CONTAINER_HOME"
    fi

    if [ -z "$REMOTE_HOME" ]; then
        REMOTE_HOME="/root"
    fi
}

normalize_input_path() {
    input_path="$(trim "$1")"

    if [ -z "$input_path" ]; then
        return 1
    fi

    case "$input_path" in
        "~")
            resolve_remote_home
            if [ -z "$REMOTE_HOME" ]; then
                echo "Skipping '~' because remote user home could not be resolved"
                return 1
            fi
            resolved_path="$REMOTE_HOME"
            ;;
        "~/"*)
            resolve_remote_home
            if [ -z "$REMOTE_HOME" ]; then
                echo "Skipping '$input_path' because remote user home could not be resolved"
                return 1
            fi
            resolved_path="$REMOTE_HOME/${input_path#\~/}"
            ;;
        /*)
            resolved_path="$input_path"
            ;;
        *)
            echo "Skipping '$input_path'. Paths must be absolute or start with '~'."
            return 1
            ;;
    esac

    resolved_path="$(printf '%s' "$resolved_path" | sed 's#/*$##')"
    if [ -z "$resolved_path" ]; then
        resolved_path="/"
    fi

    if [ "$resolved_path" = "/" ]; then
        echo "Skipping '/': root path cannot be persisted"
        return 1
    fi

    case "$resolved_path" in
        "$STATE_ROOT"|"$STATE_ROOT"/*)
            echo "Skipping '$resolved_path': path is inside the state volume root"
            return 1
            ;;
    esac

    normalized_path="$resolved_path"
    return 0
}

persist_path() {
    requested_path="$1"

    if ! normalize_input_path "$requested_path"; then
        return 0
    fi

    target_path="$normalized_path"
    state_path="$PERSISTED_PATHS_ROOT/${target_path#/}"

    ensure_dir "$(dirname "$target_path")"
    ensure_writable_dir "$(dirname "$state_path")"

    if [ -L "$target_path" ]; then
        existing_link="$(readlink "$target_path")"
        if [ "$existing_link" = "$state_path" ]; then
            ensure_writable_dir "$state_path"
            return 0
        fi
        rm -f "$target_path"
    elif [ -e "$target_path" ]; then
        if [ ! -e "$state_path" ]; then
            mv "$target_path" "$state_path"
        elif [ -d "$target_path" ] && [ -d "$state_path" ]; then
            cp -a "$target_path"/. "$state_path"/
            rm -rf "$target_path"
        else
            rm -rf "$target_path"
        fi
    fi

    ensure_writable_dir "$state_path"
    ln -s "$state_path" "$target_path"
}

parse_and_persist_paths() {
    raw_paths="${PATHS:-[]}"
    trimmed_paths="$(trim "$raw_paths")"

    if [ -z "$trimmed_paths" ] || [ "$trimmed_paths" = "[]" ]; then
        return 0
    fi

    case "$trimmed_paths" in
        \[*\])
            ;;
        *)
            echo "Skipping paths option because it is not a JSON array string: '$trimmed_paths'"
            return 0
            ;;
    esac

    inner="${trimmed_paths#\[}"
    inner="${inner%\]}"
    inner_no_quotes="$(printf '%s' "$inner" | tr -d '\"')"

    if [ -z "$(printf '%s' "$inner_no_quotes" | tr -d '[:space:]')" ]; then
        return 0
    fi

    OLD_IFS="$IFS"
    IFS=','
    for token in $inner_no_quotes; do
        persist_path "$(trim "$token")"
    done
    IFS="$OLD_IFS"
}

ensure_writable_dir "$STATE_ROOT"
ensure_writable_dir "$PERSISTED_PATHS_ROOT"

parse_and_persist_paths
