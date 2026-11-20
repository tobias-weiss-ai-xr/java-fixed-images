# appsuite-mw — OX App Suite middleware with the 2026-11 OpenJDK CPU fix.
#
# openEduSuite's appsuite-middleware 8.54.333 (OX-built wolfi image, digested
# 09a51d4b…) carries openjdk-25 25.0.5.0.2 and libexpat1 2.9.0 without the
# November fixes -> CVE-2026-114938 "Java4Shell" family (fix 25.0.5.1) and the
# libexpat1 CVEs (fix 2.10.0). OX/wolfi rebuilds may lag; this image keeps the
# app content byte-for-byte and swaps ONLY the two fixed wolfi packages:
#
#   - binaries: the pinned .apk files are downloaded, sha256-verified and
#     unpacked over /usr (COPY whiteout-replaces the old blobs; the JRE point
#     release 25.0.5.0.2->25.0.5.1 carries the same file set, so no stale
#     files remain for the JRE; the old libexpat .so.1.13.0 stays on disk but
#     is unreferenced)
#   - package database: /lib/apk/db/installed records for
#     openjdk-25-jre / openjdk-25-default-jvm / libexpat1 are updated to the
#     fixed versions (trivy reads versions from the apk db)
#
# No apk in the runtime image + wolfi marks /usr immutable, so no runtime
# mutation is attempted — only COPY layer whiteouts.
# Revert to the plain upstream middleware once OX ships a build already
# carrying openjdk>=25.0.5.1 and libexpat1>=2.10.0.

# -- base ---------------------------------------------------------------- --
FROM registry.openedusuite.org/openedusuite-nix/appsuite-middleware:8.54.333-nix AS openedusuitebase

FROM alpine:3.20 AS fetch
WORKDIR /out
ARG OPENJDK_VERSION=25.0.5.1-r0
ARG LIBEXPAT_VERSION=2.10.0-r1
ARG OPENJDK_SHA256=8abd9ec931054e9c673315e6dc376efb0ac5ee466b6138edca51cf993ecae002
ARG LIBEXPAT_SHA256=c2e5e062faaa066ef15752a4fb55fdae07c8c16e98b251d0b49651041ed6965f
# bring in the base apk database to apply a surgical version-record update
COPY --from=openedusuitebase /lib/apk/db/installed /out/db/installed
COPY patch-db.sh /out/patch-db.sh
RUN apk add --no-cache curl ca-certificates \
 && curl -fsSL -o openjdk.apk "https://packages.wolfi.dev/os/x86_64/openjdk-25-jre-${OPENJDK_VERSION}.apk" \
 && curl -fsSL -o libexpat.apk "https://packages.wolfi.dev/os/x86_64/libexpat1-${LIBEXPAT_VERSION}.apk" \
 && echo "${OPENJDK_SHA256}  openjdk.apk" | sha256sum -c - \
 && echo "${LIBEXPAT_SHA256}  libexpat.apk" | sha256sum -c - \
 && tar -xf openjdk.apk \
 && tar -xf libexpat.apk \
 && rm -f .PKGINFO .melange.yaml .source.sha256 \
 && sh /out/patch-db.sh /out/db/installed "${OPENJDK_VERSION}" "${LIBEXPAT_VERSION}"

# -- fixed image --------------------------------------------------------- --
FROM openedusuitebase
ARG OPENJDK_VERSION=25.0.5.1-r0
ARG LIBEXPAT_VERSION=2.10.0-r1
COPY --from=fetch /out/usr/ /usr/
COPY --from=fetch /out/db/installed /lib/apk/db/installed
# verify the swapped engine + record provenance inside the image
RUN java -version 2>&1 | head -2 \
 && grep -E 'openjdk-25-jre|openjdk-25-default-jvm|libexpat1' /lib/apk/db/installed -A1 | grep V: \
 && printf 'appsuite-mw java-fixed-images: openjdk-25-jre %s, libexpat1 %s (wolfi apk swap, CVE-2026-114938 family)\n' "$OPENJDK_VERSION" "$LIBEXPAT_VERSION" > /etc/appsuite-mw-fixes.txt
