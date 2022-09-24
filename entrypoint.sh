#!/bin/bash

# set TZ
echo -n "INFO: Setting TZ..."
TZ="${TZ:-Europe/London}"
echo -e "done. Timezone is set to $TZ"

# Set Precache
echo -n "INFO: Checking if Precache is enabled..."
if [[ "$PRECACHE" =~ ^(enabled|yes)$ ]]; then
    echo -n "Applying Precache settings..."
    echo 'PrecacheFor: debrep/dists/*/*/*/Packages* uburep/dists/*/*/*/Packages* secdeb/dists/*/*/*/Packages* dockerrep/dists/*/*/*/Packages*' >> /etc/apt-cacher-ng/acng.conf
    echo -e "done."
else
    echo -e "Precache disabled."
fi

# setting permissions on /var/cache/apt-cacher-ng, /var/log/apt-cacher-ng, and /var/run/apt-cacher-ng
echo -n "INFO: Setting permissions on /var/cache/apt-cacher-ng, /var/log/apt-cacher-ng, and /var/run/apt-cacher-ng..."
chown -R apt-cacher-ng:apt-cacher-ng /var/cache/apt-cacher-ng /var/log/apt-cacher-ng /var/run/apt-cacher-ng
echo -e "done"

# run CMD
echo "INFO: entrypoint complete; executing CMD '${*}'"
exec "$@"
