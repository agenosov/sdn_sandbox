### How working with OpenFlow protocol is implemented in RYU


* *ryu.ofproto.ofproto_protocol.py* defines a dictionary of supported OpenFlow versions. This dictionary is a mapping from a version number (e.g. _0x04 for v.1.3_) to a pair of modules: _a module of protocol definitions_ (message types, constants, etc.) and _a module of a parser_ which implements the concrete version of the protocol.

* The same module (*ofproto_protocol.py*) defines a _ProtocolDesc class with ability to provide supported versions of the protocol_. This is a base for the _Datapath_.

* *ryu.ofproto* package initialization defines convenient functions *get_ofp_modules* and *get_ofp_module*: the former is to obtain pairs of modules for working will all supported versions of the protocol, and the latter is to provide modules pair (_protocol definition, protocol implementation_) for specific version.

* *ryu.controller.ofp_handler.OFPHandler* is a RYU application. 

    1. On start it instantiates *ryu.controller.controller.OpenFlowController* class. The controller then starts an OpenFlow server in separate thread to handle connections from switches. Also if there're configured addresses of switches to connect to (*CONF.ofp_switch_address_list* isn't empty), the controller initiates connections to switches.

    2. This application defines handlers of the following OPF messages: _hello_, _echo_, replies for a _switch features_, _port description_, _port status_ requests and _error_ messages. **Note** that this is done via *set_ev_handler* not *set_ev_cls* decorator.

* Controller sends _hello_ message immediatly after a switch connected. A thread for working with the connected switch initiates a loop of receiving messages from the switch.

    1. *ryu.ofproto.ofproto_parser.msg* function is used to produce an OPF message from data received from the switch.

    2. a valid OPF message is translated into an event by means of the *ryu.controller.ofp_event.ofp_msg_to_ev* function.

* Each _datapath_ instance performs lookup of the *'ofp_event'* service. This service is produced by *ryu.controller.ofp_handler*.



#### About introducing classes of RYU events corresponding to OpenFlow messages


* Importing the *ryu.controller.ofp_event* leads to creation of the *_OPF_MSG_EVENTS* dictionary, which is a **mapping from OPF message name into a class of RYU event**.

    1. *ryu.ofproto.get_ofp_modules* provides a module with parser for each supported version of the protocol.

    2. Each parser defines the *cls_msg_type attribute* via decorator *@set_msg_type*. If a class defined inside a parser's module has this attribute, a class of event (corresponding to a class of OPF message) will be created by means of *ryu.controller.ofp_event._create_ofp_msg_ev_class* function.
