[MuseScore 4](https://musescore.org/) for Linux with Jack MIDI/Audio support from an (ongoing) [pull request #19246](https://github.com/musescore/MuseScore/pull/19246/) by Larry @lyrra.

This repo contains scripts to build a docker image to install dependencies, build the dev-branch and run MuseScore in a container.

The image is a two-stage build on a digest-pinned `debian:trixie` base: a builder stage compiles Qt and MuseScore, and a slim runtime stage ships only the runtime libraries plus the built artifacts. apt packages are pinned to a fixed [snapshot.debian.org](https://snapshot.debian.org) timestamp (see `setup-apt-snapshot.sh`) and the Qt installer's Python dependencies are locked (`requirements.txt`), so builds are reproducible.

## Instructions

Build locally (tags the image `:latest`):

```bash
./build
```

Run:

```bash
./run            # use the released image for this repo's latest git tag
./run --latest   # use the ':latest' tag instead (e.g. a local ./build)
```

By default `./run` resolves the repo's latest git tag (via `git describe`) and runs the matching published image `ghcr.io/andreimatveyeu/musescore4_jack:<tag>`, pulling it from GHCR if needed. Use `--latest` to run the `:latest` tag instead.

You may want to adjust `docker run` parameters such as mounts. The current directory is by default mounted to `/data` in the container.

## Releases

Pushing a semver tag triggers the GitHub Actions workflow, which builds the image, pushes it to GHCR tagged with both `:latest` and the version (e.g. `:1.0.2`), and creates a GitHub release:

```bash
git tag 1.0.2
git push origin 1.0.2
```
