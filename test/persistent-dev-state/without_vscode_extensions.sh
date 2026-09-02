#!/bin/bash

set -e

source dev-container-features-test-lib

check "vscode extensions not linked" bash -c '[ ! -L "$HOME/.vscode-server/extensions" ]'

reportResults
