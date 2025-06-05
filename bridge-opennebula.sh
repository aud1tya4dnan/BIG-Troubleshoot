#!/bin/bash

echo "
network:
  version: 2
  renderer: networkd
  ethernets:
    eth0: {}
  bridges:
    br0:
      interfaces: [eth0]
      dhcp4: false
        addresses: 10.4.89.10/24
        nameservers:
          addresses: 
            - 103.94.188.3
        routes:
            - to: default
                via: 10.4.89.1

" >> /etc/netplan/01-netcfg.yaml

mv /etc/netplan/50-cloud-init.yaml /etc/netplan/50-cloud-init.yaml.bak

netplan apply