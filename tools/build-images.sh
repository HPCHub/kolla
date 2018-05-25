#!/bin/bash

set -x

TAG=6.0.1
REPO=172.17.1.2:5001
IMAGES="cinder-api cinder-volume cinder-scheduler cron memcached rabbitmq keystone haproxy keepalived glance-api nova-compute nova-placement-api nova-api nova-scheduler nova-conductor nova-consoleauth nova-novncproxy nova-spicehtml5proxy neutron-server neutron-openvswitch-agent neutron-dhcp-agent neutron-metadata-agent neutron-l3-agent heat-api heat-engine horizon"

source /root/venv/bin/activate
kolla-build --nocache -b centos $IMAGES
if [[ $? -ne 0 ]]; then
  echo "kolla-build failed"
  exit 1
fi

for IMG in ${IMAGES}; do
  IMG_ID=`docker images -q kolla/centos-binary-${IMG}`
  [ "x$IMG_ID" != "x" ] || exit 1

  docker tag $IMG_ID $REPO/kolla/centos-binary-${IMG}:${TAG}
  docker push $REPO/kolla/centos-binary-${IMG}:${TAG}
done

docker rmi -f $(docker images -q)

