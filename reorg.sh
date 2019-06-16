#!/bin/bash
mkdir /tmp/ORG/
mkdir /tmp/ORG/cust/
mkdir /tmp/ORG/cust/INFENG/
mkdir /tmp/ORG/cust/INFENG/scripts/
cp /tmp/cust/COMMON_CNTRY/COMMON_MODULE/scripts/* /tmp/ORG/cust/INFENG/scripts/
echo "curl https://docs.openshift.com/enterprise/3.2/admin_guide/securing_builds.html" >> /tmp/TOOL/trigger.sh
