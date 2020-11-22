FROM toolchains/common AS helpers

m4_include(`paths.m4')m4_dnl

m4_include(`packages.m4')m4_dnl

FROM debian:stable-slim AS extractor
USER root

WORKDIR /usr/src

# Copy and execute each step separately to avoid invalidating cache
COPY --from=helpers /lib-helpers/prepare.sh lib-helpers/
RUN lib-helpers/prepare.sh

COPY --from=helpers /lib-helpers/functions.sh lib-helpers/

RUN apt-get update && \
	DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
		cpio \
		libbz2-dev \
		liblzma-dev \
		libxml2-dev \
		libssl-dev \
		zlib1g-dev \
		&& \
	rm -rf /var/lib/apt/lists/*

ENV SDK_DIR=/opt/sdk

ENV PACKAGES_LOCATION=/opt/

m4_dnl Use a define to have only one place to change
m4_define(`VERSION', 9.4.1)
# Extract last MacOS X SDK supporting i686 builds
COPY Xcode_`'VERSION.xip* ${PACKAGES_LOCATION}
local_package(xcode-extractor, , PACKAGE=Xcode_`'VERSION.xip SDK_PLATFORMS="MacOSX")

# Extract latest MacOS X and iPhoneOS SDK
m4_define(`VERSION', 12.2)
COPY Xcode_`'VERSION.xip* ${PACKAGES_LOCATION}
local_package(xcode-extractor, , PACKAGE=Xcode_`'VERSION.xip SDK_PLATFORMS="MacOSX iPhoneOS")

FROM scratch

COPY --from=extractor /opt/sdk/* /sdk/
