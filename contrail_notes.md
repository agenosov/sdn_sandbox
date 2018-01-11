## Key takeaways from the [arch doc](http://www.opencontrail.org/opencontrail-architecture-documentation/#section2)

* Contrail consists of 2 parts: a logically centralized but **physically distributed controller** and a **set of vRouters that serve as software forwarding elements** implemented in the hypervisors of general purpose virtualized servers
* vRouters are responsible for forwarding packets from one virtual machine to other virtual machines via a set of server-to-server tunnels.
* each vRouter has a **user space agent that implements the control plane** and a **kernel module that implements the forwarding engine**

* Provides 3 types of interfaces:
1. NB REST API’s that are used to talk to the Orchestration System and the Applications
2. SB interfaces that are used to talk to network elements (virtual or physical)
3. east-west interface used to peer with other controllers ([BGP](http://www.ietf.org/rfc/rfc4271.txt) is used for it)

* All REST APIs in the system use role-based authorization. Servers establish the identity of clients using TLS authentication and assigns the role(s).


### About Contrail nodes

* The compute nodes in the overall Contrail system host VMs. For these nodes the hypervisor is KVM or Xen. Each compute node contains a vRouter
* The control nodes **receive configuration state** from the configuration nodes using *IF-MAP* (control nodes can subscribe to the subset of configuration in which they are interested)
* The control nodes exchange routes with:
    - other control nodes using *IBGP*
    - the vRouter agents on the compute nodes using *XMPP*
    - the gateway nodes (routers and switches) using *BGP*
    - and also send configuration state using *Netconf* (to **gateway nodes, which connect the tenant virtual networks to physical networks** such as the Internet, a customer VPN, another DC, or to non-virtualized servers)

* Configuration nodes provide a *discovery service*. For the initial service discovery certificates are used for authentication.
* Inside a configuration node, *Redis message bus* is used to deliver changes in high-level data model (received via REST API from Orchestrator) to the Schema transformer (which compiles high-level data model into low-level data model)

* Analytics nodes:
    - communicate with components in control and configuration nodes using an XML-based protocol called *Sandesh* designed specifically for handling high volumes of data
    - provides the NB REST API for querying the analytics database and for retrieving operational state.
    
* **Each component on every node has a Sandesh connection to one of the analytics nodes**.


### About vRouter

* Each vRouter agent is connected to at least two control nodes for redundancy


### About Forwarding Plane

* In the Contrail system, **unknown unicast traffic is dropped instead of being flooded** because the system does not rely on flood-and-learn to fill the MAC tables. It **uses a control plane protocol to fill the MAC tables** and if the destination is not known, there is some other malfunction in the system.


### About Data Model

* The data model consists of an object hierarchy, which is a rooted directed acyclic graph. The root represents the **administrative domain** that the system is responsible for. The administrative domain contains one or more **tenants**.

* The data model for configuration and operational state is defined using *IF-MAP*, with the data itself being kept in a *Cassandra* DB

* Requirements to modules that operate on data models:
1. modules must be event-driven:
    - must **listen for updates on the pub-sub bus** (using *Redis*)
    - when it gets all the information it needs for a particular action, it performs the action
2. module must be restartable:
    - when it crashes or is forcibly restarted, it simply reconnects to the DB, reacquires its state and continues processing
3. must be able to work in a distributed fashion


## Knowledge Gaps

* [BGP-signaled end-system IP/VPNs](https://tools.ietf.org/html/draft-ietf-l3vpn-end-system-01) - the protocol used between the **control-node and the compute-node agents**.
* [BGP MPLS IP VPNs](https://tools.ietf.org/html/rfc4364)
* [MPLS over GRE](https://tools.ietf.org/html/rfc4023) - this's really small RFC, read in order to understand how an overlay network is built. Contrail supports **multiple overlay encapsulations**:
* [VXLAN](https://datatracker.ietf.org/doc/draft-mahalingam-dutt-dcops-vxlan/)
* MPLS over UDP
