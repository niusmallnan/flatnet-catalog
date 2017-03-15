#!/bin/bash

set -ex

FLAT_IF=${FLAT_IF:-eth0}
BRIDGE_NAME=${FLAT_BRIDGE:-mpbr0}

TEST_BRIDGE=$(ip addr show $BRIDGE_NAME | grep 'inet\b' | awk '{print $2}')
if [ ! -z $TEST_BRIDGE ]; then
    exit 0
fi

# Set varibles
FLAT_IF_IP=$(ip addr show $FLAT_IF | grep 'inet\b' | awk '{print $2}')
BASE_MAC=$(ip addr show $FLAT_IF | grep ether | awk '{print $2}'| cut -d : -f 4,5,6)
BRIDGE_IP=${FLAT_IF_IP}
BRIDGE_MAC="00:aa:bb:${BASE_MAC}"
GW_IP=$(ip route show | grep default | awk '{print $3}')

ip link add ${BRIDGE_NAME} type bridge
ip link set ${BRIDGE_NAME} address ${BRIDGE_MAC}
ip addr del ${eth0_IP} dev eth0
ip addr add ${BRIDGE_IP} dev ${BRIDGE_NAME}
ip link set dev ${BRIDGE_NAME} up
ip link set dev eth0 master ${BRIDGE_NAME}

ip route add default via ${GW_IP}
