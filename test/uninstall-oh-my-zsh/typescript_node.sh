#!/bin/bash

set -e

source dev-container-features-test-lib

check "oh-my-zsh directory removed for node" bash -c "[ ! -d /home/node/.oh-my-zsh ]"

reportResults
