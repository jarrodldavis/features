#!/bin/bash

set -e

source dev-container-features-test-lib

check "codex home env" bash -c '[ "$CODEX_HOME" = "/var/lib/devcontainer-state/codex" ]'
check "codex home writable" bash -c 'mkdir -p "$CODEX_HOME" && touch "$CODEX_HOME/.test-write"'
check "vscode extensions symlink" bash -c '[ -L "$HOME/.vscode-server/extensions" ]'

reportResults
