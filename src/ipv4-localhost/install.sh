#!/bin/sh
set -eu

fail() {
    echo "ipv4-localhost: $*" >&2
    exit 1
}

[ "$(id -u)" = 0 ] || fail "Installation requires root."

case "$(getconf GNU_LIBC_VERSION 2>/dev/null || true)" in
    glibc\ *) ;;
    *) fail "A glibc-based image is required, such as Debian or Ubuntu." ;;
esac

gai_conf=/etc/gai.conf

# An explicit rule replaces glibc's entire precedence table, so include
# the five defaults from gai.conf(5) alongside the IPv4 loopback rule.
precedence_table='precedence ::1/128 50
precedence ::/0 40
precedence 2002::/16 30
precedence ::/96 20
precedence ::ffff:0:0/96 10
precedence ::ffff:127.0.0.0/104 100'

if [ -e "$gai_conf" ] || [ -L "$gai_conf" ]; then
    [ -f "$gai_conf" ] || fail "$gai_conf must be a regular file."
    active_rules=$(awk '
        { sub(/#.*/, "") }
        $1 == "precedence" {
            $1 = $1
            print
        }
    ' "$gai_conf") || fail "Could not read $gai_conf."

    if [ "$active_rules" = "$precedence_table" ]; then
        exit 0
    fi
    [ -z "$active_rules" ] || fail "$gai_conf already contains active precedence rules."
fi

printf '\n# Prefer IPv4 loopback while preserving the glibc defaults.\n%s\n' "$precedence_table" >> "$gai_conf"
