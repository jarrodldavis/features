This feature configures `/etc/gai.conf` at image build time on glibc-based
images such as Debian and Ubuntu. It requires root during installation.
Alpine and other musl-based images are unsupported.

The policy gives `127.0.0.0/8` higher precedence in hostname lookups that
use glibc address selection, including lookups for `localhost`.
IPv6 remains available for explicit connections and listeners. Applications
with their own resolver or address ordering may behave differently.

The installer appends the five defaults documented in `gai.conf(5)` and
one extra rule for IPv4 loopback. An already matching active table succeeds
without changes. Other active precedence rules cause installation to fail
so the image's address policy can be reviewed.
