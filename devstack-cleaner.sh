#!/bin/bash

# By default devstack removes all logs,
# so COMPRESS_LOGS defaults to False.
#COMPRESS_LOGS=True

DEVSTACK_DIR=/opt/devstack
source $DEVSTACK_DIR/functions
source $DEVSTACK_DIR/stackrc

# Shutdown running VMs
VMLIST=$(virsh list | grep -E 'instance-[0-9a-fA-F]+' | awk '{print $2;}')
for vm in $VMLIST; do
      virsh destroy $vm
  done
  # Remove all VMs
  VMLIST=$(virsh list --all | grep -E 'instance-[0-9a-fA-F]+' | awk '{print $2;}')
  for vm in $VMLIST; do
        virsh undefine $vm
    done
    virsh list --all

    # nova-api
    pid=$(ps auxw | grep nova-api | grep -v grep | sort -k 9 | head -1 | awk '{print $2;}')
    if [ -n "$pid" ]; then
            kill $pid
        fi
        pids=$(ps auxw | grep -v grep | grep nova-api | awk '{print $2;}')
        if [ -n "$pids" ]; then
                kill $pids
            fi

            # Remove all nwfilters created by nova-compute
            NWFILTERS=$(virsh nwfilter-list | grep nova-instance-instance- | awk '{print $1;}')
            for nwfilter in $NWFILTERS; do
                  virsh nwfilter-undefine $nwfilter
              done

              # Stop running dnsmasq processes
              if is_service_enabled q-dhcp; then
                      ps aux | grep -E '[d]nsmasq.+interface=(tap|ns-)' | grep -v grep
                          pid=$(ps aux | awk '/[d]nsmasq.+interface=(tap|ns-)/ { print $2 }')
                              [ ! -z "$pid" ] && sudo kill -9 $pid
                          fi

                          # Stop metadata agent process
                          ps auxw | grep neutron-ns-metadata-proxy | grep -v grep
                          pids=$(ps auxw | grep neutron-ns-metadata-proxy | grep -v grep | awk '{print $2;}')
                          [ -n "$pids" ] && sudo kill $pids

                          # Stop ipsec process
                          ipsec_data_dir=$DATA_DIR/neutron/ipsec
                          if [ -d $ipsec_data_dir ]; then
                                  pids=$(find $ipsec_data_dir -name 'pluto.pid' -exec cat {} \;)
                              fi
                              if [ -n "$pids" ]; then
                                      sudo kill $pids
                                  fi

                                  # Stop haproxy process
                                  ps auxw | grep haproxy | grep -v grep
                                  pids=$(ps auxw | grep haproxy | grep -v grep | awk '{print $2;}')
                                  [ -n "$pids" ] && sudo kill $pids

                                  # Remove Hybrid ports
                                  NETDEVS=$(ip -o link | cut -d : -f 2 | awk '{print $1;}' | grep ^qvo)
                                  for p in $NETDEVS; do
                                        echo sudo ovs-vsctl del-port br-int $p
                                          sudo ovs-vsctl del-port br-int $p
                                            echo sudo ip link delete $p
                                              sudo ip link delete $p
                                          done
                                          BRIDGES=$(brctl show | grep -v 'bridge name' | awk '{print $1;}' | grep ^qbr)
                                          for b in $BRIDGES; do
                                                echo sudo ifconfig $b down
                                                  sudo ifconfig $b down
                                                    echo sudo brctl delbr $b
                                                      sudo brctl delbr $b
                                                  done

                                                  # Remove ovs-ports whose name
                                                  # is 'tap*****' or 'qr-*****'
                                                  for p in $(sudo ovs-vsctl list-ports br-int | grep -E '^(tap|qr-)'); do
                                                        echo sudo ovs-vsctl del-port br-int $p
                                                          sudo ovs-vsctl del-port br-int $p
                                                      done
                                                      for p in $(sudo ovs-vsctl list-ports br-ex | grep -E '^(tap|qg-)'); do
                                                            echo sudo ovs-vsctl del-port br-ex $p
                                                              sudo ovs-vsctl del-port br-ex $p
                                                          done

                                                          #/opt/openstack/neutron/bin/neutron-netns-cleanup --verbose --force \
                                                              #  --config-file
                                                          #  /etc/neutron/neutron.conf
                                                          #  \
                                                              #  --config-file
                                                          #  /etc/neutron/dhcp_agent.ini
                                                          for ns in `ip netns`; do
                                                                sudo ip netns delete $ns
                                                            done

                                                            for br in `sudo ovs-vsctl list-br`; do
                                                                  sudo ovs-vsctl del-br $br
                                                                    echo ovs-vsctl del-br $br
                                                                done

                                                                TAPS=$(ip -o link | awk '{print $2;}' | cut -d : -f 1 | grep -E '^tap')
                                                                for i in $TAPS; do
                                                                      sudo ip link delete $i
                                                                        echo ip link delete $i
                                                                    done

                                                                    # Remove
                                                                    # bridge
                                                                    # created
                                                                    # by linux
                                                                    # bridge
                                                                    # plugin
                                                                    LBS=$(brctl show | grep -v 'bridge name' | awk '{print $1;}' | grep ^brq)
                                                                    for br in $LBS; do
                                                                          sudo ifconfig $br down
                                                                            sudo brctl delbr $br
                                                                              echo brctl delbr $br
                                                                          done

                                                                          # Flush
                                                                          # iptables
                                                                          # chains
                                                                          # and
                                                                          # rules
                                                                          for table in filter nat; do
                                                                                sudo iptables -F -t $table
                                                                                  for chain in `sudo iptables -L -v -n -t $table | grep '^Chain ' | grep references | awk '{print $2;}'`; do
                                                                                          sudo iptables -t $table -X $chain
                                                                                              echo "Delete iptable chain: $table:$chain"
                                                                                                done
                                                                                            done

                                                                                            # devstack
                                                                                            # sometimes
                                                                                            # fails
                                                                                            # to
                                                                                            # talk
                                                                                            # with
                                                                                            # rabbitmq
                                                                                            # without
                                                                                            # stop
                                                                                            # and
                                                                                            # start.
                                                                                            sudo service rabbitmq-server stop
                                                                                            sudo service rabbitmq-server start

                                                                                            # Remove
                                                                                            # VM
                                                                                            # images
                                                                                            rm -vrf /opt/openstack/data/glance/*
                                                                                            rm -vrf /opt/openstack/data/nova/*

                                                                                            # Remove
                                                                                            # account
                                                                                            # rc
                                                                                            # files
                                                                                            rm -rf $DEVSTACK_DIR/accrc

                                                                                            echo "=============================="
                                                                                            echo "Status"
                                                                                            echo "=============================="

                                                                                            brctl show
                                                                                            echo '---------'
                                                                                            sudo ovs-vsctl show
                                                                                            echo '---------'
                                                                                            ip link
                                                                                            echo '---------'
                                                                                            ip netns

                                                                                            if [ "$COMPRESS_LOGS" = "True" ]; then
                                                                                                  echo "Compressing devstack logs..."
                                                                                                    SYMLINKFILES=/tmp/symlinked-log.$$
                                                                                                      find /opt/openstack/logs -type l | xargs ls -l | sed -e 's/^.* -> //' > $SYMLINKFILES
                                                                                                        TARGETLOGS=$(find /opt/openstack/logs -type f | grep -v -f $SYMLINKFILES | grep -v '.gz$')
                                                                                                          if [ -n "$TARGETLOGS" ]; then
                                                                                                                    gzip --verbose $TARGETLOGS
                                                                                                                      fi
                                                                                                                  fi

                                                                                                                  echo
                                                                                                                  df -h
