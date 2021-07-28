#!/usr/bin/env bash
echo "---- START: install_chrome_remote_desktop.sh -------" 
set -eu
# set options:
#  -x : enable debug
#  -e : chain all commands  with &&-operator, one fails = script fails
#  -u : prints error if unassigned variable is used and exits with error

wget -q https://dl.google.com/linux/direct/chrome-remote-desktop_current_amd64.deb
dpkg -i /tmp/xWSL/deb/chrome-remote-desktop_current_amd64.deb

echo "---- END: install_chrome_remote_desktop -------"
