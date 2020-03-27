#!/bin/bash

# Prerequisites
# go get github.com/aristanetworks/goarista/cmd/gnmi

gopath=$(go env | grep GOPATH | cut -d'=' -f2)
# remove prefix/suffix "" from the received path
gopath="${gopath%\"}"
gopath="${gopath#\"}"

gnmi_bin="$gopath/bin/gnmi"
certs_path="$HOME/certificates/nms"

$gnmi_bin \
    -addr localhost:10161 \
    -cafile $certs_path/monitoring_grpc_server.crt \
    -certfile $certs_path/monitoring_grpc_ca.crt \
    -keyfile $certs_path/monitoring_grpc_ca.key \
    -compression "" \
    capabilities


for path in "/interfaces" "/system" ; do
    echo "Get snapshot of $path"
    echo
    $gnmi_bin \
        -addr localhost:10161 \
        -cafile $certs_path/monitoring_grpc_server.crt \
        -certfile $certs_path/monitoring_grpc_ca.crt \
        -keyfile $certs_path/monitoring_grpc_ca.key \
        -username foo \
        -password bar \
        -compression "" \
        get $path
done

# Subscribe to system configuration updates
$gnmi_bin \
    -addr localhost:10161 \
    -cafile $certs_path/monitoring_grpc_server.crt \
    -certfile $certs_path/monitoring_grpc_ca.crt \
    -keyfile $certs_path/monitoring_grpc_ca.key \
    -username foo \
    -password bar \
    -compression "" \
    subscribe '/system'
