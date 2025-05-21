#!/bin/bash

# Fungsi untuk ping di background
function check_ping() {
    local target=$1
    if ping -c 3 "$target" &> /dev/null; then
        echo "ping $target sukses"
    else
        echo "ping $target gagal"
        unset http_proxy && unset https_proxy && unset ftp_proxy && rm -f /etc/environment
    fi
}

# Jalankan ping di background
check_ping 8.8.8.8 &
check_ping github.com &

# Tunggu semua background ping selesai
wait

# fix yum proxy

sed -i 's/^proxy=.*/proxy=_none_/' /etc/yum.conf

# fix centos repo

sudo sed -i s/mirror.centos.org/vault.centos.org/g /etc/yum.repos.d/*.repo
sudo sed -i s/^#.*baseurl=http/baseurl=http/g /etc/yum.repos.d/*.repo
sudo sed -i s/^mirrorlist=http/#mirrorlist=http/g /etc/yum.repos.d/*.repo
sudo -- bash -c 'echo "sslverify=false" >> /etc/yum.conf'

# install iperf3

yum install -y iperf3

# install sysbench

curl -s https://packagecloud.io/install/repositories/akopytov/sysbench/script.rpm.sh | sudo bash
sudo yum -y install sysbench

# done