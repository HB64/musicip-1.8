FROM debian:trixie-slim
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    gosu \
    socat \
    libc6-i386 \
    && rm -rf /var/lib/apt/lists/*
ARG PUID=1000
ARG PGID=1000
ADD MusicIP.tgz /opt
RUN groupadd -g ${PGID} musicip && \
    useradd -r -u ${PUID} -g ${PGID} musicip && \
    mkdir -p /home/musicip/.MusicMagic && \
    chown -R ${PUID}:${PGID} /opt/MusicIP && \
    chmod +x /opt/MusicIP/MusicMagicServer && \
    chmod +x /opt/MusicIP/mipcore
RUN mv -f /opt/MusicIP/entrypoint.sh /entrypoint.sh && \
    sed -i 's/\r//' /entrypoint.sh && \
    chmod +x /entrypoint.sh && \
    chown -R ${PUID}:${PGID} /home/musicip
EXPOSE 10002
CMD ["/entrypoint.sh"]