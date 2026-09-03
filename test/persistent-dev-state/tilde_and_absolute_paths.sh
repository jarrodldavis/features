#!/bin/bash

set -e

source dev-container-features-test-lib

check "tilde path expanded and linked" bash -c '[ -L /home/vscode/.codex ] || [ -L /root/.codex ]'
check "second tilde path linked" bash -c '[ -L /home/vscode/.npm ] || [ -L /root/.npm ]'
check "absolute path linked" bash -c '[ -L /usr/local/share/tool-cache ]'
check "state path for home entry exists" bash -c '[ -d /var/lib/devcontainer-state/paths/home/vscode/.codex ] || [ -d /var/lib/devcontainer-state/paths/root/.codex ]'
check "state path for absolute entry exists" bash -c '[ -d /var/lib/devcontainer-state/paths/usr/local/share/tool-cache ]'
check "absolute path links to expected state target" bash -c '[ "$(readlink /usr/local/share/tool-cache)" = "/var/lib/devcontainer-state/paths/usr/local/share/tool-cache" ]'
check "write through link reaches state target" bash -c 'echo linked-write >/usr/local/share/tool-cache/write-test && [ "$(cat /var/lib/devcontainer-state/paths/usr/local/share/tool-cache/write-test)" = "linked-write" ]'

reportResults
