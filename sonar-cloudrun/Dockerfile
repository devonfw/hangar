FROM golang:1.18.4-alpine as builder

RUN apk add git

RUN git clone https://github.com/GoogleCloudPlatform/gcsfuse.git /run/gcsfuse

ARG GCSFUSE_REPO="/run/gcsfuse/"
ADD . ${GCSFUSE_REPO}
WORKDIR ${GCSFUSE_REPO}
RUN go install ./tools/build_gcsfuse
RUN build_gcsfuse . /tmp $(git log -1 --format=format:"%H")

FROM alpine:3.15

ENV LANG='en_US.UTF-8' \
    LANGUAGE='en_US:en' \
    LC_ALL='en_US.UTF-8'

#
# SonarQube setup
#
ARG SONARQUBE_VERSION=9.6.1.59531
ARG SONARQUBE_ZIP_URL=https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-${SONARQUBE_VERSION}.zip
ENV JAVA_HOME='/usr/lib/jvm/java-11-openjdk' \
    PATH="/opt/java/openjdk/bin:$PATH" \
    SONARQUBE_HOME=/opt/sonarqube \
    SONAR_VERSION="${SONARQUBE_VERSION}" \
    SQ_DATA_DIR="/opt/sonarqube/data" \
    SQ_EXTENSIONS_DIR="/opt/sonarqube/extensions" \
    SQ_LOGS_DIR="/opt/sonarqube/logs" \
    SQ_TEMP_DIR="/opt/sonarqube/temp"

RUN set -eux; \
    addgroup -S -g 1000 sonarqube; \
    adduser -S -D -u 1000 -G sonarqube sonarqube; \
    apk add --no-cache --virtual build-dependencies gnupg unzip curl; \
    apk add --no-cache bash su-exec ttf-dejavu openjdk11-jre; \
    # pub   2048R/D26468DE 2015-05-25
    #       Key fingerprint = F118 2E81 C792 9289 21DB  CAB4 CFCA 4A29 D264 68DE
    # uid                  sonarsource_deployer (Sonarsource Deployer) <infra@sonarsource.com>
    # sub   2048R/06855C1D 2015-05-25
    echo "networkaddress.cache.ttl=5" >> "${JAVA_HOME}/conf/security/java.security"; \
    sed --in-place --expression="s?securerandom.source=file:/dev/random?securerandom.source=file:/dev/urandom?g" "${JAVA_HOME}/conf/security/java.security"; \
    for server in $(shuf -e hkps://keys.openpgp.org \
                            hkps://keyserver.ubuntu.com) ; do \
        gpg --batch --keyserver "${server}" --recv-keys 679F1EE92B19609DE816FDE81DB198F93525EC1A && break || : ; \
    done; \
    mkdir --parents /opt; \
    cd /opt; \
    curl --fail --location --output sonarqube.zip --silent --show-error "${SONARQUBE_ZIP_URL}"; \
    curl --fail --location --output sonarqube.zip.asc --silent --show-error "${SONARQUBE_ZIP_URL}.asc"; \
    gpg --batch --verify sonarqube.zip.asc sonarqube.zip; \
    unzip -q sonarqube.zip; \
    mv "sonarqube-${SONARQUBE_VERSION}" sonarqube; \
    rm sonarqube.zip*; \
    rm -rf ${SONARQUBE_HOME}/bin/*; \
    chown -R sonarqube:sonarqube ${SONARQUBE_HOME}; \
    # this 777 will be replaced by 700 at runtime (allows semi-arbitrary "--user" values)
    chmod -R 777 "${SQ_DATA_DIR}" "${SQ_EXTENSIONS_DIR}" "${SQ_LOGS_DIR}" "${SQ_TEMP_DIR}"; \
    apk del --purge build-dependencies;

# GCSFuse Install
RUN apk add --update --no-cache bash ca-certificates fuse tini

COPY --from=builder /tmp/bin/gcsfuse /usr/local/bin/gcsfuse
COPY --from=builder /tmp/sbin/mount.gcsfuse /usr/sbin/mount.gcsfuse

# RUN set -e; \
#     apt-get update -y && apt-get install -y \
#     gnupg2 \
#     tini \
#     lsb-release; \
#     gcsFuseRepo=gcsfuse-`lsb_release -c -s`; \
#     echo "deb http://packages.cloud.google.com/apt $gcsFuseRepo main" | \
#     tee /etc/apt/sources.list.d/gcsfuse.list; \
#     curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | \
#     apt-key add -; \
#     apt-get update; \
#     apt-get install -y gcsfuse && apt-get clean

COPY --chown=sonarqube:sonarqube run.sh sonar.sh ${SONARQUBE_HOME}/bin/
RUN chmod +x ${SONARQUBE_HOME}/bin/run.sh
RUN chmod +x ${SONARQUBE_HOME}/bin/sonar.sh
# Create mount directory for service
ENV MNT_DIR /var/sonarqube/data
RUN mkdir -p $MNT_DIR


WORKDIR ${SONARQUBE_HOME}

EXPOSE 9000

STOPSIGNAL SIGINT

# Use tini to manage zombie processes and signal forwarding
# https://github.com/krallin/tini
ENTRYPOINT ["/sbin/tini", "--"]

# Run the web service on container startup.
CMD ["./bin/run.sh"]