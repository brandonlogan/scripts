#!/bin/bash

match1='service_provider=LOADBALANCER:Haproxy:neutron.services.loadbalancer.drivers.haproxy.plugin_driver.HaproxyOnHostPluginDriver:default'
insert1='service_provider=LOADBALANCERV2:AgentlessHaproxy:neutron.services.loadbalancer.drivers.haproxy.synchronous_namespace_driver.HaproxyNSDriver:default'
 
match2='service_plugins = neutron.services.l3_router.l3_router_plugin.L3RouterPlugin,neutron.services.loadbalancer.plugin.LoadBalancerPlugin'
insert2='service_plugins = neutron.services.l3_router.l3_router_plugin.L3RouterPlugin,neutron.services.loadbalancer.plugin.LoadBalancerPluginv2'
 
file='/etc/neutron/neutron.conf'

if [ `ps aux | grep neutron-server | wc -l` -gt 1 ]; then
    kill -9 `ps aux | grep '[n]eutron-server' -m1 | awk '{print $2}'`
fi

if [ ! "$(grep "$insert1" $file)" ]; then
    sed -i "s/$match1/$insert1/" $file
fi

if [ ! "$(grep "$insert2" $file)" ]; then
    sed -i "s/$match2/$insert2/" $file
fi


#cp ~/neutron.conf /etc/neutron/neutron.conf

sudo PIP_DOWNLOAD_CACHE=/var/cache/pip HTTP_PROXY= HTTPS_PROXY= NO_PROXY= /usr/local/bin/pip install --build=/tmp/pip-build.bE71P -e /opt/stack/neutron
