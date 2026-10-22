#!/bin/sh
set -eu

echo "Configuring /etc/localtime to follow the host without mounting over it"

# Keep the host's timezone file on a separate mount so tzdata can safely
# replace /etc/localtime and its own /usr/share/zoneinfo files.
mkdir -p /usr/local/share
touch /usr/local/share/host-localtime

cat > /usr/local/sbin/restore-host-localtime <<'EOF'
#!/bin/sh
set -eu
[ -e /usr/local/share/host-localtime ] || exit 0
ln -sfn /usr/local/share/host-localtime /etc/localtime.dpkg-host-new
mv -f /etc/localtime.dpkg-host-new /etc/localtime
EOF
chmod 0755 /usr/local/sbin/restore-host-localtime

# Debian tzdata's postinst may rewrite /etc/localtime. Restore the host
# reference after apt's dpkg phase, including when apt itself fails.
if command -v apt-get >/dev/null 2>&1; then
    mkdir -p /etc/apt/apt.conf.d
    cat > /etc/apt/apt.conf.d/99-match-host-time-zone <<'EOF'
DPkg::Post-Invoke { "/usr/local/sbin/restore-host-localtime"; };
EOF
fi

# The runtime bind mount is applied only when the container starts.
# Keep the link valid in the image already.
ln -sfn /usr/local/share/host-localtime /etc/localtime.dpkg-host-new
mv -f /etc/localtime.dpkg-host-new /etc/localtime
