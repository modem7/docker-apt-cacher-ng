#!/bin/bash

# set TZ
export TZ
TZ="${TZ:-Europe/London}"

# setting permissions on /var/cache/apt-cacher-ng, /var/log/apt-cacher-ng, and /var/run/apt-cacher-ng
echo -n "INFO: Setting permissions on /var/cache/apt-cacher-ng, /var/log/apt-cacher-ng, and /var/run/apt-cacher-ng..."
chown -R apt-cacher-ng:apt-cacher-ng /var/cache/apt-cacher-ng /var/log/apt-cacher-ng /var/run/apt-cacher-ng
echo -e "done"

# run CMD
echo "INFO: entrypoint complete; executing CMD '${*}'"
exec "${@}"
