#!/bin/bash

# Path to the py_gnmicli.py script (https://github.com/google/gnxi/gnmi_cli_py)
gnmi_python_client_path="$1"

certs_path="$HOME/certificates/nms"

source $gnmi_python_client_path/venv/bin/activate

python $gnmi_python_client_path/py_gnmicli.py \
    -m get -t localhost -p 10161\
    -user foo -pass bar \
    -rcert $certs_path/monitoring_grpc_server.crt \
    -cchain $certs_path/monitoring_grpc_ca.crt \
    -pkey $certs_path/monitoring_grpc_ca.key \
    -x /

deactivate
