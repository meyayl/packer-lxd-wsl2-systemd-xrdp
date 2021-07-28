#!/usr/bin/env bash
set -eu
echo "---- START: cleanup.sh -------"

SSH_USER=${SSH_USERNAME:-vagrant}
DISK_USAGE_BEFORE_CLEANUP=$(df -h)

# Disable the release upgrader
echo "==> Disabling the release upgrader"
sed -i.bak 's/^Prompt=.*$/Prompt=never/' /etc/update-manager/release-upgrades

# Disable periodic upgrades
echo "==> Disabling periodic apt upgrades"
echo 'APT::Periodic::Enable "0";' >> /etc/apt/apt.conf.d/10periodic

# Make sure udev does not block our network - http://6.ptmc.org/?p=164
echo "==> Cleaning up udev rules"
rm -rf /dev/.udev/

echo "==> Cleaning up leftover dhcp leases"

if [ -d "/var/lib/dhcp3" ]; then
    rm /var/lib/dhcp3/*
fi

UBUNTU_VERSION=$(lsb_release -sr)
# Add delay to prevent "vagrant reload" from failing
echo "pre-up sleep 2" >> /etc/network/interfaces

echo "==> Cleaning up tmp"
rm -rf /tmp/*

echo "==> Installed packages"
dpkg --get-selections | grep -v deinstall

# Remove Bash history
unset HISTFILE
rm -f /root/.bash_history
rm -f /home/${SSH_USER}/.bash_history

# Clean up log files
find /var/log -type f | while read f; do echo -ne '' > "${f}"; done;

echo "==> Clearing last login information"
>/var/log/lastlog
>/var/log/wtmp
>/var/log/btmp

echo "---- END: cleanup.sh -------"
