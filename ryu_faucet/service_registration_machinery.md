### Mechanism of service registration


* The *ryu.controller.handler.register_service* function allows to register specified RYU application as a _provider of events defined in the calling module_.

* For instance, the _OFPHandler_ application provides events defined in the *ryu.controller.ofp_event* module (remember that _importing this module leads to creation of different classes of events corresponding to OPF messages_). If there're applications consuming OPF events (by declaring this intent via *set_ev_cls* decorator), the _OFPHandler will be started automatically_.

* Other examples of registering services (i.e. _providers of events declared in some another module_):
    
    1. _ryu.services.protocols.ovsdb.manager_ is registered as a service - it provides events declared in _ryu.services.protocols.ovsdb.event_.

    2. _ryu.topology.switches_ is also registered as a service - its application provides events declared in _ryu.topology.event_


#### How it works


* The *ryu.controller.handler.register_service* function defines additional attribute *_SERVICE_NAME* for the module where provided events are defined (i.e. _in the calling module_). The value for this attribute is application module path.
