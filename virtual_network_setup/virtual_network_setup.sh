#!/bin/bash

set -euo pipefail

bridge_name=s1

# Failure mode for switch.
# In case of a controller is configured, this mode controls whether the switch is capable of setting up new flows when there's no connection with controller.
failure_mode=secure # standalone|secure

run_as_netns()
{
    netns=$1
    shift
    ip netns exec $netns $@
}

function main
{
    while getopts "m:ch" opt
    do
        case $opt in
            m)
                failure_mode="$OPTARG"
                ;;
            
            c)
                clean_setup
                exit 0
                ;;

            h)
                usage
                exit 0
                ;;

            \?)
                echo "Invalid option -$OPTARG"
                exit 1
                ;;

            :)
                echo "Error: Option -$OPTARG requires an argument"
                exit 1
                ;;
        esac
    done

    if [ "$failure_mode" != "secure" -a "$failure_mode" != "standalone" ]; then
        echo "Invalid failure mode specified"
        usage
        exit 2
    fi
    
    # Create namespaces
    ip netns add h1
    ip netns add h2
    ip netns add h3

    # Create switch
    ovs-vsctl add-br $bridge_name \
        -- set bridge $bridge_name fail_mode=$failure_mode

    # Create links
    link_type=veth
    ip link add h1-eth0 type $link_type peer name $bridge_name-eth1
    ip link add h2-eth0 type $link_type peer name $bridge_name-eth2
    ip link add h3-eth0 type $link_type peer name $bridge_name-eth3

    echo "Links created:"
    ip link show type $link_type
    echo "====================="

    # Move host ports into namespaces
    ip link set h1-eth0 netns h1
    ip link set h2-eth0 netns h2
    ip link set h3-eth0 netns h3

    echo "Verify that host ports were moved into separate namespaces:"
    ip link show type $link_type
    echo "====================="

    # Connect switch ports with OVS
    ovs-vsctl add-port $bridge_name $bridge_name-eth1
    ovs-vsctl add-port $bridge_name $bridge_name-eth2
    ovs-vsctl add-port $bridge_name $bridge_name-eth3
    ovs-vsctl show

    # Setup OPF controller
    ovs-vsctl set-controller $bridge_name tcp:127.0.0.1:6653
    # TODO: make an ability for service controllers to connect to a switch...
    #ovs-vsctl set-controller $bridge_name ptcp:127.0.0.1:6654

    echo "Verify that target controller is specified:"
    ovs-vsctl get-controller $bridge_name
    echo "====================="

    # Configure network
    run_as_netns h1 ifconfig h1-eth0 10.0.0.1
    run_as_netns h1 ifconfig lo up
    ifconfig $bridge_name-eth1 up

    run_as_netns h2 ifconfig h2-eth0 10.0.0.2
    run_as_netns h2 ifconfig lo up
    ifconfig $bridge_name-eth2 up

    run_as_netns h3 ifconfig h3-eth0 10.0.0.3
    run_as_netns h3 ifconfig lo up
    ifconfig $bridge_name-eth3 up

    cat <<EOT
    Virtual network setup is done.
    Verify connectivity by command:
    ip netns exec h1 ping -c1 10.0.0.2
EOT
}

function clean_setup
{
    ovs-vsctl del-br $bridge_name
    if [ $? -ne 0 ] ; then
        echo "Nothing to cleanup. No bridge $bridge_name"
        exit 2
    fi
    ip netns del h3
    ip netns del h2
    ip netns del h1
}

function usage
{
    cat <<EOT
Usage: $(dirname "$0") [OPTION]...

Options:
  -m    Specify failure mode for switch (standalone|secure) (default: secure)

  -c    Clean all setup made previously and exit

  -h    Display this help and exit
EOT
}

main "$@"
