#!/usr/bin/env bash
echo "---- START: sshd.sh -------"
set -eu
# set options:
#  -x : enable debug
#  -e : chain all commands  with &&-operator, one fails = script fails
#  -u : prints error if unassigned variable is used and exits with error

echo "UseDNS no" >> /etc/ssh/sshd_config

echo "---- END: sshd.sh -------"
