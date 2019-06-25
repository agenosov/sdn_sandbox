#!/bin/bash

# TODO: introduce options for:
# - specifying failure mode for bridge
# - cleaning up

# Create namespaces
ip netns add h1
ip netns add h2
ip netns add h3

# Create switch
bridge_name=s1
failure_mode=secure # standalone|secure
ovs-vsctl add-br $bridge_name

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
ovs-vsctl set-controller $bridge_name tcp:127.0.0.1:6653 ptcp:127.0.0.1:6654

echo "Set failure mode"
ovs-vsctl set-fail-mode $bridge_name $failure_mode

echo "Verify that target controller is specified:"
ovs-vsctl get-controller $bridge_name
echo "====================="

# Configure network
sudo ip netns exec h1 ifconfig h1-eth0 10.0.0.1
sudo ip netns exec h1 ifconfig lo up
ifconfig $bridge_name-eth1 up

sudo ip netns exec h2 ifconfig h2-eth0 10.0.0.2
sudo ip netns exec h2 ifconfig lo up
ifconfig $bridge_name-eth2 up

sudo ip netns exec h3 ifconfig h3-eth0 10.0.0.3
sudo ip netns exec h3 ifconfig lo up
ifconfig $bridge_name-eth3 up

# Verify connectivity
ip netns exec h1 ping -c1 10.0.0.2
