#!/bin/bash
neutron="supernova neutron-ds-demo"
nova="supernova nova-ds-demo"

function add_security_group_rules {
    $neutron security-group-rule-create default --protocol icmp
    $neutron security-group-rule-create default --protocol tcp --port-range-min 22 --port-range-max 22
    $neutron security-group-rule-create default --protocol tcp --port-range-min 80 --port-range-max 80
}

function create_network_and_subnet {
    net_name=$1
    subnet_name=$2
    cidr=$3
    $neutron net-create ${net_name}
    $neutron subnet-create --name ${subnet_name} ${net_name} ${cidr}
}

function get_server_ip {
    name=$1
    net_name=$2
    member_ip=$($nova show ${name} | awk "/${net_name} "'network/ {print $5}')
    echo $member_ip
}

function boot_server {
    name=$1
    net_name=$2
    $nova boot --image $($nova image-list | awk '/cirros/ {print $2}') --flavor 1 --nic net-id=$($nova net-list | awk "/${net_name}/ "'{print $2}') ${name}
    status=$($nova show ${name} | awk '/status/ {print $4}')
    while [ "$status" != "ACTIVE" ]
    do
        sleep 2
        status=$($nova show ${name} | awk '/status/ {print $4}')
    done
}

function start_web_service {
    name=$1
    net_name=$2
    ip=$($nova show ${name} | awk "/${net_name}"' network/ {print $5}')
    net_id=$($neutron net-show ${net_name} | awk '/ id / {print $4}')
    ns_name="qdhcp-$net_id"
    SERVE_TRAFFIC="while true; do { echo -e 'HTTP/1.1 200 OK\r\n'; echo -e '${name}'; } | sudo nc -l -p 80; done &"
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

function get_vip {
    vip=$($neutron lbaas-loadbalancer-show lb1 | awk '/vip_address/ {print $4}')
    echo $vip
}

function create_lb {
    vip_subnet=$1
    $neutron lbaas-loadbalancer-create --name lb1 ${vip_subnet}
    wait_for_lb_active "lb1"
    $neutron lbaas-listener-create --name listener1 --loadbalancer lb1 --protocol HTTP --protocol-port 80
    wait_for_lb_active "lb1"
    $neutron lbaas-pool-create --name pool1 --listener listener1 --protocol HTTP --lb-algorithm ROUND_ROBIN
    wait_for_lb_active "lb1"
}

function add_member {
    ip=$1
    subnet=$2
    $neutron lbaas-member-create --address ${ip} --subnet ${subnet} --protocol-port 80 pool1
}

function create_member_on_network {
    net_name=$1
    subnet_name=$2
    member_name=$3
    boot_server ${member_name} ${net_name}
    member_ip=$(get_server_ip ${member_name} ${net_name})
    start_web_service ${member_name} ${net_name}
    add_member ${member_ip} ${subnet_name}
    wait_for_lb_active "lb1"
}

function create_network_and_member {
    net_name=$1
    subnet_name=$2
    cidr=$3
    member_name=$4
    create_network_and_subnet ${net_name} ${subnet_name} ${cidr}
    create_member_on_network ${net_name} ${subnet_name} ${member_name}
}

function validate_connection {
    vip=$1
    member_name=$2
    echo "Testing connection to $vip"
    output=$(curl $vip 2>/dev/null)
    if [ $output = ${member_name} ]
    then
        echo "Successful Connection!"
    else
        echo "Connection Failed!"
    fi
}

add_security_group_rules
create_lb "private-subnet"
vip=$(get_vip)

net_name="user-net"
member_name="member1"
subnet_name="user-subnet"
cidr="10.2.2.0/24"
create_network_and_member ${net_name} ${subnet_name} ${cidr} ${member_name}
create_network_and_member "user-net2" "user-subnet2" "10.3.3.0/24" "member2"
create_member_on_network ${net_name} ${subnet_name} "member3"

validate_connection ${vip} ${member_name}

