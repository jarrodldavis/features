#!/bin/bash

set -e

source dev-container-features-test-lib

check "state root env" bash -c '[ "$PERSISTENT_DEV_STATE_ROOT" = "/var/lib/devcontainer-state" ]'
check "state root writable" bash -c 'touch /var/lib/devcontainer-state/.test-write'
check "no default codex symlink" bash -c '[ ! -L "$HOME/.codex" ]'

reportResults
