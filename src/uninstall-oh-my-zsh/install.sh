#!/bin/sh
set -e

echo "Activating feature 'uninstall-oh-my-zsh'"

uninstall_if_present() {
    user_name="$1"
    home_dir="$2"

    if [ -z "$home_dir" ] && [ -n "$user_name" ]; then
        if command -v getent >/dev/null 2>&1; then
            home_dir="$(getent passwd "$user_name" | cut -d: -f6)"
        else
            home_dir="$(awk -F: -v user="$user_name" '$1==user {print $6; exit}' /etc/passwd 2>/dev/null)"
        fi
    fi

    if [ -z "$home_dir" ]; then
        return
    fi

    zsh_dir="$home_dir/.oh-my-zsh"

    if [ ! -d "$zsh_dir" ] || [ ! -f "$zsh_dir/tools/uninstall.sh" ]; then
        return
    fi

    echo "Uninstalling Oh My Zsh from '$home_dir'"

    if [ "$user_name" = "root" ] || [ -z "$user_name" ]; then
        command env HOME="$home_dir" ZSH="$zsh_dir" sh -ceu 'yes | head -n1 | sh -eu $ZSH/tools/uninstall.sh'
        return
    fi

    if id -u "$user_name" >/dev/null 2>&1; then
        su "$user_name" -c "env HOME='$home_dir' ZSH='$zsh_dir' sh -ceu 'yes | head -n1 | sh -eu \$ZSH/tools/uninstall.sh'"
    fi
}

uninstall_if_present "root" "/root"
uninstall_if_present "$_CONTAINER_USER" "$_CONTAINER_USER_HOME"
uninstall_if_present "$_REMOTE_USER" "$_REMOTE_USER_HOME"
