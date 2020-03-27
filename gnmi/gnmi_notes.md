### Launching gNMI target

```bash
./gnmi_target.sh
```

## Launching gNMI clients

### Client from Arista examples

```bash
./gnmi_client.sh
```

### Python client from Google

Before running the script, python virtual environment is to be created and requirements are to be installed, as indicated in [README](https://github.com/google/gnxi/blob/master/gnmi_cli_py/README.md)

#### Get configuration filtered by provided path
```bash
./gnmi_client2.sh -d <PATH_TO_GNMI_CLI_PY> -x /system/
```

#### Configure a failure-mode for OpenFlow agent
```bash
./gnmi_config_updater.sh -d <PATH_TO_GNMI_CLI_PY> -x /system/openflow/agent/config/failure-mode/ -v SECURE
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

* Request OpenFlow agent's configuration

This is for the case when the target is using [this example configuration](https://github.com/google/gnxi/blob/master/gnmi_target/openconfig-openflow.json)

```bash
-x /system/openflow/agent
```

### Nuances related to Authentication and RPC Authorization

* If the target authenticates an RPC operation (*i.e. the gnmi_target is provided with both -username and -password options*), the client still can discover capabilities even without providing a username and password.

* The 'Get' request in the case above isn't permitted (_due to no username in Metadata_).
