# java-fixed-images — JVM/Java security-fix images (2026-11)

Twin of [php-fixed-images](https://github.com/tobias-weiss-ai-xr/php-fixed-images).
Own builds of Java runtimes / JVM-based application images that carry the
**2026-11 Java security cluster** while upstream distro packages and app images
lag:

- **CVE-2026-114938 "Java4Shell"** (critical) — HotSpot Base64 intrinsic heap
  overflow; fixed in OpenJDK CPU (25.0.5.1 / 17.0.21 / 21.0.13 / 11.0.31).
  Not exploitable on our fleet (nodes lack AVX-512 VBMI), but images
  should stop shipping the vulnerable `-XX:UseBASE64Intrinsics` JRE.
- CVE-2026-114939/114940/114941/114942 and companions — same OpenJDK CPU.
- Bundled-jar residuals in app images (opennlp / solr / jetty in XWiki, etc.).

Strategy: keep the upstream application image byte-for-byte and only swap the
Java runtime (engine/JDK or jar files) with a patched build, ABI-compatible.

## Published images

| Image | Contents |
|---|---|
| `ghcr.io/tobias-weiss-ai-xr/java-fixed-images/gromox-jdk:17.0.21` | grommunio gromox-core with the JDK replaced by Temurin **17.0.21.1** (ships 17.0.20.1). Base = the `php-fixed-images/gromox-core:8.4.28` image, so it carries **both** the PHP 8.4.28 engine fix and the JDK CPU in one image |
| *(planned)* `xwiki-jarfix:18.9.0` | XWiki 18.9.0 with opennlp-tools 1.9.5 / solr-core 9.10.1 / jetty fixed jars swapped into `WEB-INF/lib` |
| *(planned)* `appsuite-mw` | openEduSuite appsuite-middleware with openjdk 25.0.5.1 (wolfi) |

Same images mirrored to `registry.openedusuite.org/java-fixed/<name>:<tag>`.

## Provenance

- gromox-jdk: `grommunio` community `gromox-core:2026.11-202611200110`
  (digest-pinned) as base; **Adoptium Temurin 17.0.21** (GA, hotspot, x64, Linux,
  SHA-256-verified from the Adoptium binary API) extracted into the Leap 16
  `/usr/share/jvm` layout and wired through `update-alternatives`. Embedded
  keycloak is disabled in the fleet anyway (`ENABLE_KEYCLOAK=false`), so this
  removes the last dormant Java residual from the gromox image.
- Rebuild locally: `bash build.sh` (needs docker); push:
  `GITHUB_TOKEN=... bash build.sh <registry> push` (or GitHub Actions).

## Notes / gotchas

- Leap 16 keeps JREs under `/usr/share/jvm`, selected via `update-alternatives`
  (`/usr/bin/java -> /usr/bin/alts`). Swap the whole JDK directory, don't patch
  symlinks by hand.
- Verify every image *in-container*: `java -version` → the fixed patch level,
  and the application still starts.
- Pin base images by digest (SCG-009 no-bare-latest); upstream daily rebuilds
  are fine to track but pin what you deploy.
