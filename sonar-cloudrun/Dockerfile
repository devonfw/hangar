FROM golang:1.18.4-alpine as fuse-builder

RUN apk add git

ARG GCSFUSE_REPO="/run/gcsfuse/"

RUN git clone https://github.com/GoogleCloudPlatform/gcsfuse.git ${GCSFUSE_REPO}

WORKDIR ${GCSFUSE_REPO}
RUN go install ./tools/build_gcsfuse
RUN build_gcsfuse . /tmp $(git log -1 --format=format:"%H")

FROM sonarqube:latest

RUN apk add --update --no-cache bash ca-certificates fuse tini

#USER sonarqube

COPY --from=fuse-builder /tmp/bin/gcsfuse /usr/local/bin/gcsfuse
COPY --from=fuse-builder /tmp/sbin/mount.gcsfuse /usr/sbin/mount.gcsfuse

COPY run.sh ./run.sh
RUN chmod +x ./run.sh



# Use tini to manage zombie processes and signal forwarding
# https://github.com/krallin/tini
ENTRYPOINT ["/sbin/tini", "--"]

CMD ["./run.sh"]