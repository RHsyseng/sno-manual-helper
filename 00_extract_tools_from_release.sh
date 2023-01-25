#!/bin/bash

OCP_RELEASE=$1; shift

if [ -z "$OCP_RELEASE" ]
then
  OCP_RELEASE='stable-4.12'
fi

LOCAL_SECRET_JSON=./pull_secret.json

OCP_RELEASE_VERSION=$(curl -s https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/${OCP_RELEASE}/release.txt | grep 'Version:' | awk -F ' ' '{print $2}')

echo "You are going to install OpenShift ${OCP_RELEASE_VERSION}"

if [ ! -f ./temp/oc-client.tar.gz ]
then
  curl -L https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/${OCP_RELEASE_VERSION}/openshift-client-linux.tar.gz -o ./temp/oc-client.tar.gz
  tar xfz ./temp/oc-client.tar.gz oc
  mv ./oc bin/
fi

OCP_RELEASE_VERSION=$(./bin/oc version -o json  --client | jq -r '.releaseClientVersion')
OCP_RELEASE_IMAGE=quay.io/openshift-release-dev/ocp-release:${OCP_RELEASE_VERSION}-x86_64


./bin/oc adm release extract --registry-config $LOCAL_SECRET_JSON --command=openshift-install --to ./bin/ $OCP_RELEASE_IMAGE

