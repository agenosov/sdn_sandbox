A bunch of scripts for organizing virtual network on a single host.

Mostly they duplicate what a Mininet tool allows.
With a simple purpose to learn what Mininet does under the hood and how it communicates with Open vSwitch.

* *virtual_network_setup.sh* builds the following topology:
    - a single switch (Open vSwitch)
    - this switch is controlled by an SDN controller which is expected (_but may not_) to be launched on the same host
    - a three hosts connected to the switch
This setup is motivated by corresponding topic from the [LFS265 introductory course](https://training.linuxfoundation.org/training/software-defined-networking-fundamentals/).
