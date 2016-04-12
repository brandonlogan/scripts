mysql -uroot -ppassword -e "drop database neutron; create database neutron;"
quark-db-manage --config-file /etc/neutron/neutron.conf upgrade head
pkill neutron-server
sed -i '/core_plugin =.*/c\core_plugin = quark.plugin.Plugin' /etc/neutron/neutron.conf
sed -i '/service_plugins =.*/c\' /etc/neutron/neutron.conf
screen -r -p q-svc -X stuff '/usr/local/bin/neutron-server --config-file /etc/neutron/neutron.conf --config-file /etc/neutron/plugins/ml2/ml2_conf.ini & echo $! >/opt/stack/status/stack/q-svc.pid; fg || echo "q-svc failed to start" | tee "/opt/stack/status/stack/q-svc.failure"'$(echo -ne '\015') 
sleep 5
/home/bran3993/scripts/add_mac_addresses_to_quark.py
supernova neutron-ds-demo net-create scip-net
supernova neutron-ds-demo subnet-create --name scip-subnet scip-net 50.0.0.0/24
mysql -uroot -ppassword -e "update neutron.quark_subnets set segment_id='floating_ip';"
supernova neutron-ds-demo net-create lb-ha-net
supernova neutron-ds-demo subnet-create --name lb-ha-subnet lb-ha-net 10.0.0.0/24
supernova neutron-ds-demo port-create --name ha-port1 lb-ha-net
supernova neutron-ds-demo port-create --name ha-port2 lb-ha-net
