## HOW-TO
1. sudo apt-get install mininet
   Test: sudo mn --test pingall                                                   (a)
         sudo mn --topo single,3 --mac --switch ovsk --controller [remote|ryu]    (b)
   
   Tips:
   * For both (a) & (b), the ovs-vswitchd service must be launched
   * During (b), MN try to connect remote controller at localhost:6633 (6633 is OpenFlow port)
   * As no controller is launched: there is a message: "Unable to contact the remote controller..." and pingall fails
   * Support for concrete version of OPF could be enabled by passing additional parameter: --switch ovs,protocols=OpenFlow14

2. cd ryu && PYTHONPATH=.
   ./bin/ryu-manager ryu/app/simple_switch.py

   Now connection is established between MN switch & Ryu controller - pingall should be passed

3. Dump flows for switch s1: sudo ovs-ofctl -O OpenFlow13 dump-flows s1

4. To launch integrated tests:
   - sudo pip install nose


## PROBLEMS & OPEN QUESTIONS

1. Mininet was launched with options: --mac --switch ovsk --controller ryu. Ryu simple switch used OPF v.1.2.
   There was an exception from MN: Please shut down the controller which is running on port 6633
2. ryu-manager ./simple_switch_13.py ==> unsupported version 0x3. If possible, set the switch to use one of the versions
   The same for v.1.4 (???)
   Who told it?! ovs-ofctl supports OpenFlow versions 0x1:0x4. [This message is either from MN or OVS]
   Besides, when running this app, ping passes for MN hosts (when using --switch ovs)
3. **L2 Dumb switch doesn't works when using OPF versions 1.3 or 1.4** (I launch MN explicitly indicating OPF version...) - ???
