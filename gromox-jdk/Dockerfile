# gromox-jdk — grommunio gromox-core with a patched OpenJDK 17 CPU level.
#
# grommunio's community image ships openjdk 17.0.20.1 (pre-fix for the 2026-11
# Java security cluster incl. CVE-2026-114938 Java4Shell family). This image
# keeps gromox-core byte-for-byte and only replaces the JDK with Adoptium
# Temurin 17.0.21.1 (GA, hotspot, x64, Linux — SHA-256-verified), installed into
# the Leap 16 /usr/share/jvm layout and wired via update-alternatives.
#
# Note: the embedded keycloak is DISABLED in the fleet deployment
# (ENABLE_KEYCLOAK=false in the running pod), so this JDK is dormant today —
# the image exists to remove the residual from vulnerability scans and to be
# ready when keycloak is re-enabled or the JDK is used by other gromox bits.
#
# Upstream tracking: revert to the stock grommunio image once their Leap 16
# java-17-openjdk package reaches 17.0.21+; pin whatever you deploy by digest.

ARG GROMOX_BASE=container.grommunio.com/community/gromox-core:2026.11-202611200110@sha256:9de818a5aaab1dc0640b525ab293416659a479ba86f9e6640df493115a7f5b93
FROM ${GROMOX_BASE}

ARG TEMURIN_VER=17.0.21.1
ARG TEMURIN_BUILD=2
ARG TEMURIN_SHA256=0b0ac5eab6db6abaec68c9913bcddb31321e5da411c45073d520d9c125e6f7b4

RUN set -eux; \
    TAG="jdk-${TEMURIN_VER}%2B${TEMURIN_BUILD}"; \
    FN="OpenJDK17U-jdk_x64_linux_hotspot_${TEMURIN_VER}_${TEMURIN_BUILD}.tar.gz"; \
    URL="https://github.com/adoptium/temurin17-binaries/releases/download/${TAG}/${FN}"; \
    curl -fsSL "${URL}" -o /tmp/jdk.tar.gz; \
    echo "${TEMURIN_SHA256}  /tmp/jdk.tar.gz" | sha256sum -c -; \
    mkdir -p /usr/share/jvm/temurin-17; \
    tar -xzf /tmp/jdk.tar.gz -C /usr/share/jvm/temurin-17 --strip-components=1; \
    rm -f /tmp/jdk.tar.gz; \
    update-alternatives --install /usr/bin/java java /usr/share/jvm/temurin-17/bin/java 100 \
        --slave /usr/bin/jar jar /usr/share/jvm/temurin-17/bin/jar \
        --slave /usr/bin/javac javac /usr/share/jvm/temurin-17/bin/javac; \
    update-alternatives --set java /usr/share/jvm/temurin-17/bin/java; \
    printf 'export JAVA_HOME=/usr/share/jvm/temurin-17\n' > /etc/profile.d/temurin-java.sh; \
    java -version 2>&1 | head -1; \
    readlink -f /usr/bin/java
