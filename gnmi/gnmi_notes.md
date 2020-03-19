### Launching gNMI target

```bash
./gnmi_target.sh
```

## Launching gNMI clients

### Client from Arista examples

```bash
./gnmi_client.sh
```

### Examples of specifying gNMI paths

* Request all config from the root

Specify gNMI path as below:
```bash
-x /
```

* Specify a path for the concrete interface

```bash
-x /interfaces/interface[name=admin]
```

* Request system config

```bash
-x /system
```

### Nuances related to Authentication and RPC Authorization

* If the target authenticates an RPC operation (*i.e. the gnmi_target is provided with both -username and -password options*), the client still can discover capabilities even without providing a username and password.

* The 'Get' request in the case above isn't permitted (_due to no username in Metadata_).