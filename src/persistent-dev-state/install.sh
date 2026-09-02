#!/bin/sh
set -e

echo "Activating feature 'persistent-dev-state'"

STATE_ROOT="/var/lib/devcontainer-state"
HOME_STATE_ROOT="$STATE_ROOT/home"
CODEX_STATE_DIR="$STATE_ROOT/codex"

ensure_dir() {
    dir="$1"
    mkdir -p "$dir"
}

persist_home_dir() {
    relative_path="$1"

    trimmed_path="$(printf '%s' "$relative_path" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
    if [ -z "$trimmed_path" ]; then
        return 0
    fi

    case "$trimmed_path" in
        /*)
            echo "Skipping absolute path '$trimmed_path' in additionalHomeDirs"
            return 0
            ;;
    esac

    home_target="$_REMOTE_USER_HOME/$trimmed_path"
    state_target="$HOME_STATE_ROOT/$trimmed_path"

    ensure_dir "$(dirname "$home_target")"
    ensure_dir "$(dirname "$state_target")"

    if [ -L "$home_target" ]; then
        existing_link="$(readlink "$home_target")"
        if [ "$existing_link" = "$state_target" ]; then
            ensure_dir "$state_target"
            return 0
        fi
        rm -f "$home_target"
    elif [ -e "$home_target" ]; then
        if [ ! -e "$state_target" ]; then
            mv "$home_target" "$state_target"
        elif [ -d "$home_target" ] && [ -d "$state_target" ]; then
            cp -a "$home_target"/. "$state_target"/
            rm -rf "$home_target"
        else
            rm -rf "$home_target"
        fi
    fi

    ensure_dir "$state_target"
    ln -s "$state_target" "$home_target"
}

ensure_dir "$STATE_ROOT"
ensure_dir "$HOME_STATE_ROOT"
ensure_dir "$CODEX_STATE_DIR"

persist_home_dir ".codex"

if [ "${PERSISTVSCODEEXTENSIONS}" = "true" ]; then
    persist_home_dir ".vscode-server/extensions"
fi

if [ -n "${ADDITIONALHOMEDIRS}" ]; then
    OLD_IFS="$IFS"
    IFS=','
    for entry in $ADDITIONALHOMEDIRS; do
        persist_home_dir "$entry"
    done
    IFS="$OLD_IFS"
fi

if [ -n "$_REMOTE_USER" ] && id -u "$_REMOTE_USER" >/dev/null 2>&1; then
    remote_group="$(id -gn "$_REMOTE_USER")"
    chown -R "$_REMOTE_USER:$remote_group" "$STATE_ROOT"
fi
