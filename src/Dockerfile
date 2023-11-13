#
# "Build" image
#
# It actually compiles sources from the official svn repository
#
ARG JAVA_VERSION

FROM eclipse-temurin:${JAVA_VERSION}-jdk AS build

WORKDIR /usr/local/src/arma3sync

ARG ARMA3SYNC_VERSION
ENV ARMA3SYNC_SVN svn://www.sonsofexiled.fr/repository/ArmA3Sync/releases

RUN apt-get update && apt-get install --yes subversion --no-install-recommends
RUN svn checkout ${ARMA3SYNC_SVN}/ArmA3Sync-${ARMA3SYNC_VERSION} .
RUN mkdir build
RUN javac $(find . -name "*.java") -Xlint:deprecation -Xlint:unchecked -encoding ISO-8859-1 -classpath "$(find . -name "*.jar" -printf '%p:')" -d ./build
WORKDIR /usr/local/src/arma3sync/build
RUN jar cmvf ../MANIFEST_A3S.MF ../ArmA3Sync.jar ./*

#
# Runtime image
#

FROM eclipse-temurin:${JAVA_VERSION}-jre AS runtime

LABEL \
  org.label-schema.schema-version = "1.0" \
  org.label-schema.name = "arwynfr/arma3sync" \
  org.label-schema.description = "Arma3Sync docker command" \
  org.label-schema.vendor = "ArwynFr" \
  org.label-schema.version = 2 \
  maintainer = "arwyn.fr@gmail.com"

WORKDIR /opt/soe/arma3sync

ARG ARMA3SYNC_VERSION
ENV ARMA3SYNC_VERSION=$ARMA3SYNC_VERSION
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
