#!/bin/bash

# This is to install directly in the linux box without vagrant
# in order to run this in linux, this script is to replace following things in vagrant_shell/dep.sh
# replace vagrant:vagrant as your_user:your_user
# replace /vagrant as your path to this git local repository root path, such as /home/df/github/lab_env/
# back up the .profile in ~ and run this modified scripts

set -e

if [ -z ${install_dir} ]; then
    CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
else
    CURRENT_DIR=${install_dir}
fi

REPLACE_FILE=${CURRENT_DIR}/vagrant_shell/deb.sh

cp ~/.profile ~/.profile.bk
cp ${REPLACE_FILE} ${CURRENT_DIR}
sed -i 's/\/vagrant/${CURRENT_DIR}/g' ${CURRENT_DIR}/deb.sh
sed -i 's/\vagrant:vagrant/${USER}:${USER}/g' ${CURRENT_DIR}/deb.sh
chmod +x ${CURRENT_DIR}/deb.sh
# ${CURRENT_DIR}/deb.sh