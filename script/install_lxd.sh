#!/usr/bin/env bash
echo "---- START: install_lxd.sh -------" 
set -eu
# set options:
#  -x : enable debug
#  -e : chain all commands  with &&-operator, one fails = script fails
#  -u : prints error if unassigned variable is used and exits with error

SSH_USER=${SSH_USERNAME:-vagrant}

if [[ "${PACKER_BUILDER_TYPE}" == "lxc" ]];then
    modprobe loop
    apt-get install -yqq squashfuse snap snapd
    systemctl restart snapd
fi
snap install lxd
usermod --append --groups lxd ${SSH_USER}
echo "---- END: install_lxd.sh -------"
