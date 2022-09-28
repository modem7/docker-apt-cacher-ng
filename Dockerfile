# syntax = docker/dockerfile:latest
FROM ubuntu:jammy-20220815
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
                    avahi-daemon \
                    ca-certificates \
                    cron \
                    logrotate \
                    rsyslog \
                    wget
EOF

RUN <<EOF
    set -xe
    # Set permissions
    chown -R apt-cacher-ng:apt-cacher-ng /var/run/apt-cacher-ng

    # Modify config files
    sed -i "s/# PassThroughPattern: .* # this would allow CONNECT to everything/PassThroughPattern: .* # this would allow CONNECT to everything/g" /etc/apt-cacher-ng/acng.conf
    sed -i "s/# ReuseConnections: 1/ReuseConnections: 1/g" /etc/apt-cacher-ng/acng.conf
    sed -i "s/# UnbufferLogs: 0/UnbufferLogs: 1/g" /etc/apt-cacher-ng/acng.conf
    sed -i "s/ExThreshold: 4/ExThreshold: 7/g" /etc/apt-cacher-ng/acng.conf
    sed -i "s/# SocketPath: \/var\/run\/apt-cacher-ng\/socket/SocketPath=\/var\/run\/apt-cacher-ng\/socket/g" /etc/apt-cacher-ng/acng.conf
    sed -i "s/# PidFile: \/var\/run\/apt-cacher-ng\/pid/pidfile=\/var\/run\/apt-cacher-ng\/pid/g" /etc/apt-cacher-ng/acng.conf
    echo "Remap-dockerrep: file:docker_mirrors /docker ; file:backends_docker # Docker Archives" >> /etc/apt-cacher-ng/acng.conf
    sed -i "s/# ForeGround: 0/ForeGround: 1/g" /etc/apt-cacher-ng/acng.conf
    sed -i "s/size 10M/size 100M/g" /etc/logrotate.d/apt-cacher-ng
    sed -i "/imklog/s/^/#/" /etc/rsyslog.conf

    # Create Docker mirrors
    echo 'https://download.docker.com/linux' >> /usr/lib/apt-cacher-ng/docker_mirrors
    # echo 'https://download.docker.com/linux/ubuntu' >> /usr/lib/apt-cacher-ng/docker_mirrors
    # echo 'https://download.docker.com/linux/centos' >> /usr/lib/apt-cacher-ng/docker_mirrors
    # echo 'https://download.docker.com/linux/debian' >> /usr/lib/apt-cacher-ng/docker_mirrors
    # echo 'https://download.docker.com/linux/fedora' >> /usr/lib/apt-cacher-ng/docker_mirrors
    # echo 'https://download.docker.com/linux/raspbian' >> /usr/lib/apt-cacher-ng/docker_mirrors
    # echo 'https://download.docker.com/linux/rhel' >> /usr/lib/apt-cacher-ng/docker_mirrors

    # Create Docker backends
    echo 'https://download.docker.com/linux' >> /etc/apt-cacher-ng/backends_docker
    # echo 'https://download.docker.com/linux/ubuntu' >> /etc/apt-cacher-ng/backends_docker
    # echo 'https://download.docker.com/linux/centos' >> /etc/apt-cacher-ng/backends_docker
    # echo 'https://download.docker.com/linux/debian' >> /etc/apt-cacher-ng/backends_docker
    # echo 'https://download.docker.com/linux/fedora' >> /etc/apt-cacher-ng/backends_docker
    # echo 'https://download.docker.com/linux/raspbian' >> /etc/apt-cacher-ng/backends_docker
    # echo 'https://download.docker.com/linux/rhel' >> /etc/apt-cacher-ng/backends_docker
EOF

ARG TINI_VERSION='v0.19.0'
COPY --link --chmod=755 entrypoint.sh /
ADD --link --chmod=755 https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini

VOLUME ["/var/cache/apt-cacher-ng"]
EXPOSE 3142/tcp

HEALTHCHECK --interval=10s --timeout=10s --retries=3 --start-period=20s \
    CMD wget -q -t1 -O /dev/null http://localhost:3142/acng-report.html || exit 1

ENTRYPOINT ["/tini", "-gv", "--", "/entrypoint.sh"]
CMD ["/bin/bash", "-c", "/etc/init.d/apt-cacher-ng start; tail -f /var/log/apt-cacher-ng/*"]



