[MuseScore 4](https://musescore.org/) for Linux with Jack MIDI/Audio support from an (ongoing) [pull request #19246](https://github.com/musescore/MuseScore/pull/19246/) by Larry @lyrra.

This repo contains scripts to build a docker image to install dependencies, build the dev-branch and run MuseScore in a container.

## Instructions

Build:

```bash
./build
```

Run:
```bash
./run
```
You may want to adjust `docker run` parameters such as mounts. The current directory is by default mounted to `/data` in the container.