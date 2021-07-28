#!/usr/bin/env bash
echo "---- START: basics.sh -------"
set -eu
# set options:
#  -x : enable debug
#  -e : chain all commands  with &&-operator, one fails = script fails
#  -u : prints error if unassigned variable is used and exits with error

SSH_USER=${SSH_USERNAME:-vagrant}
export DEBIAN_FRONTEND=noninteractive

echo "==> enable force color in /etc/skel/.bashrc ~/.bashrc"
sed -i -e 's/#force_color_prompt=yes/force_color_prompt=yes/g' /etc/skel/.bashrc
sed -i -e 's/#force_color_prompt=yes/force_color_prompt=yes/g' /home/${SSH_USER}/.bashrc
chown ${SSH_USER}:${SSH_USER} /home/vagrant/.bashrc
sed -i -e 's/#force_color_prompt=yes/force_color_prompt=yes/g' /root/.bashrc

os_package="vim git bash-completion apt-transport-https wget software-properties-common"
echo "==> Installing ${os_package}."
apt-get --yes -o Dpkg::Options::="--force-confnew" install ${os_package}

# git bash completiom
wget https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash --output-document=/etc/bash_completion.d/git-completion.bash

echo "---- END: basics.sh -------"
