# modem7/docker-apt-cacher-ng
[![Docker Pulls](https://img.shields.io/docker/pulls/modem7/apt-cacher-ng)](https://hub.docker.com/r/modem7/apt-cacher-ng)
[![Docker Image Size (tag)](https://img.shields.io/docker/image-size/modem7/apt-cacher-ng/latest)](https://hub.docker.com/r/modem7/apt-cacher-ng)
[![Build Status](https://drone.modem7.com/api/badges/modem7/docker-apt-cacher-ng/status.svg)](https://drone.modem7.com/modem7/docker-apt-cacher-ng)
[![GitHub last commit](https://img.shields.io/github/last-commit/modem7/docker-apt-cacher-ng)](https://github.com/modem7/docker-apt-cacher-ng)

Docker image for apt-cacher-ng based off of debian:bullseye-slim



To pull this image:
`docker pull modem7/apt-cacher-ng`

## Image Tags

### Multi-arch Tags

The `latest` tag has multi-arch support for `amd64`, and `arm64` and will automatically pull the correct tag based on your system's architecture.

## Example usage

```
docker run -d \
  --name apt-cacher-ng \
  -p 3142:3142 \
  -e TZ="Europe/London" \
  -v /data/apt-cacher-ng:/var/cache/apt-cacher-ng \
  modem7/apt-cacher-ng
```

## Docker Compose example
```
 ################
 #APT-Cacher-NG##
 ################

  apt-cacher-ng:
    container_name: APT-Cacher-NG
    hostname: APT-Cacher-NG
    restart: always
    image: modem7/apt-cacher-ng
    networks:
      pihole:
        ipv4_address: '172.22.0.111'
    ports:
    - "3142:3142"
    volumes:
      - apt-cacher-ng:/var/cache/apt-cacher-ng

volumes:
  apt-cacher-ng:
```

This image runs `apt-cacher-ng`, `cron`, and `rsyslogd` to ensure that apt-cacher-ng functions properly with scheduled jobs and appropriate logging.

In order to configure a host to make use of apt-cacher-ng on a box, you should create a file on the host `/etc/apt/apt.conf` with the following lines:

```
Acquire::http::Proxy "http://<docker-host>:3142";
```

You can also bypass the apt caching server on a per client basis by using the following syntax in your `/etc/apt/apt.conf` file:

```
Acquire::HTTP::Proxy::<repo-url> "DIRECT";
```

For example:

```
Acquire::HTTP::Proxy::get.docker.com "DIRECT";
Acquire::HTTP::Proxy::download.virtualbox.org "DIRECT";
```

Note:  The above assumes that you are mapping port 3142 on the docker host and 3142 is accessible from all machines.

You can also update the /etc/apt-cacher-ng/acng.conf and add one or more `PassThroughPattern` lines to force clients to bypass a repository:

```
PassThroughPattern: get\.docker\.com
PassThroughPattern: download\.virtualbox\.org
```

Based on the work from [mbentley](https://github.com/mbentley/docker-apt-cacher-ng) and [sameersbn](https://github.com/sameersbn/docker-apt-cacher-ng).
