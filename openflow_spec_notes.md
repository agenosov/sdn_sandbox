## Notes from the Section 7


### About switch ports

* In general, the port config bits are set by the controller and not changed by the switch. 
  If the port config bits are changed by the switch through another administrative interface, the switch sends an OFPT_PORT_STATUS message to notify the controller of the change.

* When the port state flags are changed, the switch sends an OFPT_PORT_STATUS message to notify the controller of the change


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

* Most match fields have prerequisites (another match field type and match field value that this match field depends on) - see *Header Match Fields*.

* Note for how switches deal with matches: **if the match in a flow mod message specifies a field but fails to specify its prerequisites, the switch must return an error** with *OFPET_BAD_MATCH* type and *OPFBMC_BAD_PREREQ* code (for example, specifies an IPv4 addr without matching the EtherType to 0x800).

* The controller can query the switch about which match fields are supported in each flow table.

* There're 2 types of match fields:
    - *header match fields* - matching values extracted from the packet headers
    - *pipeline match fields* - matching values attached to the packet for pipeline processing


### Flow Instructions

* Instructions (associated with the flow entry) are executed when a packet matches the entry.

* For the *Apply-Actions* instruction, the *actions field is treated as a list*. For the *Write-Actions* instruction, the *actions field is treated as a set*.


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
