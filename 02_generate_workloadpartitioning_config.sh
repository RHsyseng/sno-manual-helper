#!/bin/bash
CPUSET="changeme"

if [ "${CPUSET}" == "changeme" ]
then
  echo "Edit this script and change CPUSET variable value"
  exit 1
fi

cat <<EOF > assets/99_workload_partitioning.yaml
apiVersion: machineconfiguration.openshift.io/v1
kind: MachineConfig
metadata:
  labels:
    machineconfiguration.openshift.io/role: master
  name: 02-master-workload-partitioning
spec:
  config:
    ignition:
      version: 3.2.0
    storage:
      files:
      - contents:
          source: data:text/plain;charset=utf-8;base64,WP01
        mode: 420
        overwrite: true
        path: /etc/crio/crio.conf.d/01-workload-partitioning
        user:
          name: root
      - contents:
          source: data:text/plain;charset=utf-8;base64,WP02
        mode: 420
        overwrite: true
        path: /etc/kubernetes/openshift-workload-pinning
        user:
          name: root
EOF
sed -i "s/WP01/$(echo "W2NyaW8ucnVudGltZS53b3JrbG9hZHMubWFuYWdlbWVudF0KYWN0aXZhdGlvbl9hbm5vdGF0aW9uID0gInRhcmdldC53b3JrbG9hZC5vcGVuc2hpZnQuaW8vbWFuYWdlbWVudCIKYW5ub3RhdGlvbl9wcmVmaXggPSAicmVzb3VyY2VzLndvcmtsb2FkLm9wZW5zaGlmdC5pbyIKcmVzb3VyY2VzID0geyAiY3B1c2hhcmVzIiA9IDAsICJjcHVzZXQiID0gIkNIQU5HRU1FIiB9Cg==" | base64 -d | sed "s/CHANGEME/${CPUSET}/" | base64 -w0)/" assets/99_workload_partitioning.yaml
sed -i "s/WP02/$(echo "ewogICJtYW5hZ2VtZW50IjogewogICAgImNwdXNldCI6ICJDSEFOR0VNRSIKICB9Cn0K" | base64 -d | sed "s/CHANGEME/${CPUSET}/" | base64 -w0)/" assets/99_workload_partitioning.yaml

