#
# "Build" image
#
# It actually downloads the latest binary from official FTP.
#

FROM debian:stretch-slim AS build

WORKDIR /usr/local/src/arma3sync

ENV ARMA3SYNC_FTP ftp://www.sonsofexiled.fr/ArmA3/ArmA3Sync/download

RUN apt-get update && apt-get install --yes --no-install-recommends libxml-xpath-perl=1.40 wget=1.18 bsdtar=3.2.2
RUN wget "${ARMA3SYNC_FTP}/`wget ${ARMA3SYNC_FTP}/a3s.xml -O- | xpath -q -n -e '/version/file/text()'`" -O- | bsdtar --strip-components=1 -xvf-

#
# Runtime image
#

FROM openjdk:8-jre-slim

LABEL \
  org.label-schema.schema-version = "1.0" \
  org.label-schema.name = "arwynfr/arma3sync" \
  org.label-schema.description = "Arma3Sync docker command" \
  org.label-schema.vendor = "ArwynFr" \
  org.label-schema.version = 1 \
  maintainer = "arwyn.fr@gmail.com"

WORKDIR /opt/soe/arma3sync

ENV ARMA3SYNC_OPT /opt/soe/arma3sync
ENV ARMA3SYNC_NAME ""
ENV ARMA3SYNC_PROTOCOL HTTP
ENV ARMA3SYNC_URL http://localhost/
ENV ARMA3SYNC_PORT ""
ENV ARMA3SYNC_LOGIN anonymous
ENV ARMA3SYNC_PASSWD ""
ENV ARMA3SYNC_PATH /mods

COPY --from=build /usr/local/src/arma3sync/ArmA3Sync.jar .
COPY --from=build /usr/local/src/arma3sync/resources/lib ./resources/lib
RUN ln -s /data ./resources/ftp
COPY ./*.sh ./
RUN chmod +x ./*.sh

VOLUME /data
ENTRYPOINT [ "/opt/soe/arma3sync/entrypoint.sh" ]
