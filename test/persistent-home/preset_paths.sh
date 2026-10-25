#!/bin/bash
set -e
source dev-container-features-test-lib
home=/home/vscode
state_root=/var/lib/devcontainer-persistent-home
check "Codex preset" bash -c "[ \"\$(readlink '$home/.codex')\" = '$state_root/.codex' ]"
check "Copilot CLI home" bash -c "[ \"\$(readlink '$home/.copilot')\" = '$state_root/.copilot' ]"
check "Copilot CLI session state is writable" bash -c "mkdir -p '$home/.copilot/session-state/test-session' && printf persisted > '$home/.copilot/session-state/test-session/events.jsonl' && [ \"\$(cat '$state_root/.copilot/session-state/test-session/events.jsonl')\" = persisted ]"
check "Copilot agent sessions" bash -c "[ \"\$(readlink '$home/.vscode-server/data/agentSessionData')\" = '$state_root/.vscode-server/data/agentSessionData' ]"
check "Copilot session database" bash -c "[ \"\$(readlink '$home/.vscode-server/data/User/globalStorage/github.copilot-chat')\" = '$state_root/.vscode-server/data/User/globalStorage/github.copilot-chat' ]"
check "Agent Host database file" bash -c "[ -f '$state_root/.vscode-server/data/User/globalStorage/agent-host.db' ]"
check "Arbitrary paths remain supported" test -L "$home/.local/share/example"
check "VS Code server data remains ephemeral" test ! -L "$home/.vscode-server/data"
reportResults
