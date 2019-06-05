Initially when OVS is started with clear database the command *sudo ovs-vsctl show* outputs only OVS version.

Let's launch Mininet:
    sudo mn --topo single,3 --mac --switch ovsk --controller remote

Now it's time to view the changes inside OVS database:

* the command *sudo ovs-vsctl show* outputs bridge's ports and attached controller (*if the controller is already launched*)

* the new bridge can be shown using the command *sudo ovs-vsctl list-br*


### Using ovs-ofctl to obtain current state of OpenFlow switch (_not just Open vSwitch_)

* show switch flow tables (with statistics):
```bash
ovs-ofctl dump-tables s1
```

* show installed flows:
```bash
ovs-ofctl dump-flows s1
```

* view aggregated statistics for flows:
```bash
ovs-ofctl dump-aggregate s1
```

* monitor receiving OPF messages for a particular switch's table:
```bash
ovs-ofctl monitor s1 watch:table=101
```

[UPD.17.05]
* view the full OpenFlow flow table, including hidden flows, on bridge br0:
```bash
ovs-appctl bridge/dump-flows br0
```

* If controllers are not actually in-band (e.g. they are on localhost via 127.0.0.1, or on a separate network), then configure your controllers in "out-of-band" mode:
```bash
ovs-vsctl set controller br0 connection-mode=out-of-band
```
