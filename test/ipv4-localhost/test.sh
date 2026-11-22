#!/bin/bash
set -euo pipefail

addresses=$(getent ahosts localhost)
read -r first_address _ <<< "$addresses"
test "$first_address" = 127.0.0.1
