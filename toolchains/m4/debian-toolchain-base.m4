m4_define(`DEBIAN_VERSION',20210408)
FROM toolchains/common AS helpers

FROM debian:stable-DEBIAN_VERSION-slim m4_ifdef(`STAGE_IMAGE_NAME',AS STAGE_IMAGE_NAME,)
USER root

WORKDIR /usr/src

# Copy and execute each step separately to avoid invalidating cache
COPY --from=helpers /lib-helpers/prepare.sh lib-helpers/
RUN lib-helpers/prepare.sh

COPY --from=helpers /lib-helpers/functions.sh lib-helpers/
