# syntax=docker/dockerfile:1

FROM debian:bookworm AS builder

# Enable apt source repository
RUN sed -i -e 's/^Types: deb/Types: deb deb-src/g' /etc/apt/sources.list.d/debian.sources

# Install packages for building
RUN --mount=type=cache,target=/var/lib/apt/,sharing=locked \
    --mount=type=cache,target=/var/cache/apt/,sharing=locked \
    apt-get update && apt-get -y build-dep x264

WORKDIR /workspace/build/

# Build x264
RUN --mount=type=bind,source=.,rw \
    apt-get update && apt-get source x264 \
    && cd ./x264-*/ \
    && patch -p1 < /workspace/build/add_eos_eob.diff \
    && dpkg-buildpackage -b -us -uc \
    && cp /workspace/build/libx264-164_*.deb /workspace/

FROM debian:bookworm

RUN --mount=type=bind,from=builder,source=/workspace/,target=/workspace/ \
    --mount=type=cache,target=/var/lib/apt/,sharing=locked \
    --mount=type=cache,target=/var/cache/apt/,sharing=locked \
    apt-get update && apt-get install -y --no-install-recommends \
    ffmpeg /workspace/libx264-164_*.deb

ENTRYPOINT ["ffmpeg"]
