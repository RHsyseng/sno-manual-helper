#!/bin/bash

mkdir -p ocp/
rm -rf ocp/*

cp assets/install-config.yaml ocp/

./bin/openshift-install create manifests --dir ocp/

if [[ -f "assets/static_hostname" ]]
then

  cat <<EOF > assets/20_static_hostname.yaml
apiVersion: machineconfiguration.openshift.io/v1
kind: MachineConfig
metadata:
  labels:
    machineconfiguration.openshift.io/role: master
  name: 20-static-hostname
spec:
  config:
    ignition:
      version: 3.2.0
    storage:
      files:
      - contents:
          source: data:text/plain;charset=utf-8;base64,HOSTNAME
        mode: 420
        overwrite: true
        path: /etc/hostname
        user:
          name: root
EOF
  HOSTNAME=$(cat assets/static_hostname | base64 -w0)
  sed -i "s/HOSTNAME/${HOSTNAME}/" assets/20_static_hostname.yaml
  cp assets/20_static_hostname.yaml ocp/openshift/
fi

cp assets/99_workload_partitioning.yaml ocp/openshift/
cp assets/10_inplace_dns.yaml ocp/openshift/

./bin/openshift-install create single-node-ignition-config --dir ocp/

if [[ -f "assets/static_ip" ]]
then

  STATIC_IP_B64=$(cat assets/static_ip | base64 -w0)
  IFACE_NAME=$(cat assets/static_ip | grep interface-name |  awk -F "=" '{print $2}')
  STATIC_IP_IGN="{\"overwrite\": true,\"path\": \"/etc/NetworkManager/system-connections/${IFACE_NAME}.nmconnection\",\"mode\": 384,\"user\": {\"name\": \"root\"},\"contents\": { \"source\": \"data:;base64,${STATIC_IP_B64}\" }}"
  cat ocp/bootstrap-in-place-for-live-iso.ign | jq ".storage.files += [${STATIC_IP_IGN}]" > ocp/temp.ign
  mv ocp/temp.ign ocp/bootstrap-in-place-for-live-iso.ign
  # Add --copy-network to coreos-install command
  COPY_NETWORK=$(cat ocp/bootstrap-in-place-for-live-iso.ign | jq -r '(.storage.files[] | select(.path | contains("install-to-disk.sh")).contents.source)' | awk -F "base64," '{print $2}' | base64 -d | sed "s/\(coreos-installer install .*$\)/\1 --copy-network/" | base64 -w0)
  cat ocp/bootstrap-in-place-for-live-iso.ign | jq -r '.storage.files[] |= if .path | contains("install-to-disk.sh") then .contents.source = "data:text/plain;charset=utf-8;base64,'$COPY_NETWORK'" else . end' > ocp/temp.ign
  mv ocp/temp.ign ocp/bootstrap-in-place-for-live-iso.ign
fi
sudo podman run --privileged --rm -v /dev:/dev -v /run/udev:/run/udev -v $PWD:/data -w /data quay.io/coreos/coreos-installer:release iso ignition embed -fi /data/ocp/bootstrap-in-place-for-live-iso.ign /data/temp/rhcos-live.iso

cp ./temp/rhcos-live.iso ./build/sno-rhcos-live.iso
