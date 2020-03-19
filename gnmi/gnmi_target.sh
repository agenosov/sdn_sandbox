#!/bin/bash

# Prerequisites
# 1. go get github.com/google/gnxi/gnmi_target
# 2. go install github.com/google/gnxi/gnmi_target

gopath=$(go env | grep GOPATH | cut -d'=' -f2)
# remove prefix/suffix "" from the received path
gopath="${gopath%\"}"
gopath="${gopath#\"}"

gnmi_bin="$gopath/bin/gnmi_target"
config_path="$HOME/projects/sdn/gnxi/gnmi_target/openconfig-openflow.json"
certs_path="$HOME/certificates/nms/"

$gnmi_bin \
  -bind_address :10161 \
  -config $config_path \
  -key $certs_path/monitoring_grpc_server.key \
  -cert $certs_path/monitoring_grpc_server.crt \
  -ca $certs_path/monitoring_grpc_ca.crt \
  -alsologtostderr \
  -username foo \
  -password bar
