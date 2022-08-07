#!/bin/bash

: <<'end_header_info'
(c) Andrey Prokopenko job@terem.fr
(c) Thomas Westfeld westfeld@mac.com
fully automatic script to install ZFS support on a Hetzner rescue image
NO DATA on the VPS will be destroyed by running this script
How to use: add SSH key to the rescue console, set it OS to linux64, then press "mount rescue and power cycle" button
Next, connect via SSH to console, and run the script
After the script has finished you have all the ZFS tools like zpool, zfs etc. available on the rescue image
The ZFS support is not persisted on the rescue image: every time you load into the image, this script has to be run
To cope with network failures its higly recommended to run the script inside screen console
screen -dmS zfs
screen -r zfs
To detach from screen console, hit Ctrl-d then a
end_header_info

set -o errexit
set -o pipefail
set -o nounset

# shellcheck disable=SC2120
function print_step_info_header {
  echo -n "
###############################################################################
# ${FUNCNAME[1]}"

  if [[ "${1:-}" != "" ]]; then
    echo -n " $1" 
  fi


  echo "
###############################################################################
"
}

function display_intro_banner {
  # shellcheck disable=SC2119
  print_step_info_header

  local dialog_message='Hello!
This script installs ZFS support on the Hetzner rescue system.
After the script has finished you have all the ZFS tools like zpool, zfs etc. available on the rescue image.
NO DATA ON THE DISKS ARE AFFECTED BY RUNNING THIS SCRIPT.
The ZFS support is not persisted on the rescue image: every time you load into the image, this script has to be run.
In order to stop the procedure, hit Esc twice during dialogs (excluding yes/no ones), or Ctrl+C while any operation is running.
'
  dialog --msgbox "$dialog_message" 30 100
}

function check_prerequisites {
  # shellcheck disable=SC2119
  print_step_info_header
  if [[ $(id -u) -ne 0 ]]; then
    echo 'This script must be run with administrative privileges!'
    exit 1
  fi
  if ! dpkg-query --showformat="\${Status}" -W dialog 2> /dev/null | grep -q "install ok installed"; then
    apt install --yes dialog
  fi
}

#################### MAIN ################################
export LC_ALL=en_US.UTF-8
export NCURSES_NO_UTF8_ACS=1

check_prerequisites

display_intro_banner

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
  find /usr/local/sbin/ -type l -exec rm {} +
echo "======= zfs installed on rescue system =========="
  zfs --version

