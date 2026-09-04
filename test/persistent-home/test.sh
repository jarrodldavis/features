#!/bin/bash

set -e

source dev-container-features-test-lib

check "persistent state root exists" test -d /var/lib/devcontainer-persistent-home

reportResults
