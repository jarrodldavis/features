#!/bin/bash

set -e

source dev-container-features-test-lib

check "localtime points to host time zone" test "$(readlink /etc/localtime)" = /usr/local/share/host-localtime
check "localtime matches host time zone" cmp /etc/localtime /usr/local/share/host-localtime
check "Oh My Zsh directory removed" bash -c '[ ! -d "$HOME/.oh-my-zsh" ]'

reportResults
