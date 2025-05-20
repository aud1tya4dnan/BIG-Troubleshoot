#!/bin/bash

installer_dir=$(pwd)
echo "=== MIGRATE MESIN =========================================================="
echo "Direktori installer adalah ${installer_dir}"
echo "============================================================================"
echo "Berikut ini adalah IP mesin ini (bisa > 1)"
ip a | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p'
echo "----------------------------------------------------------------------------"
echo "Bila > 1, tentukan IP yang dapat ditemukan melalui internet (IP publik)."
echo "Bila hanya satu, masukkan IP tersebut di bawah."
echo "IP publik mesin ini:"
read ip_publik
echo "----------------------------------------------------------------------------"
echo "Bila masin ini memiliki domain, masukkan di bawah, jika tidak kosongkan dan"
echo "tekan ENTER"
echo "Nama domain mesin ini:"
read domain_publik
if [[ -z "$domain_publik" ]]; then
    echo "----------------------------------------------------------------------------"
    echo "IP mesin: $ip_publik"
    echo "Domain:   Kosong/Tidak Ada"
elif [[ -n "$domain_publik" ]]; then
    echo "----------------------------------------------------------------------------"
    echo "IP mesin: $ip_publik"
    echo "Domain:   $domain_publik"
fi
echo "----------------------------------------------------------------------------"
echo "Perhatikan hasil di atas, bila ada kesalahan/error tekan CTRL+C, "
echo "bila tidak tekan ENTER"
read enter
if [[ -z "$enter" ]]; then
    echo "$ip_publik" > $installer_dir/ip.tmp
    echo "$domain_publik" >> $installer_dir/domain.tmp
fi

cd /opt/source/palapa-frontend/src/config/
if [[ -z "$domain_publik" ]]; then
    sed -i "1s/.*/const host = 'http:\/\/${ip_publik}';/" /opt/source/palapa-frontend/src/config/index.js
    sed -i "2s/.*/    var base_url = 'http:\/\/${ip_publik}'/" /opt/source/palapa-frontend/public/jelajah/js/config.js
elif [[ -n "$domain_publik" ]]; then
    sed -i "1s/.*/const host = 'http:\/\/${domain_publik}';/" /opt/source/palapa-frontend/src/config/index.js
    sed -i "2s/.*/    var base_url = 'http:\/\/${domain_publik}'/" /opt/source/palapa-frontend/public/jelajah/js/config.js
fi
cd /opt/source/palapa-frontend/
npm audit fix
npm install
npm run build
RANDOM=1
mv /var/www/html/palapa/ /var/www/html/palapa.${RANDOM}/
cp -r -f /opt/source/palapa-frontend/build/ /var/www/html/palapa/

cd /opt/gspalapa-api
if [[ -z "$domain_publik" ]]; then
    sed -i "21s/.*/GEOSERVER_WMS_OUT = 'http:\/\/${ip_publik}\/geoserver\/wms?'/" cfg.py
    sed -i "22s/.*/GEOSERVER_WFS_OUT = 'http:\/\/${ip_publik}\/geoserver\/wms?'/" cfg.py
elif [[ -n "$domain_publik" ]]; then
    sed -i "21s/.*/GEOSERVER_WMS_OUT = 'http:\/\/${domain_publik}\/geoserver\/wms?'/" cfg.py
    sed -i "22s/.*/GEOSERVER_WFS_OUT = 'http:\/\/${domain_publik}\/geoserver\/wms?'/" cfg.py
fi

cd /var/www/html/gspalapa/
if [[ -z "$domain_publik" ]]; then
    sed -i "2s/.*/var baseAPIURL = 'http:\/\/${ip_publik}\/api\/';/" /var/www/html/gspalapa/js/cfg.js
    sed -i "4s/.*/var baseGSURL = 'http:\/\/${ip_publik}\/geoserver\/wms';/" /var/www/html/gspalapa/js/cfg.js
elif [[ -n "$domain_publik" ]]; then
    sed -i "2s/.*/var baseAPIURL = 'http:\/\/${domain_publik}\/api\/';/" /var/www/html/gspalapa/js/cfg.js
    sed -i "4s/.*/var baseGSURL = 'http:\/\/${domain_publik}\/geoserver\/wms';/" /var/www/html/gspalapa/js/cfg.js
fi

echo "----------------------------------------------------------------------------"
echo "Menset hostname"
mv /etc/hosts $installer_dir/hosts.backup
cp $installer_dir/hosts /etc/
if [[ -z "$domain_publik" ]]; then
    echo " "
elif [[ -n "$domain_publik" ]]; then
    sed -i "$ a\127.0.0.1   ${domain_publik}" /etc/hosts
fi
echo "----------------------------------------------------------------------------"

echo "------------------------Migrasi Pycsw------------------------------"
echo "Menseting pycsw"
mv /opt/pycsw-2.0/pycsw/default.cfg /opt/pycsw-2.0/pycsw/_backup_default.cfg
cd /opt/pycsw-2.0/pycsw/
cp default-sample.cfg default.cfg
sed -ie "s/home=\/var\/www\/pycsw/home=\/opt\/pycsw-2.0\/pycsw/g" /opt/pycsw-2.0/pycsw/default.cfg
if [[ -z "$domain_publik" ]]; then
    sed -ie "s/url=http:\/\/localhost\/pycsw\/csw.py/url=http:\/\/127.0.0.1\/csw/g" /opt/pycsw-2.0/pycsw/default.cfg
elif [[ -n "$domain_publik" ]]; then
    sed -ie "s/url=http:\/\/localhost\/pycsw\/csw.py/url=http:\/\/${domain_publik}\/csw/g" /opt/pycsw-2.0/pycsw/default.cfg
fi
sed -ie "s/transactions=false/transactions=true/g" /opt/pycsw-2.0/pycsw/default.cfg
sed -ie "s/allowed_ips=127.0.0.1/allowed_ips=127.0.0.1,${ip_publik}/g" /opt/pycsw-2.0/pycsw/default.cfg
sed -ie "s/database=sqlite:\/\/\/\/var\/www\/pycsw\/tests\/suites\/cite\/data\/cite.db/#database=sqlite:\/\/\/\/var\/www\/pycsw\/tests\/suites\/cite\/data\/cite.db/g" /opt/pycsw-2.0/pycsw/default.cfg
sed -ie "s/#database=postgresql:\/\/username:password@localhost\/pycsw/database=postgresql:\/\/syspalapa:sysp4l4p4@127.0.0.1\/palapa/g" /opt/pycsw-2.0/pycsw/default.cfg
sed -ie "s/table=records/table=metadata/g" /opt/pycsw-2.0/pycsw/default.cfg
echo "------------------Setup Ulang CFG------------------------------"
cd /opt/pycsw-2.0/pycsw/
pycsw-admin.py -c setup_db -f default.cfg
echo "----------------------------------------------------------------------------"
echo "Restarting services"
systemctl restart tomcat
systemctl restart httpd
systemctl restart gs-api
echo "----------------------------------------------------------------------------"
echo "DONE."
echo "----------------------------------------------------------------------------"
