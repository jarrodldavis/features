#!/bin/bash

set -e

source dev-container-features-test-lib

check "node user exists" id node
check "node home directory exists" bash -c "home_dir=\$(getent passwd node | cut -d: -f6) && [ -n \"\$home_dir\" ] && [ -d \"\$home_dir\" ]"
check "oh-my-zsh directory removed for node" bash -c "home_dir=\$(getent passwd node | cut -d: -f6) && [ ! -d \"\$home_dir/.oh-my-zsh\" ]"

reportResults
