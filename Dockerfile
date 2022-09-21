# syntax = docker/dockerfile-upstream:master-labs
FROM debian:bullseye-20220912-slim
LABEL maintainer="Modem7"

RUN --mount=type=cache,id=aptcache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,id=libcache,target=/var/lib/apt,sharing=locked \
    <<EOF
    set -xe
    rm -fv /etc/apt/apt.conf.d/docker-clean
    echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' > /etc/apt/apt.conf.d/keep-cache
    apt-get update
    DEBIAN_FRONTEND=noninteractive \
                    apt-get install \
                    --no-install-recommends -y \
                    apt-cacher-ng \
                    ca-certificates \
                    cron \
                    logrotate \
                    rsyslog \
                    wget
EOF

RUN <<EOF
    set -xe
    chown -R apt-cacher-ng:apt-cacher-ng /var/run/apt-cacher-ng
    sed -i "s/# PassThroughPattern: .* # this would allow CONNECT to everything/PassThroughPattern: .* # this would allow CONNECT to everything/g" /etc/apt-cacher-ng/acng.conf
    sed -i "s/# ReuseConnections: 1/ReuseConnections: 1/g" /etc/apt-cacher-ng/acng.conf
    sed -i "s/# UnbufferLogs: 0/UnbufferLogs: 1/g" /etc/apt-cacher-ng/acng.conf
    sed -i "s/ExThreshold: 4/ExThreshold: 7/g" /etc/apt-cacher-ng/acng.conf
    sed -i "s/# SocketPath: \/var\/run\/apt-cacher-ng\/socket/SocketPath=\/var\/run\/apt-cacher-ng\/socket/g" /etc/apt-cacher-ng/acng.conf
    sed -i "s/# PidFile: \/var\/run\/apt-cacher-ng\/pid/pidfile=\/var\/run\/apt-cacher-ng\/pid/g" /etc/apt-cacher-ng/acng.conf
    sed -i "s/# ForeGround: 0/ForeGround: 1/g" /etc/apt-cacher-ng/acng.conf
    sed -i "s/size 10M/size 100M/g" /etc/logrotate.d/apt-cacher-ng
    sed -i '/imklog/s/^/#/' /etc/rsyslog.conf
EOF

ARG TINI_VERSION='v0.19.0'
ADD --link --chmod=755 https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
COPY --link --chmod=755 entrypoint.sh /

VOLUME ["/var/cache/apt-cacher-ng"]
EXPOSE 3142/tcp

HEALTHCHECK --interval=10s --timeout=10s --retries=3 --start-period=20s \
    CMD wget -q -t1 -O /dev/null http://localhost:3142/acng-report.html || exit 1

ENTRYPOINT ["/tini", "-gv", "--", "/entrypoint.sh"]
#CMD ["/etc/init.d/apt-cacher-ng", "start", "&&", "tail", "-f", "/var/log/apt-cacher-ng/*"]
CMD /etc/init.d/apt-cacher-ng start && tail -f /var/log/apt-cacher-ng/*



