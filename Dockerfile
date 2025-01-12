FROM ubuntu:24.04

ENV PATH="/opt/qt/6.2.4/gcc_64/bin:${PATH}"
ENV LD_LIBRARY_PATH="/opt/qt/6.2.4/gcc_64/lib:/usr/lib/x86_64-linux-gnu"
ENV LANG="en_US.UTF-8" LANGUAGE="en_US:en" LC_ALL="en_US.UTF-8"

RUN mkdir -p /app
WORKDIR /app
COPY make_build.sh .
RUN chmod a+x make_build.sh && ./make_build.sh
CMD pw-jack mscore

# prevent Musescore from crashing due to directories not found/not writable:
RUN mkdir -p /home/user/.local/share/MuseScore/MuseScore4/logs/
RUN chmod a+rwx -R /home/user/.local/share/MuseScore

ARG GIT_COMMIT=unspecified
LABEL revision=$GIT_COMMIT
