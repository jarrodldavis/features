#!/bin/bash

set -e

source dev-container-features-test-lib

check "oh-my-zsh directory removed" bash -c "[ ! -d /home/octocat/.oh-my-zsh ]"

reportResults
