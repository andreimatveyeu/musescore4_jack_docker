#!/bin/bash
# Pin apt to a fixed snapshot.debian.org timestamp so package versions are
# reproducible regardless of when the image is built. Used by BOTH the builder
# (make_build.sh) and the runtime stage (Dockerfile) so they share one snapshot.
#
# Bump DEBIAN_SNAPSHOT to intentionally move to newer packages. An arbitrary
# timestamp redirects to the nearest existing snapshot, so any value works.
set -e

DEBIAN_SNAPSHOT=20260628T000000Z

# Replace the default deb822 source so we fetch ONLY from the snapshot.
rm -f /etc/apt/sources.list.d/debian.sources

cat > /etc/apt/sources.list <<EOF
deb [check-valid-until=no] http://snapshot.debian.org/archive/debian/${DEBIAN_SNAPSHOT} trixie main
deb [check-valid-until=no] http://snapshot.debian.org/archive/debian/${DEBIAN_SNAPSHOT} trixie-updates main
deb [check-valid-until=no] http://snapshot.debian.org/archive/debian-security/${DEBIAN_SNAPSHOT} trixie-security main
EOF
