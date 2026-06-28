#!/bin/bash
# Builder stage only: install build deps, build Qt + MuseScore, install to /usr/local.
# No cleanup/useradd/locale-gen here -- this stage is discarded; the runtime stage
# (see Dockerfile) installs only runtime libs and copies the built artifacts out.
set -e
export DEBIAN_FRONTEND=noninteractive

# Pin apt to a fixed Debian snapshot (shared with the runtime stage).
./setup-apt-snapshot.sh

apt-get update
apt-get install -y --no-install-recommends \
    git \
    build-essential \
    cmake \
    pkg-config \
    python3 \
    python3-pip \
    libglib2.0-0t64 \
    libdbus-1-3 `# Qt6DBus links libdbus-1.so.3 at build time; no -dev package pulls it in` \
    libfontconfig1 \
    libfreetype6 \
    libopengl0 \
    libvorbis-dev \
    libjack-jackd2-dev \
    libsndfile1-dev \
    libasound2-dev \
    libgl1-mesa-dev \
    libglu1-mesa-dev \
    libxkbcommon-dev \
    libxkbfile-dev \
    libxcb-xinerama0 \
    libxcb-cursor0 \
    libxkbcommon-x11-0 \
    libxcb1 \
    libxcb-icccm4 \
    libxcb-keysyms1 \
    libxcb-shape0 \
    zlib1g-dev

pip install --break-system-packages -r requirements.txt
aqt install-qt linux desktop 6.2.4 gcc_64 --outputdir /opt/qt --modules qtnetworkauth qtscxml qt5compat qtmultimedia qtwebview qtwebengine

MUSESCORE_COMMIT=9773fcf84ee09d58cd491b56585b7bc4fa94b1d0
# This is the specific commit from PR #19246 mentioned in this video: https://www.youtube.com/watch?v=kSvwFtiHNkA
# PR: https://github.com/musescore/MuseScore/pull/19246/
git clone https://github.com/andreimatveyeu/MuseScore4.git MuseScore
cd MuseScore
git fetch origin $MUSESCORE_COMMIT
git checkout $MUSESCORE_COMMIT
mkdir build
cd build
cmake ..
make -j$(nproc)
make install
