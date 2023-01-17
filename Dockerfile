FROM alpine:latest

ARG TARGETOS
ARG TARGETARCH
ARG TARGETPLATFORM

ENV TZ=Europe/Berlin

# Applying fs patch for assets
ADD rootfs.tar.gz /

RUN mkdir /backup

WORKDIR /restic

RUN apk update && \
    apk add wget curl bash coreutils tzdata jq && \
    rm -rf /var/cache/apk/*

RUN chmod +x /restic/* && \
    ln -s /restic/status.sh /usr/local/bin/status

RUN TARGET_BIN_ARCH="${TARGETOS}_${TARGETARCH}" && \
    echo "Selecting $TARGET_BIN_ARCH binary for $TARGETPLATFORM" && \
    wget $(curl -s https://api.github.com/repos/restic/restic/releases | jq '.[] | select(.tag_name=="v0.15.0")' | grep "browser_download_url" | grep "$TARGET_BIN_ARCH" | cut -d '"' -f 4) -O ./restic.bz2 && \
    bzip2 -cd "./restic.bz2" > "./restic" && \
    rm restic.bz2 && \
    chmod +x restic

VOLUME /root/.cache/restic
    
ENTRYPOINT ["./entry.sh"]