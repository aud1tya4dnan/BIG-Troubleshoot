#!/bin/bash

# Fungsi untuk ping di background
function check_ping() {
    local target=$1
    if ping -c 3 "$target" &> /dev/null; then
        echo "ping $target sukses"
    else
        echo "ping $target gagal"
    fi
}

# Jalankan ping di background
check_ping 8.8.8.8 &
check_ping github.com &

# Tunggu semua background ping selesai
wait

# Daftar file yang akan disalin
files=("migratevm_new_modif.sh" "chpass.sh" "hosts")

# Salin file ke /home jika ada
for file in "${files[@]}"; do
    if [[ -f "$file" ]]; then
        cp "$file" /home
    else
        echo "File $file tidak ditemukan."
    fi
done

# Masuk ke direktori /home
cd /home || { echo "Gagal masuk ke /home"; exit 1; }

# Unset proxy
unset http_proxy
unset https_proxy

# Beri permission dan jalankan script
chmod +rx *.sh

# Eksekusi script utama jika ada
if [[ -f "migratevm_new_modif.sh" ]]; then
    ./migratevm_new_modif.sh
else
    echo "Script migratevm_new_modif.sh tidak ditemukan di /home"
    exit 1
fi
