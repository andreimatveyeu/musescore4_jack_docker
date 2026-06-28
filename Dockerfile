# ---------- builder: compile Qt + MuseScore, then get discarded ----------
FROM debian:trixie@sha256:d07d1b51c39f51188e60be9b64e6bf769fa94e187f092bc32b91305cfa34ba5a AS builder

# qmake (installed by aqt under here) must be on PATH for MuseScore's cmake to find Qt.
ENV PATH="/opt/qt/6.2.4/gcc_64/bin:${PATH}"
ENV LD_LIBRARY_PATH="/opt/qt/6.2.4/gcc_64/lib:/usr/lib/x86_64-linux-gnu"

RUN mkdir -p /app
WORKDIR /app
COPY make_build.sh setup-apt-snapshot.sh requirements.txt ./
RUN chmod a+x make_build.sh setup-apt-snapshot.sh && ./make_build.sh

# ---------- runtime: only runtime libs + the built artifacts ----------
FROM debian:trixie@sha256:d07d1b51c39f51188e60be9b64e6bf769fa94e187f092bc32b91305cfa34ba5a AS runtime

ENV LD_LIBRARY_PATH="/opt/qt/6.2.4/gcc_64/lib:/usr/lib/x86_64-linux-gnu"
ENV LANG="en_US.UTF-8" LANGUAGE="en_US:en" LC_ALL="en_US.UTF-8"
ENV DEBIAN_FRONTEND=noninteractive

# Pin apt to the same Debian snapshot as the builder for reproducibility.
COPY setup-apt-snapshot.sh /tmp/setup-apt-snapshot.sh
RUN chmod a+x /tmp/setup-apt-snapshot.sh && /tmp/setup-apt-snapshot.sh && rm /tmp/setup-apt-snapshot.sh

# Runtime libraries only -- no -dev packages, no build toolchain.
# dbus/dbus-user-session: the save dialog needs a D-Bus session bus; on Debian
# these are only Recommends, so --no-install-recommends would otherwise drop them.
RUN apt-get update && apt-get install -y --no-install-recommends \
    locales \
    dbus \
    dbus-user-session \
    pipewire \
    pipewire-bin \
    pipewire-jack \
    pulseaudio-utils \
    libjack-jackd2-0 \
    libsndfile1 \
    libasound2t64 \
    libvorbis0a \
    libvorbisenc2 \
    libvorbisfile3 \
    libfontconfig1 \
    libfreetype6 \
    libopengl0 \
    libgl1 \
    libglx-mesa0 \
    libgl1-mesa-dri \
    libglu1-mesa \
    libegl1 \
    libgles2 \
    libgbm1 \
    libxkbcommon0 \
    libxkbcommon-x11-0 \
    libxkbfile1 \
    libxcb1 \
    libxcb-xinerama0 \
    libxcb-cursor0 \
    libxcb-icccm4 \
    libxcb-keysyms1 \
    libxcb-shape0 \
    libxcb-image0 \
    libxcb-render-util0 \
    libxcb-randr0 \
    libxcb-render0 \
    libxcb-shm0 \
    libxcb-sync1 \
    libxcb-util1 \
    libxcb-xfixes0 \
    libxcb-xkb1 \
    libxcb-glx0 \
    libx11-6 \
    libx11-xcb1 \
    libxext6 \
    libglib2.0-0t64 \
    libgssapi-krb5-2 \
    zlib1g \
    ca-certificates \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen

# Copy only the Qt subdirs loaded at runtime (skips bin/include/mkspecs/doc/modules)
# and only MuseScore's binary + data (skips headers, static libs, pip leftovers).
COPY --from=builder /opt/qt/6.2.4/gcc_64/lib /opt/qt/6.2.4/gcc_64/lib
COPY --from=builder /opt/qt/6.2.4/gcc_64/plugins /opt/qt/6.2.4/gcc_64/plugins
COPY --from=builder /opt/qt/6.2.4/gcc_64/qml /opt/qt/6.2.4/gcc_64/qml
COPY --from=builder /opt/qt/6.2.4/gcc_64/libexec /opt/qt/6.2.4/gcc_64/libexec
COPY --from=builder /opt/qt/6.2.4/gcc_64/resources /opt/qt/6.2.4/gcc_64/resources
COPY --from=builder /opt/qt/6.2.4/gcc_64/translations /opt/qt/6.2.4/gcc_64/translations
COPY --from=builder /usr/local/bin/mscore /usr/local/bin/mscore
COPY --from=builder /usr/local/share /usr/local/share

# prevent Musescore from crashing due to directories not found/not writable:
RUN mkdir -p /home/user/.local/share/MuseScore/MuseScore4/logs/ \
    && chmod a+rwx -R /home/user/.local/share/MuseScore

# add user to run as non-root
RUN useradd -G audio user

CMD ["pw-jack", "mscore"]

ARG GIT_COMMIT=unspecified
LABEL revision=$GIT_COMMIT
