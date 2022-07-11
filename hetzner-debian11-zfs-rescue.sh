#!/bin/bash

: <<'end_header_info'
(c) Andrey Prokopenko job@terem.fr
fully automatic script to install Debian 11 with ZFS root on Hetzner VPS
WARNING: all data on the disk will be destroyed
How to use: add SSH key to the rescue console, set it OS to linux64, then press "mount rescue and power cycle" button
Next, connect via SSH to console, and run the script
Answer script questions about desired hostname, ZFS ARC cache size et cetera
To cope with network failures its higly recommended to run the script inside screen console
screen -dmS zfs
screen -r zfs
To detach from screen console, hit Ctrl-d then a
end_header_info

set -o errexit
set -o pipefail
set -o nounset

echo "===========remove unused kernels in rescue system========="
for kver in $(find /lib/modules/* -maxdepth 0 -type d | grep -v "$(uname -r)" | cut -s -d "/" -f 4); do
  apt purge --yes "linux-headers-$kver"
  apt purge --yes "linux-image-$kver"
done

echo "======= installing zfs on rescue system =========="
  echo "zfs-dkms zfs-dkms/note-incompatible-licenses note true" | debconf-set-selections
  apt-get install --yes software-properties-common
  apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 8CF63AD3F06FC659
  add-apt-repository 'deb http://ppa.launchpad.net/jonathonf/zfs/ubuntu focal main'
  apt update
  apt install --yes zfs-dkms zfsutils-linux
  add-apt-repository -r 'deb http://ppa.launchpad.net/jonathonf/zfs/ubuntu focal main'
  apt update
  zfs --version

echo "======= zfs installed on rescure system =========="
