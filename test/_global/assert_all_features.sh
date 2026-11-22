#!/bin/bash

set -e

source dev-container-features-test-lib

localhost_resolves_to_ipv4_first() {
    local addresses first_address
    addresses=$(getent ahosts localhost) || return
    read -r first_address _ <<< "$addresses"
    test "$first_address" = 127.0.0.1
}

check "localtime points to host time zone" test "$(readlink /etc/localtime)" = /usr/local/share/host-localtime
check "localtime matches host time zone" cmp /etc/localtime /usr/local/share/host-localtime
check "Oh My Zsh directory removed" bash -c '[ ! -d "$HOME/.oh-my-zsh" ]'
check "IPv4 loopback precedence is active" grep -Eq '^[[:space:]]*precedence[[:space:]]+::ffff:127\.0\.0\.0/104[[:space:]]+100([[:space:]]|$)' /etc/gai.conf
check "localhost resolves to IPv4 first" localhost_resolves_to_ipv4_first

reportResults
