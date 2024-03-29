# modem7/docker-apt-cacher-ng
[![Docker Pulls](https://img.shields.io/docker/pulls/modem7/apt-cacher-ng)](https://hub.docker.com/r/modem7/apt-cacher-ng)
[![Docker Image Size (tag)](https://img.shields.io/docker/image-size/modem7/apt-cacher-ng/latest)](https://hub.docker.com/r/modem7/apt-cacher-ng)
[![Build Status](https://drone.modem7.com/api/badges/modem7/docker-apt-cacher-ng/status.svg)](https://drone.modem7.com/modem7/docker-apt-cacher-ng)
[![GitHub last commit](https://img.shields.io/github/last-commit/modem7/docker-apt-cacher-ng)](https://github.com/modem7/docker-apt-cacher-ng)

[!["Buy Me A Coffee"](https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png)](https://www.buymeacoffee.com/modem7)

Docker image for apt-cacher-ng.

---

Apt-Cache-ng is a caching proxy. Specialized for package files from Linux distributors, primarily for Debian (and Debian based) distributions but not limited to those.

A caching proxy have the following benefits:

- Lower latency
- Reduce WAN traffic
- Higher speed for cached contents

---

To pull this image:
`docker pull modem7/apt-cacher-ng`

## Image Tags

### Multi-arch Tags

The `latest` tag has multi-arch support for `amd64`, and `arm64` and will automatically pull the correct tag based on your system's architecture.

## Environment Variables
| Variable | Possible Values | Description |
| :----: | --- | --- |
| PRECACHE | enabled or yes | Enables the precache for Debian, Ubuntu, Debian Security, and Docker |

## Example usage

```bash
docker run -d \
  --name apt-cacher-ng \
  -p 3142:3142 \
  -e TZ="Europe/London" \
  -v /data/apt-cacher-ng:/var/cache/apt-cacher-ng \
  modem7/apt-cacher-ng
```

## Docker Compose example
```yaml
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

```bash
Acquire::http::Proxy "http://<docker-host>:3142";
```

Or a one liner for Debian/Ubuntu hosts:
```bash
echo "Acquire::http::Proxy \"http://<docker-host>:3142\";" | sudo tee /etc/apt/apt.conf.d/00proxy
```

You can also bypass the apt caching server on a per client basis by using the following syntax in your `/etc/apt/apt.conf` file:

```bash
Acquire::HTTP::Proxy::<repo-url> "DIRECT";
```

For example:

```bash
Acquire::HTTP::Proxy::get.docker.com "DIRECT";
Acquire::HTTP::Proxy::download.virtualbox.org "DIRECT";
```

Note:  The above assumes that you are mapping port 3142 on the docker host and 3142 is accessible from all machines.

You can also update the /etc/apt-cacher-ng/acng.conf and add one or more `PassThroughPattern` lines to force clients to bypass a repository:

```bash
PassThroughPattern: get\.docker\.com
PassThroughPattern: download\.virtualbox\.org
```

## Getting https://download.docker.com to cache
If you want to cache your Docker.com downloads, you'll need to change the repo on your client from https to http.

For example, if you're following the [Ubuntu install](https://docs.docker.com/engine/install/ubuntu/) instructions, you'll need to do change the following:

Instead of
```bash
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

Change to:
```bash
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] http://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

---

Based on the work from [mbentley](https://github.com/mbentley/docker-apt-cacher-ng) and [sameersbn](https://github.com/sameersbn/docker-apt-cacher-ng).
