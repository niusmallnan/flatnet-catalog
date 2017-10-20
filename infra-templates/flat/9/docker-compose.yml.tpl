version: '2'
services:
  cni-driver:
    privileged: true
    image: niusmallnan/rancher-flat:v0.2.0
    environment:
      FLAT_IF: ${FLAT_IF}
      FLAT_BRIDGE: ${FLAT_BRIDGE}
      MTU: ${MTU}
    command: sh -c "start-flat.sh && start-cni-driver.sh"
    network_mode: host
    pid: host
    labels:
      io.rancher.network.cni.binary: 'rancher-bridge'
      io.rancher.container.dns: 'true'
      io.rancher.scheduler.global: 'true'
    volumes:
    - /var/run/docker.sock:/var/run/docker.sock
    - rancher-cni-driver:/opt/cni-driver
    logging:
      driver: json-file
      options:
        max-size: 25m
        max-file: '2'
    network_driver:
      name: Rancher Flat Networking
      default_network:
        name: l2-flat
        host_ports: true
        subnets:
        - network_address: ${SUBNET}
          start_address: ${START_ADDRESS}
          end_address: ${END_ADDRESS}
        dns:
        - 169.254.169.250
        dns_search:
        - rancher.internal
      cni_config:
        '10-rancher-flat.conf':
          name: rancher-flat-network
          type: rancher-bridge
          bridge: ${FLAT_BRIDGE}
          bridgeSubnet: ${SUBNET}
          logToFile: /var/log/rancher-cni.log
          isDebugLevel: ${RANCHER_DEBUG}
          hostNat: {{ .Values.HOST_NAT  }}
          mtu: ${MTU}
          skipBridgeConfigureIP: true
          skipFastPath: true
          ipam:
            type: rancher-flat-ipam
            logToFile: /var/log/rancher-cni.log
            isDebugLevel: ${RANCHER_DEBUG}
            routes:
            - dst: 0.0.0.0/0
              gw: ${GATEWAY}
