#!/bin/bash
neutron="supernova neutron-ds-demo"
nova="supernova nova-ds-demo"
function setup_neutron_resources {
    $neutron net-create user-net
    $neutron subnet-create --name user-subnet user-net 10.2.2.0/24
    $neutron security-group-rule-create default --protocol icmp
    $neutron security-group-rule-create default --protocol tcp --port-range-min 22 --port-range-max 22
    $neutron security-group-rule-create default --protocol tcp --port-range-min 80 --port-range-max 80
}

function create_member {
    $nova boot --image $($nova image-list | awk '/cirros/ {print $2}') --flavor 1 --nic net-id=$($nova net-list | awk '/user-net/ {print $2}') member1
    status=$($nova show member1 | awk '/status/ {print $4}')
    while [ "$status" != "ACTIVE" ]
    do
        sleep 2
        status=$($nova show member1 | awk '/status/ {print $4}')
    done
}
function start_member_web_service {
    ip=$($nova show member1 | awk '/user-net network/ {print $5}')
    net_id=$($neutron net-show user-net | awk '/ id / {print $4}')
    ns_name="qdhcp-$net_id"
    SERVE_TRAFFIC="while true; do { echo -e 'HTTP/1.1 200 OK\r\n'; echo -e 'member1'; } | sudo nc -l -p 80; done &"
    #SERVE_TRAFFIC="ls"
    echo "sudo ip netns exec $ns_name sshpass -p cubswin:\) ssh -oUserKnownHostsFile=/dev/null -oStrictHostKeyChecking=no -oCheckHostIP=no cirros@$ip"
    sudo ip netns exec $ns_name sshpass -p cubswin:\) ssh -oUserKnownHostsFile=/dev/null -oStrictHostKeyChecking=no -oCheckHostIP=no cirros@$ip $SERVE_TRAFFIC
    while [ $? -ne 0 ]
    do
        sleep 10
        echo "sudo ip netns exec $ns_name sshpass -p cubswin:\) ssh -oUserKnownHostsFile=/dev/null -oStrictHostKeyChecking=no -oCheckHostIP=no cirros@$ip"
        sudo ip netns exec $ns_name sshpass -p cubswin:\) ssh -oUserKnownHostsFile=/dev/null -oStrictHostKeyChecking=no -oCheckHostIP=no cirros@$ip $SERVE_TRAFFIC
    done
}
function wait_for_lb_active {
    echo "Waiting for $1 to become ACTIVE..."
    status=$($neutron lbaas-loadbalancer-show $1 | awk '/provisioning_status/ {print $4}')
    while  [ "$status" != "ACTIVE" ]
     do
        sleep 2
        status=$($neutron lbaas-loadbalancer-show $1 | awk '/provisioning_status/ {print $4}')
        if [ $status == "ERROR" ]
         then
            echo "$1 ERRORED. Exiting."
            exit 1;
        fi
     done
}
setup_neutron_resources
create_member
start_member_web_service
ip=$($nova show member1 | awk '/user-net network/ {print $5}')
$neutron lbaas-loadbalancer-create --name lb1 private-subnet
wait_for_lb_active "lb1"
$neutron lbaas-listener-create --name listener1 --loadbalancer lb1 --protocol HTTP --protocol-port 80
wait_for_lb_active "lb1"
$neutron lbaas-pool-create --name pool1 --listener listener1 --protocol HTTP --lb-algorithm ROUND_ROBIN
wait_for_lb_active "lb1"
$neutron lbaas-member-create --address $ip --subnet user-subnet --protocol-port 80 pool1
wait_for_lb_active "lb1"
vip=$($neutron lbaas-loadbalancer-show lb1 | awk '/vip_address/ {print $4}')
echo "Testing connection to $vip"
output=$(curl $vip 2>/dev/null)
if [ $output == "member1" ]
then
    echo "Successful Connection!"
else
    echo "Connection Failed!"
fi
