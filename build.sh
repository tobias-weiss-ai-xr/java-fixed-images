#!/usr/bin/env bash
# Reproducible build of the java-fixed-images set (2026-11 Java security cluster).
# Usage:
#   bash build.sh [registry-prefix] [build|push]     # build all images
#   GITHUB_TOKEN=... bash build.sh <registry> push   # push all (logs in to ghcr.io)
set -euo pipefail

REGISTRY="${1:-java-fixed}"
MODE="${2:-build}"

# grommunio gromox-core, PHP 8.4.28-fixed base (see gromox-jdk/Dockerfile).
GROMOX_BASE="ghcr.io/tobias-weiss-ai-xr/php-fixed-images/gromox-core:8.4.28-20261120"
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
