### Running FAUCET in a python virtual env

* virtualenv venv && . ./venv/bin/activate
* install FAUCET while *in the venv*

#### Control simple topology (one switch with 4 ports connected to hosts)

* mn --topo single,4 --mac --switch ovs --controller remote

* export FAUCET_CONFIG = ./faucet_simple_topo.yml

#### Control DC topology

* mn --custom ../inside-openflow-course/datacenterConfigurable.py --topo dcconfigurable,4,4 --mac --switch ovs --controller remote

* export FAUCET_CONFIG=./faucet_datacenter_4_4.yml

* ryu-manager ./faucet/src/ryu_faucet/org/onfsdn/faucet/faucet.py
* config for testing _misc VLANs_: ./faucet_datacenter_4_4_misc_vlans.yml


### Additional packages for running tests for FAUCET

* vlan (see what's inside: _dpkg -L vlan_)

* [WAS INSTALLED] fuser (part of the _psmisc_) - *identifies processes that are using files or sockets*

* [WAS INSTALLED] netcat-openbsd - provides the _nc_ utility to manipulate TCP/UDP connections
