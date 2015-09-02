#!/bin/bash

if [ `ps aux | grep neutron-server | wc -l` -gt 1 ]; then
    kill -9 `ps aux | grep '[n]eutron-server' -m1 | awk '{print $2}'`
fi

sudo PIP_DOWNLOAD_CACHE=/var/cache/pip HTTP_PROXY= HTTPS_PROXY= NO_PROXY= /usr/local/bin/pip install --build=/tmp/pip-build.bE71P -e /opt/stack/neutron

/usr/local/bin/neutron-server --config-file /etc/neutron/neutron.conf --config-file /etc/neutron/plugins/ml2/ml2_conf.ini
