#!/bin/bash

NODEIP=$1; shift

if [ -z "$NODEIP" ]
then
    echo "Run the script like ./03_generate_inplacedns_config.sh <your SNO node IP>, for example: ./03_generate_inplacedns_config.sh 10.19.142.235"
    exit 1
fi

cat <<EOF > assets/10_inplace_dns.yaml
apiVersion: machineconfiguration.openshift.io/v1
kind: MachineConfig
metadata:
  labels:
    machineconfiguration.openshift.io/role: master
  name: 10-inplace-dns
spec:
  config:
    ignition:
      version: 3.2.0
    storage:
      files:
      - contents:
          source: data:text/plain;charset=utf-8;base64,DNS1
        mode: 420
        overwrite: true
        path: /etc/dnsmasq.d/single-node.conf
        user:
          name: root
      - contents:
          source: data:text/plain;charset=utf-8;base64,DNS2
        mode: 365
        overwrite: true
        path: /etc/NetworkManager/dispatcher.d/forcedns
        user:
          name: root
      - contents:
          source: data:text/plain;charset=utf-8;base64,ClttYWluXQpyYy1tYW5hZ2VyPXVubWFuYWdlZAo=
        mode: 420
        overwrite: true
        path: /etc/NetworkManager/conf.d/single-node.conf
        user:
          name: root
    systemd:
      units:
      - contents: |
          [Unit]
          Description=Run dnsmasq to provide local dns for Single Node OpenShift
          Before=kubelet.service crio.service
          After=network.target

          [Service]
          ExecStart=/usr/sbin/dnsmasq -k

          [Install]
          WantedBy=multi-user.target
        enabled: true
        name: dnsmasq.service
EOF
CLUSTERNAME=$(cat assets/install-config.yaml | grep -A1 metadata | grep name | awk -F "name:" '{print $2}' | tr -d " " | tr -d '"' | tr -d "'")
BASEDOMAIN=$(cat assets/install-config.yaml | grep baseDomain | awk -F "baseDomain:" '{print $2}' | tr -d " " | tr -d '"' | tr -d "'")
sed -i "s/DNS1/$(echo "YWRkcmVzcz0vYXBwcy5DTFVTVEVSTkFNRS5CQVNFRE9NQUlOL05PREVJUAphZGRyZXNzPS9hcGktaW50LkNMVVNURVJOQU1FLkJBU0VET01BSU4vTk9ERUlQCmFkZHJlc3M9L2FwaS5DTFVTVEVSTkFNRS5CQVNFRE9NQUlOL05PREVJUAoK" | base64 -d | sed "s/CLUSTERNAME/${CLUSTERNAME}/g" | sed "s/BASEDOMAIN/${BASEDOMAIN}/g" | sed "s/NODEIP/${NODEIP}/g" | base64 -w0)/" assets/10_inplace_dns.yaml
sed -i "s/DNS2/$(echo "ZXhwb3J0IElQPSJOT0RFSVAiCmV4cG9ydCBCQVNFX1JFU09MVl9DT05GPS9ydW4vTmV0d29ya01hbmFnZXIvcmVzb2x2LmNvbmYKaWYgWyAiJDIiID0gImRoY3A0LWNoYW5nZSIgXSB8fCBbICIkMiIgPSAiZGhjcDYtY2hhbmdlIiBdIHx8IFsgIiQyIiA9ICJ1cCIgXSB8fCBbICIkMiIgPSAiY29ubmVjdGl2aXR5LWNoYW5nZSIgXTsgdGhlbgogICAgaWYgISBncmVwIC1xICIkSVAiIC9ldGMvcmVzb2x2LmNvbmY7IHRoZW4KICAgICAgZXhwb3J0IFRNUF9GSUxFPSQobWt0ZW1wIC9ldGMvZm9yY2VkbnNfcmVzb2x2LmNvbmYuWFhYWFhYKQogICAgICBjcCAgJEJBU0VfUkVTT0xWX0NPTkYgJFRNUF9GSUxFCiAgICAgIGNobW9kIC0tcmVmZXJlbmNlPSRCQVNFX1JFU09MVl9DT05GICRUTVBfRklMRQogICAgICBzZWQgLWkgLWUgInMvQ0xVU1RFUk5BTUUuQkFTRURPTUFJTi8vIiBcCiAgICAgIC1lICJzL3NlYXJjaCAvJiBDTFVTVEVSTkFNRS5CQVNFRE9NQUlOIC8iIFwKICAgICAgLWUgIjAsL25hbWVzZXJ2ZXIvcy9uYW1lc2VydmVyLyYgJElQXG4mLyIgJFRNUF9GSUxFCiAgICAgIG12ICRUTVBfRklMRSAvZXRjL3Jlc29sdi5jb25mCiAgICBmaQpmaQo=" | base64 -d | sed "s/CLUSTERNAME/${CLUSTERNAME}/g" | sed "s/BASEDOMAIN/${BASEDOMAIN}/g" | sed "s/NODEIP/${NODEIP}/g" | base64 -w0)/" assets/10_inplace_dns.yaml
