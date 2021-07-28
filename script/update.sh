#!/usr/bin/env bash
echo "---- START: update.sh -------"
set -eu
# set options:
#  -x : enable debug
#  -e : chain all commands  with &&-operator, one fails = script fails
#  -u : prints error if unassigned variable is used and exits with error

export DEBIAN_FRONTEND=noninteractive

sed -i 's|http://us.archive.ubuntu.com/ubuntu|http://de.archive.ubuntu.com/ubuntu|g' /etc/apt/sources.list
sed -i 's|http://security.ubuntu.com/ubuntu|http://de.archive.ubuntu.com/ubuntu|g' /etc/apt/sources.list

# Disable periodic upgrades
echo "==> Disabling periodic apt upgrades"
echo 'APT::Periodic::Enable "0";' >> /etc/apt/apt.conf.d/10periodic

echo "==> Updating list of repositories"
# apt-get update does not actually perform updates, it just downloads and indexes the list of packages
apt-get --yes -o Dpkg::Options::="--force-confnew" update
apt-get --yes install apt-utils

if [[ $UPDATE  =~ ^(true|yes|1|TRUE|YES|ON)$ ]]; then
    echo "==> Performing dist-upgrade (all packages and kernel)"
    apt-get --yes -o Dpkg::Options::="--force-confnew" dist-upgrade
fi

echo "---- END: update.sh -------"
