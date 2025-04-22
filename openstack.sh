#!/bin/bash

sudo useradd -s /bin/bash -d /opt/stack -m stack

sudo chmod +x /opt/stack

echo "stack ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/stack
sudo -u stack -i

git clone https://opendev.org/openstack/devstack
cd devstack

nano local.conf
