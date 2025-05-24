#!/bin/bash
set -euo pipefail

# Membaca input dari pengguna
# Input memasukkan lokasi penyimpanan hasil
read -p "Masukkan lokasi penyimpanan hasil (default: /home/iperf3-results/client): " RESULT_DIR
read -p "Masukkan IP Virtual Machine Palapa: " SERVER_IP

# Jika pengguna tidak memasukkan lokasi penyimpanan, gunakan default
if [ -z "$RESULT_DIR" ]; then
  RESULT_DIR="/home/iperf3-results/client" # Lokasi penyimpanan default
fi

#RESULT_DIR="/home/iperf3/" # Lokasi penyimpanan
mkdir -p "$RESULT_DIR"

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
CSV_RESULT="$RESULT_DIR/iperf3_client_$TIMESTAMP.csv"

# Konfigurasi
#SERVER_IP="" # IP Virtual Machine Palapa
DURATION=10
ITERATIONS=1 # Iterasi

echo "Creating results file: $CSV_RESULT"
echo "iteration,interval,sender_transfer,sender_bitrate,retrans,receiver_transfer,receiver_bitrate" > "$CSV_RESULT"

for i in $(seq 1 "$ITERATIONS"); do
  echo "Running iperf3 test iteration $i…"

  # Jalankan iperf3 sekali; ambil outputnya ke variabel
  OUTPUT=$(iperf3 -c "$SERVER_IP" -t "$DURATION")

  # Baris summary sender & receiver
  sender_line=$(echo "$OUTPUT" | grep 'sender')
  receiver_line=$(echo "$OUTPUT" | grep 'receiver')

  # --- parsing sender ---
  interval=$(echo "$sender_line" | awk '{print $3}')
  sender_transfer=$(echo "$sender_line" | awk '{print $5 " " $6}')
  sender_bitrate=$(echo "$sender_line" | awk '{print $7 " " $8}')
  sender_retrans=$(echo "$sender_line" | awk '{print $(NF-1)}')

  # --- parsing receiver ---
  receiver_transfer=$(echo "$receiver_line" | awk '{print $5 " " $6}')
  receiver_bitrate=$(echo "$receiver_line" | awk '{print $7 " " $8}')

  # Simpan ke CSV
  echo "$i,$interval,$sender_transfer,$sender_bitrate,$sender_retrans,$receiver_transfer,$receiver_bitrate" >> "$CSV_RESULT"
done

echo "Hasil disimpan di: $CSV_RESULT"
