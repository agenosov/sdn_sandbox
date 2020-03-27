#!/bin/bash

# Path to the py_gnmicli.py script (https://github.com/google/gnxi/gnmi_cli_py)

certs_path="$HOME/certificates/nms"
gnmi_path="/"
gnmi_value=""

while getopts "d:v:x:" opt
do
    case $opt in
        d)
            pushd "$OPTARG" >/dev/null

            # Path to the py_gnmicli.py script (https://github.com/google/gnxi/gnmi_cli_py)
            gnmi_python_client_path="$(pwd -P)"
            popd >/dev/null
            ;;
        v)
            gnmi_value="$OPTARG"
            ;;
        x)
            gnmi_path="$OPTARG"
            ;;            
        \?)
            echo "Invalid option -$OPTARG"
            exit 1
            ;;
        :)
            echo "Error: Option -$OPTARG requires an argument"
            exit 1
            ;;
    esac
done

source $gnmi_python_client_path/venv/bin/activate

python $gnmi_python_client_path/py_gnmicli.py \
    -t localhost -p 10161\
    -user foo -pass bar \
    -rcert $certs_path/monitoring_grpc_server.crt \
    -cchain $certs_path/monitoring_grpc_ca.crt \
    -pkey $certs_path/monitoring_grpc_ca.key \
    -m set-update \
    -x $gnmi_path \
    -val $gnmi_value

deactivate
