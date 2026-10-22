#!/bin/bash
set -e

# Feature installation should replace a zoneinfo symlink with a file,
# so the runtime bind mount won't follow it into /usr/share/zoneinfo.
test -f /etc/localtime
test ! -L /etc/localtime
echo "Timezone mount target is a regular file"
