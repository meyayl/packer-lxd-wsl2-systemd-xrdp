#!/usr/bin/env bash
echo "---- START: minimize.sh -------"
set -eu
# set options:
#  -x : enable debug
#  -e : chain all commands  with &&-operator, one fails = script fails
#  -u : prints error if unassigned variable is used and exits with error

echo "==> Installed packages before cleanup"
dpkg --get-selections | grep -v deinstall

echo "==> Removing development packages"
dpkg --list | awk '{ print $2 }' | grep -- '-dev$' | xargs apt-get -y purge

echo "==> Removing obsolete networking components"
apt-get --yes purge ppp pppconfig pppoeconf
echo "==> Removing other oddities"
apt-get --yes purge popularity-contest installation-report wireless-tools wpasupplicant

# Exlude the files we don't need w/o uninstalling linux-firmware
echo "==> Setup dpkg excludes for linux-firmware"
cat <<_EOF_ | cat >> /etc/dpkg/dpkg.cfg.d/excludes
#BEGIN
path-exclude=/lib/firmware/*
path-exclude=/usr/share/doc/linux-firmware/*
#END
_EOF_

# Delete the massive firmware packages
rm -rf /lib/firmware/*
rm -rf /usr/share/doc/linux-firmware/*

# Clean up the apt cache
apt-get --yes autoremove --purge
apt-get --yes autoclean
apt-get --yes clean

echo "==> Removing APT files"
find /var/lib/apt -type f | xargs rm -f
#echo "==> Removing any docs"
echo "==> Removing caches"
find /var/cache -type f -exec rm -rf {} \;
# delete any logs that have built up during the install
find /var/log/ -name *.log -exec rm -f {} \;

echo "---- END: minimize.sh -------"
