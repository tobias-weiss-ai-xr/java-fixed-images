#!/usr/bin/env bash
# Reproducible build of the java-fixed-images set (2026-11 Java security cluster).
# Usage:
#   bash build.sh [registry-prefix] [build|push]     # build all images
#   GITHUB_TOKEN=... bash build.sh <registry> push   # push all (logs in to ghcr.io)
set -euo pipefail

REGISTRY="${1:-java-fixed}"
MODE="${2:-build}"

# grommunio community gromox-core, 2026-11-20 daily build (immutable tag),
# published under their official container registry.
GROMOX_BASE="container.grommunio.com/community/gromox-core:2026.11-202611200110@sha256:9de818a5aaab1dc0640b525ab293416659a479ba86f9e6640df493115a7f5b93"
# Adoptium Temurin 17 GA — latest patch level at build time via the binary API.
TEMURIN_17_LATEST="https://api.adoptium.net/v3/binary/latest/17/ga/linux/x64/jdk/hotspot/normal/eclipse?project=jdk"

imgs=(
  "gromox-jdk:17.0.21|gromox-jdk"
)

if [ "$MODE" = push ]; then
  if [ -n "${GITHUB_TOKEN:-}" ]; then
    printf '%s' "$GITHUB_TOKEN" | docker login ghcr.io -u "${GITHUB_ACTOR:-tobias-weiss-ai-xr}" --password-stdin
  fi
  for e in "${imgs[@]}"; do docker push "$REGISTRY/${e%%|*}"; done
  exit 0
fi

for e in "${imgs[@]}"; do
  name="${e%%|*}"; ctx="${e#*|}"
  docker build \
    --build-arg GROMOX_BASE="$GROMOX_BASE" \
    --build-arg TEMURIN_URL="$TEMURIN_17_LATEST" \
    -t "$REGISTRY/$name" "$ctx"
done
echo "all images built; push with: GITHUB_TOKEN=... bash build.sh '$REGISTRY' push"
