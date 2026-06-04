#!/bin/bash

set -e

source dev-container-features-test-lib

check "oh-my-zsh not present for root" bash -c "[ ! -d /root/.oh-my-zsh ]"

reportResults
