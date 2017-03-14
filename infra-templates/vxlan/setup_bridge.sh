#!/bin/bash

set -ex

# Set varibles
eth0_IP=$(ip addr show eth0 | grep 'inet\b' | awk '{print $2}')
BASE_MAC=$(ip addr show eth0 | grep ether | awk '{print $2}'| cut -d : -f 4,5,6)

BRIDGE_IP=${eth0_IP}
BRIDGE_MAC="00:aa:bb:${BASE_MAC}"
GW_IP=$(ip route show | grep default | awk '{print $3}')

BRIDGE_NAME=mpbr0

ip link add ${BRIDGE_NAME} type bridge
ip link set ${BRIDGE_NAME} address ${BRIDGE_MAC}
ip addr del ${eth0_IP} dev eth0
ip addr add ${BRIDGE_IP} dev ${BRIDGE_NAME}
ip link set dev ${BRIDGE_NAME} up
ip link set dev eth0 master ${BRIDGE_NAME}

ip route add default via ${GW_IP}
ip addr show
