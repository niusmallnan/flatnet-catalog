version: '2'
services:
  cni-driver:
    privileged: true
    image: niusmallnan/rancher-flat:v0.1.4
    {{- if eq .Values.AUTO_BIND_BRIDGE "true" }}
    environment:
      FLAT_IF: ${FLAT_IF}
      FLAT_BRIDGE: ${FLAT_BRIDGE}
      MTU: ${MTU}
    command: sh -c "setup_flat_bridge.sh && touch /var/log/rancher-cni.log && exec tail ---disable-inotify -F /var/log/rancher-cni.log"
    {{- else }}
    command: sh -c "touch /var/log/rancher-cni.log && exec tail ---disable-inotify -F /var/log/rancher-cni.log"
    {{- end }}
    network_mode: host
    pid: host
    labels:
      io.rancher.network.cni.binary: 'rancher-bridge'
      io.rancher.container.dns: 'true'
      io.rancher.scheduler.global: 'true'
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
        - network_address: $SUBNET
          start_address: ${START_ADDRESS}
          end_address: ${END_ADDRESS}
        dns:
        - 169.254.169.250
        dns_search:
        - rancher.internal
      cni_config:
        '10-rancher-flat.conf':
          name: rancher-cni-network
          type: rancher-bridge
          bridge: ${FLAT_BRIDGE}
          bridgeSubnet: ${SUBNET}
          bridgeIP: '__host_interface__: ${FLAT_BRIDGE}'
          logToFile: /var/log/rancher-cni.log
          isDebugLevel: ${RANCHER_DEBUG}
          hairpinMode: {{ .Values.RANCHER_HAIRPIN_MODE }}
          promiscMode: {{ .Values.RANCHER_PROMISCUOUS_MODE }}
          hostNat: {{ .Values.HOST_NAT }}
          mtu: ${MTU}
          ipam:
            type: rancher-cni-ipam
            logToFile: /var/log/rancher-cni.log
            isDebugLevel: ${RANCHER_DEBUG}
            subnetPrefixSize: /${SUBNET_PREFIX_SIZE}
            routes:
            - dst: 0.0.0.0/0
              gw: ${GATEWAY}
            - dst: 169.254.169.250/32
              gw: '__host_interface__: ${FLAT_BRIDGE}'
