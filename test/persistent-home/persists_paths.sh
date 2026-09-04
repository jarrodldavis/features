#!/bin/bash

set -e

source dev-container-features-test-lib

home=/home/vscode
state_root=/var/lib/devcontainer-persistent-home

check "top-level path is a symlink" test -L "$home/.codex"
check "top-level path points into the volume" bash -c "[ \"\$(readlink '$home/.codex')\" = '$state_root/.codex' ]"
check "nested path is a symlink" test -L "$home/.local/share/example"
check "nested path points into the volume" bash -c \
    "[ \"\$(readlink '$home/.local/share/example')\" = '$state_root/.local/share/example' ]"
check "existing state is migrated" bash -c "[ \"\$(cat '$home/.codex/existing')\" = existing ]"
check "volume ownership matches remote user" bash -c \
    "[ \"\$(stat -c %u '$state_root')\" = \"\$(id -u vscode)\" ]"
check "remote user can write persistent state" sudo -u vscode sh -c \
    "printf persisted > '$home/.codex/new' && [ \"\$(cat '$state_root/.codex/new')\" = persisted ]"

reportResults
