#!/bin/bash

function get_link {
    name=$1
    link=$(ip link | awk "/: ${name}:"'/ {print $1}')
    echo ${link}
}

bridge=$(get_link "main-br")
ether=$(get_link "enp")
wifi=$(get_link "wlp")

if [[ -z "${bridge// }" ]]
then
    ip link add name main-br type bridge
    ip link set main-br up
    ip addr add 192.168.2.1/24 dev main-br
fi

if [[ -z "${ether// }" ]]
then
    iptables -t nat -A POSTROUTING -o enp0s20u1u1 -j MASQUERADE
fi

if [[ -z "${wifi// }" ]]
then
    iptables -t nat -A POSTROUTING -o wlp2s0 -j MASQUERADE
fi

sysctl net.ipv4.ip_forward=1
modprobe openvswitch
modprobe ebtables
modprobe kvm
modprobe ip6_tables ip6table_filter ip6table_mangle ip6t_REJECT
modprobe br_netfilter
