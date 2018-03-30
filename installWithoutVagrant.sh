#!/bin/bash

# This is to install directly in the linux box without vagrant
# in order to run this in linux, this script is to replace following things in vagrant_shell/dep.sh
# replace vagrant:vagrant as your_user:your_user
# replace /vagrant/ as your path to this git local repository root path, such as /home/df/github/lab_env/
# back up the .profile in ~ and run this modified scripts

set -e

if [ -z ${install_dir} ]; then
    CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
else
    CURRENT_DIR=${install_dir}
fi

REPLACE_FILE=${CURRENT_DIR}/vagrant_shell/deb.sh
CURRENT_DIR_REPLACE=$(echo ${CURRENT_DIR}/ | sed "s/\//\\\\\//g")

echo "setup environment for user:"${USER}

cp ~/.profile ~/.profile.bk
cp ${REPLACE_FILE} ${CURRENT_DIR}
sed -i "s/\/home\/vagrant/\/home\/${USER}/g" ${CURRENT_DIR}/deb.sh       ## replace /home/vagrant to /home/df
sed -i "s/\/vagrant\//${CURRENT_DIR_REPLACE}/g" ${CURRENT_DIR}/deb.sh    ## replace /vagrant/ to ${CURRENT_DIR}
sed -i "s/vagrant:vagrant/${USER}:${USER}/g" ${CURRENT_DIR}/deb.sh       ## replace ownership
chmod +x ${CURRENT_DIR}/deb.sh
${CURRENT_DIR}/deb.sh
rm -r ${CURRENT_DIR}/deb.sh