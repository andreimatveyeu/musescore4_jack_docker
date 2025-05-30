#!/bin/bash
set -e
export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get install -y --no-install-recommends \
    git \
    build-essential \
    cmake \
    locales \
    python3 \
    python3-pip \
    pipewire \
    pulseaudio-utils \
    pipewire-jack \
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

apt-get clean
rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen
locale-gen

pip install --break-system-packages aqtinstall==3.1.21
aqt install-qt linux desktop 6.2.4 gcc_64 --outputdir /opt/qt --modules qtnetworkauth qtscxml qt5compat qtmultimedia qtwebview qtwebengine

# d83f86ec095ae24f285108f6528d44ec9016c3de is the specific commit from PR #19246 that was tested. PR: https://github.com/musescore/MuseScore/pull/19246/
git clone --depth=1 https://github.com/musescore/MuseScore.git MuseScore
cd MuseScore
git fetch origin pull/19246/head:jack-support
#git checkout jack-support  # uncomment to use latest commit of the pull request
git checkout 77ee6664db420e52977dbe1385fd7778e675b339
mkdir build
cd build
cmake ..
make -j$(nproc)
make install

# cleanup
apt-get remove -y --purge git build-essential cmake python3-pip python3
cd /app
rm -rf MuseScore
rm -rf /root/.cache
rm -rf /usr/local/lib/python*

# add user to run as non-root
useradd -G audio user
