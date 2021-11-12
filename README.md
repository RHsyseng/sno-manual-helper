# sno-manual-helper

Helper scripts to install SNO manually

This script was initially created by Mario Vazquez Cebrian, kudos to [Mario](https://github.com/mvazquezc)!

## How to use it

Copy your pull secret (in json format) into this folder (you can get yours from this url https://console.redhat.com/openshift/install/pull-secret). The name of the pull secret is expected to be pull_secret.json.

Update assets/install-config.yaml to fit your environment needs, you need to modify configs between <>.

Then run commands below:

This by default will install the latest stable 4.9 release:

```shell
$ ./00_extract_tools_from_release.sh
You are going to install OpenShift 4.9.5
<omitted>
```

or to install a particular release under [link](https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/), for example ‘stable-4.8’, ‘4.8.12’, ‘4.9.4’, ‘latest’ etc. like 4.9.4 in below example:

```shell
$ ./00_extract_tools_from_release.sh 4.9.4
You are going to install OpenShift 4.9.4
<omitted>

```

```shell
$ ./01_get_rhcos_iso.sh
$ ls -l temp/
oc-client.tar.gz
rhcos-live.iso

```

Run 02_generate_workloadpartitioning_config.sh to set reserved CPUSET:

```shell
$ ./02_generate_workloadpartitioning_config.sh
Run the script like ./02_generate_workloadpartitioning_config.sh <CPUSET>, for example ./02_generate_workloadpartitioning_config.sh 0-3,16-19
$ ./02_generate_workloadpartitioning_config.sh 0-3,16-19
$ ls -1 assets/
99_workload_partitioning.yaml
install-config.yaml

```

Run 03_generate_inplacedns_config.sh script to setup the in-place DNS resolution:

```shell
$./03_generate_inplacedns_config.sh 
Run the script like ./03_generate_inplacedns_config.sh <your SNO node IP>, for example: ./03_generate_inplacedns_config.sh 10.19.142.235

$ ./03_generate_inplacedns_config.sh 10.19.142.235
$ ls -1 assets/
99_workload_partitioning.yaml
Install-config.yaml
10_inplace_dns.yaml

```

```shell
./04_generate_deploy_iso.sh
$ ls -1 build/
sno-rhcos-live.iso

```

Boot the bare-metal node using the iso (sno-rhcos-live.iso) generated in the previous steps using virtual-media or any other mechanism you have at your disposal. 

Monitor the deployment progress:

```shell
$ ./05_monitor_deployment.sh

INFO Waiting up to 40m0s for the cluster at https://api.sno49-manual.cloud.lab.eng.bos.redhat.com:6443 to initialize...

INFO Waiting up to 10m0s for the openshift-console route to be created... 
INFO Install complete!                            
INFO To access the cluster as the system:admin user when using 'oc', run 'export KUBECONFIG=/home/kni/sno/4.9-manual/ocp/auth/kubeconfig' 
INFO Access the OpenShift web-console here: https://console-openshift-console.apps.sno49-manual.cloud.lab.eng.bos.redhat.com 
INFO Login to the console with user: "kubeadmin", and password: "etF5s-rPxxZ-9fZ8w-6ZcX4" 
INFO Time elapsed: 18m41s  

```

You should have a cluster deployment after around 40 mins:

```shell
$ ./bin/oc get clusterversion,co
NAME                                         VERSION   AVAILABLE   PROGRESSING   SINCE   STATUS
clusterversion.config.openshift.io/version   4.9.5     True        False         8h      Cluster version is 4.9.5

NAME                                                                           VERSION   AVAILABLE   PROGRESSING   DEGRADED   SINCE   MESSAGE
clusteroperator.config.openshift.io/authentication                             4.9.5     True        False         False      8h      
clusteroperator.config.openshift.io/baremetal                                  4.9.5     True        False         False      8h      
clusteroperator.config.openshift.io/cloud-controller-manager                   4.9.5     True        False         False      8h      
clusteroperator.config.openshift.io/cloud-credential                           4.9.5     True        False         False      8h      
clusteroperator.config.openshift.io/cluster-autoscaler                         4.9.5     True        False         False      8h      
clusteroperator.config.openshift.io/config-operator                            4.9.5     True        False         False      8h      
clusteroperator.config.openshift.io/console                                    4.9.5     True        False         False      8h      
clusteroperator.config.openshift.io/csi-snapshot-controller                    4.9.5     True        False         False      8h      
clusteroperator.config.openshift.io/dns                                        4.9.5     True        False         False      8h      
clusteroperator.config.openshift.io/etcd                                       4.9.5     True        False         False      8h      
clusteroperator.config.openshift.io/image-registry                             4.9.5     True        False         False      8h      
clusteroperator.config.openshift.io/ingress                                    4.9.5     True        False         False      8h      
clusteroperator.config.openshift.io/insights                                   4.9.5     True        False         False      8h      
clusteroperator.config.openshift.io/kube-apiserver                             4.9.5     True        False         False      8h      
clusteroperator.config.openshift.io/kube-controller-manager                    4.9.5     True        False         False      8h      
clusteroperator.config.openshift.io/kube-scheduler                             4.9.5     True        False         False      8h      
clusteroperator.config.openshift.io/kube-storage-version-migrator              4.9.5     True        False         False      8h      
clusteroperator.config.openshift.io/machine-api                                4.9.5     True        False         False      8h      
clusteroperator.config.openshift.io/machine-approver                           4.9.5     True        False         False      8h      
clusteroperator.config.openshift.io/machine-config                             4.9.5     True        False         False      8h      
clusteroperator.config.openshift.io/marketplace                                4.9.5     True        False         False      8h      
clusteroperator.config.openshift.io/monitoring                                 4.9.5     True        False         False      8h      
clusteroperator.config.openshift.io/network                                    4.9.5     True        False         False      8h      
clusteroperator.config.openshift.io/node-tuning                                4.9.5     True        False         False      8h      
clusteroperator.config.openshift.io/openshift-apiserver                        4.9.5     True        False         False      8h      
clusteroperator.config.openshift.io/openshift-controller-manager               4.9.5     True        False         False      8h      
clusteroperator.config.openshift.io/openshift-samples                          4.9.5     True        False         False      8h      
clusteroperator.config.openshift.io/operator-lifecycle-manager                 4.9.5     True        False         False      8h      
clusteroperator.config.openshift.io/operator-lifecycle-manager-catalog         4.9.5     True        False         False      8h      
clusteroperator.config.openshift.io/operator-lifecycle-manager-packageserver   4.9.5     True        False         False      8h      
clusteroperator.config.openshift.io/service-ca                                 4.9.5     True        False         False      8h      
clusteroperator.config.openshift.io/storage                                    4.9.5     True        False         False      8h   

```
