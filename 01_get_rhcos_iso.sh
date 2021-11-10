#!/bin/bash

ISO_URL=$(./bin/openshift-install coreos print-stream-json | jq .architectures.x86_64.artifacts.metal.formats.iso.disk.location | tr -d '"')

curl -L ${ISO_URL} -o temp/rhcos-live.iso

