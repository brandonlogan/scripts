#!/bin/bash
 
if [ `ps aux | grep neutron-lbaas-agent | wc -l` -gt 1 ]; then
    kill -9 `ps aux | grep '[n]eutron-lbaas-agent' -m1 | awk '{print $2}'`
fi
 
sudo PIP_DOWNLOAD_CACHE=/var/cache/pip HTTP_PROXY= HTTPS_PROXY= NO_PROXY= /usr/local/bin/pip install --build=/tmp/pip-build.bE71P -e /opt/stack/neutron
