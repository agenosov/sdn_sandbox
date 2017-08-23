#!/bin/bash

# Create namespaces
ip netns add h1
ip netns add h2
ip netns add h3

# Create switch
ovs-vsctl add-br s1

# Create links
ip link add h1-eth0 type veth peer name s1-eth1
ip link add h2-eth0 type veth peer name s1-eth2
ip link add h3-eth0 type veth peer name s1-eth3

echo "Links created:"
ip link show

# Move host ports into namespaces
ip link set h1-eth0 netns h1
ip link set h2-eth0 netns h2
ip link set h3-eth0 netns h3

echo "Verify that host ports were moved into separate namespaces:"
ip link show

# Connect switch ports with OVS
ovs-vsctl add-port s1 s1-eth1
ovs-vsctl add-port s1 s1-eth2
ovs-vsctl add-port s1 s1-eth3

# Setup OPF controller
#echo "Setting up controller"
ovs-vsctl set-controller s1 tcp:127.0.0.1
# TODO: what is this?
#ovs-controller ptcp:&
ovs-vsctl show

# Configure network
sudo ip netns exec h1 ifconfig h1-eth0 10.0.0.1
sudo ip netns exec h1 ifconfig lo up
ifconfig s1-eth1 up

sudo ip netns exec h2 ifconfig h2-eth0 10.0.0.2
sudo ip netns exec h2 ifconfig lo up
ifconfig s1-eth2 up

sudo ip netns exec h3 ifconfig h3-eth0 10.0.0.3
sudo ip netns exec h3 ifconfig lo up
ifconfig s1-eth3 up

# Verify connectivity
ip netns exec h1 ping -c1 10.0.0.2
