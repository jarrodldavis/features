#!/bin/bash

set -e

source dev-container-features-test-lib

check "no home symlink when empty" bash -c '[ ! -L "$HOME/.codex" ]'
check "paths directory exists" bash -c '[ -d /var/lib/devcontainer-state/paths ]'

reportResults
