#!/bin/bash

set -e

source dev-container-features-test-lib

check "remote codex symlink" bash -c '[ -L /home/octocat/.codex ]'
check "additional .npm symlink" bash -c '[ -L /home/octocat/.npm ]'
check "additional pnpm store symlink" bash -c '[ -L /home/octocat/.local/share/pnpm/store ]'
check "state writable by remote user" bash -c 'su - octocat -c "touch /var/lib/devcontainer-state/codex/remote-write-test"'

reportResults
