#!/bin/bash
mkdir /tmp/ORG/
mkdir /tmp/ORG/cust/
mkdir /tmp/ORG/cust/INFENG/
mkdir /tmp/ORG/cust/INFENG/scripts/
cp /tmp/cust/DFBANK1/IHOTFIX/scripts/* /tmp/ORG/cust/INFENG/scripts/
echo "curl -X POST -k https://192.168.64.16:8443/apis/build.openshift.io/v1/namespaces/p3/buildconfigs/3bc/webhooks/3bcsecret/generic" >> /tmp/TOOL/trigger.sh
