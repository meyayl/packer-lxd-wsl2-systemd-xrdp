#!/usr/bin/env bash
echo "---- START: wsl.sh -------"
set -eu
# set options:
#  -x : enable debug
#  -e : chain all commands  with &&-operator, one fails = script fails
#  -u : prints error if unassigned variable is used and exits with error

cat << EOF > /etc/wsl.conf
[automount]
enabled = true
options = "metadata,uid=1000,gid=1000,umask=22,fmask=11,case=off"
mountFsTab = true
crossDistro = true

[network]
generateHosts = true
generateResolvConf = true

[interop]
enabled = true
appendWindowsPath = true

[user]
default = ${SSH_USERNAME}
EOF

export DEBIAN_FRONTEND=noninteractive
apt-get install -yqq daemonize dbus-user-session fontconfig ubuntu-wsl wslu
git clone https://github.com/meyayl/ubuntu-wsl2-systemd-script /tmp/ubuntu-wsl2-systemd-script
cd /tmp/ubuntu-wsl2-systemd-script

./install.sh --force --no-wslg | true

echo "---- END: wsl.sh -------"