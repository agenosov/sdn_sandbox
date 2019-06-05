### How to run Mininet with a concrete Ryu application as a controller

```bash
mn --custom ./datacenterConfigurable.py --topo dcconfigurable --mac --switch ovs --controller ryu,$IOF_SS2_PATH/ss2.core,ryu.app.ofctl_rest
```

### How to pass parameters to configure a concrete topology

```bash
mn --custom ./datacenterConfigurable.py --topo dcconfigurable,3,5 --mac --switch ovs --controller remote
```

### Create a full redundancy topology (2 root switches / 4 TOR switches / 3 hosts per rack)

```bash
mn --custom ./datacenterHARootConfigurable.py --topo dc_ha_root,4,3,2 --mac --switch ovs --controller remote
```
