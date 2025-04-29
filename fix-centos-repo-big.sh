#!/bin/bash

sudo sed -i s/mirror.centos.org/vault.centos.org/g /etc/yum.repos.d/*.repo
sudo sed -i s/^#.*baseurl=http/baseurl=http/g /etc/yum.repos.d/*.repo
sudo sed -i s/^mirrorlist=http/#mirrorlist=http/g /etc/yum.repos.d/*.repo
sudo -- bash -c 'echo "sslverify=false" >> /etc/yum.conf'

#source
#https://medium.com/@bonguides25/fix-http-error-404-not-found-trying-other-mirror-centos-7-1600e862644c
