#!/usr/bin/env bash
set -eu
# set options:
#  -x : enable debug
#  -e : chain all commands  with &&-operator, one fails = script fails
#  -u : prints error if unassigned variable is used and exits with error
export DEBIAN_FRONTEND=noninteractive

# install ansible
echo "==> Installing ansible and dependencies."
. /etc/lsb-release
if [[ "${DISTRIB_RELEASE}" != "20.04" ]]; then
  # the "|| echo" after the command is a workaround required during hyperv builds. It works regadlress of the timeout problem. 
  sudo apt-add-repository --yes --update ppa:ansible/ansible || echo "Adding ppa:ansible/ansible exited with $?" && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 7BB9C367
fi
sudo apt-get --yes -o Dpkg::Options::="--force-confnew" install ansible
echo "==> Installed ansible"


