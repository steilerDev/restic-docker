FROM alpine:latest

# Applying fs patch for assets
ADD rootfs.tar.gz /

RUN mkdir /backup

WORKDIR /restic

RUN apk update && \
    apk add wget curl bash && \
    rm -rf /var/cache/apk/*

RUN chmod +x /restic/* && \
    ln -s /restic/status.sh /usr/local/bin/status

RUN wget $(curl -s https://api.github.com/repos/restic/restic/releases | grep "browser_download_url" | grep "linux_amd64" | head -n 1 | cut -d '"' -f 4) -O ./restic.bz2 && \
    bzip2 -cd "./restic.bz2" > "./restic" && \
    rm restic.bz2 && \
    chmod +x restic
    
ENTRYPOINT ["./entry.sh"]