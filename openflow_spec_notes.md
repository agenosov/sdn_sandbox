## Questions at Stackoverflow related to learning OPF

* [what if a flow table is full](https://stackoverflow.com/questions/49275450/how-does-a-flow-entry-change-in-an-open-flow)


## Common terms

* Flow entry in a switch flow table consists of:
    - match fields
    - a priority for matching
    - counters
    - a set of instructions to apply to matching packet.

* Instructions associated with flow entry contain either _actions_ or _modify pipeline processing_.

    Examples of actions: packet forwarding, packet modification, group table processing.

    Pipeline processing instructions allow packets to be sent to subsequent tables for further processing and allow metadata to be communicated between tables.

    The same as above in another words with more details: an **instruction either modifies pipeline processing** (such as directing the packet to another flow table), or **contains a set of actions to add to the action set**, or **contains a list of actions to apply immediatly to the packet**.

* During pipeline processing a set of values (_pipeline fields_) can be attached to the packet:

    - the ingress port (a property of the packet throughout the OPF pipeline)

    - the metadata value

    - the Tunnel-ID (a packet may have this extra pipeline field when it's associated with a *logical OPF port*)

* Actions may be _accumulated in the Action Set_ of the packet or _applied immediately_ to the packet.

* A switch element that can measure and control the rate of packets is called a **meter**. It _triggers_ a meter **band** if the packet rate (or byte rate) passing through the meter exceeds a predefined threshold.

    Each meter may have several bands. Band specifies a target rate and a way packets should be processed if that rate is exceeded.

    Example is a rate limiter whose band drops the packet.

    Meters are attached directly to flow entries (as opposed to queues attached to ports). There's a separate meter table.

* Pipeline processing happens in two stages: *ingress processing and egress processing*. Egress processing happens after the determination of the output port and happens in the context of this port.


## Notes related to OPF channel & connection management

### Message types supported by OPF

* _controller-to-switch_
* _async_ (initiated by the switch, used to inform the controller about changes)
* _symmetric_ (can be initiated by both sides). **Experimenter** messages fall into this category.

### Message Handling

* In the absence of barrier messages, switches may reorder messages to maximize performance => **controllers shouldn't depend on a specific processing order**... If 2 messages from the controller depend on each other:
    - they must either *be separated by a barrier message*
    - or *be put in the same ordered bundle*.

### Connection setup & maintenance

* After connection setup is done **one of the 1-st things the controller should do** is to get the *Datapath ID of the switch* (as a reply to *OFPT_FEATURES_REQUEST* message).

* A switch management protocol such as *OF-CONFIG* is recommended to be used for configuring and managing security credentials.

### Multiple controllers

* Controller can specify which types of async messages from switch are sent over its channel in order to **control which message types can be enabled of filtered**.

* As a key takeaways from [CAP for Networks](https://people.eecs.berkeley.edu/~alig/papers/cap-for-networks.pdf):

    - controllers typically communicate through *out-of-band management network* to coordinate among themselves... so there could be a situation where **the controllers are partitioned from each other** while the data network bacame connected... as a result **network policies may be violated**.

    - _hybrid approaches_ (i.e. where controllers revert to *in-band control* where the out-of-band control network is partitioned) provide comparable simplicity (to out-of-band) while providing greater resilency.


## Notes related to the details of OPF Switch Protocol 

### About switch ports

* In general, the port config bits are set by the controller and not changed by the switch.

* The switch sends an *OFPT_PORT_STATUS message* to notify the controller of the change when:

    - the port config bits are changed by the switch through another administrative interface.

* Port addition, modification or removal never changes the content of the flow tables. **When a port is deleted it's left to the controller to clean up any flow entries** (or group entries) referencing that port.


### About switch queues

* A switch can optionally have one or more queues (to provide QoS) attached to a specific output port. Those queues
can be used to schedule packets exiting the datapath on that output port.

* Packets are directed to one of the queues based on the *packet output port* and the *packet queue id*.

* Queue processing happens logically after all pipeline processing.

* There is the **special action type** to set queue id when outputting a packet to a port: *OFPAT_SET_QUEUE*


### Flow Match

* OXM TLV - *OpenFlow Extensible Match type-length-value* format

* The payload of the OpenFlow match is a set of OXM Flow match fields.

* The first 4 bytes of an OXM TLV (*flow match field*) are its header (**the combination of oxm_class and oxm_field normally designates a protocol header field**, but it can also refer to a packet pipeline field):
    - *oxm_class*
    - *oxm_field*
    - *oxm_hasmask* - defines if the OXM TLV contains a bitmask
    - *oxm_length* -  the length of the OXM TLV payload in bytes, i.e. everything that follows the 4 bytes OXM TLV header

* If oxm_hasmask is 0, the OXM TLV’s body contains a value for the field, called *oxm_value*. The **OXM TLV match matches only packets in which the corresponding field equals oxm_value**.

* If oxm_hasmask is 1, *each 1-bit in oxm_mask constrains the OXM TLV to match only packets in which the corresponding bit of the field equals the corresponding bit in oxm_value*.

* Most match fields have prerequisites (another match field type and match field value that this match field depends on) - see [Header Match Fields](https://www.opennetworking.org/wp-content/uploads/2014/10/openflow-switch-v1.5.1.pdf#paragraph.7.2.3.8)

* Note for how switches deal with matches: **if the match in a flow mod message specifies a field but fails to specify its prerequisites, the switch must return an error** with *OFPET_BAD_MATCH* type and *OPFBMC_BAD_PREREQ* code (for example, specifies an IPv4 addr without matching the EtherType to 0x800).

* The controller can query the switch about which match fields are supported in each flow table.

* There're 2 types of match fields:
    - *header match fields* - matching values extracted from the packet headers
    - *pipeline match fields* - matching values attached to the packet for pipeline processing


### Flow Stats

* OPF *Extensible Stat format* follow the same convention as OXM format.

* Each flow table of the switch must support the [required stat fields](https://www.opennetworking.org/wp-content/uploads/2014/10/openflow-switch-v1.5.1.pdf#paragraph.7.2.4.4):

    - OXS_OF_DURATION
    - OXS_OF_IDLE_TIME
    - OXS_OF_FLOW_COUNT
    - OXS_OF_PACKET_COUNT
    - OXS_OF_BYTE_COUNT


### Flow Instructions

* Instructions (associated with the flow entry) are executed when a packet matches the entry.

* For the *Apply-Actions* instruction, the *actions field is treated as a list*. For the *Write-Actions* instruction, the *actions field is treated as a set*.

* *STAT_TRIGGER* instruction type allows the controller to receive a trigger for one or many thresholds, i.e. *when one of the stat field values of the flow entry crosses threshold*.


### Controller-to-Switch messages

* _Handshake_: the controller requests switch features, and the switch must reply with *OFPT_FEATURES_REPLY* message. The reply contains:
    - *datapath_id* - lower 48-bits are for a MAC address, the upper 16-bits are implementer-defined (for example, it could be VLAN ID to distinguish multiple virtual switch instances on a single physical switch)
    - the maximum number of packets the switch can buffer (when sending packets to the controller using packet-in messages)
    - number of tables supported by the switch, the type of connection (main or auxiliary)
    - bitmap which defines the switch capabilities.

* The controller is able to *set and query configuration parameters in the switch*. For the OPF v.1.3.5, these parameters include:
    - bitmap with combination of flags which indicate how IP fragments should be treated by the switch
    - the number of bytes of each packet sent to the controller by the switch pipeline.

* For the *flow mod message*:
    - the *buffer_id* refers to a packet buffered at the switch and sent to the controller by a packet-in message (if the buffer_id is valid, flow-mod removes the corresponding packet from the buffer and processes it through the OpenFlow pipeline after the flow is inserted, starting at the first flow table)
    - the *flags* field controls whether the *Send flow removed message* is to be sent by the switch **when flow expires or is deleted**.

* The *OFPT_PORT_MOD message* is used by the controller to modify the behavior of the port on the switch - **what behaviour and what for???**

* About *meter-modification messages*:
    - the OPF protocol defines some *virtual* meters which can't be associated with flows (for slow datapath, for controller connection)
    - one of the fields is *the list of bands*, and if the current rate of packets exceeds the rate of multiple bands, the band with the highest configured rate is used
    - the *rate* field of the band indicates **the rate value above which the corresponding band may apply to packets**. The rate value is in kbits/sec (unless the flags field includes OFPMF_PKTPS)

* _Multipart messages_ are used to request statistics or state information from the switch.

* Controller can set and query the *async* messages which it wants to receive **via a given OPF channel**.
