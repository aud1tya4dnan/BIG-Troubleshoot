#!/bin/bash

echo "=== STEP17 =================================================================="
echo "Jika ingin merubah password default user/admin palapa, tekan Y,"
echo "jika tidak, tekan ENTER untuk selesai"
read enter
if [[ -n "$enter" ]]; then
    echo "Masukkan password baru:"
    read -s pass1
    echo "Masukkan password baru sekali lagi:"
    read -s pass2
    if [[ $pass1 == $pass2 ]]; then
        su postgres -c "psql -d palapa -c \"ALTER USER palapa WITH PASSWORD '${pass1}'\"" > /dev/null 2
        su postgres -c "psql -d palapa -c \"UPDATE public.users SET password = 'plain:${pass1}' WHERE name = 'palapa'\"" > /dev/null 2
        current_step="STEP18"
    fi
    if [[ $pass1 != $pass2 ]]; then
        echo "Password tidak sama"
    fi
fi
if [[ -z "$enter" ]]; then
    current_step="STEP18"
fi