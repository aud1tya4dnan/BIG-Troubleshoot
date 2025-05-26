#!/bin/bash
set -euo pipefail

read -p "Masukkan lokasi penyimpanan hasil (default: /home/iperf3-results/server): " RESULT_DIR
read -p "Masukan Tipe Test(Internal/External): " TEST_TYPE

# Jika pengguna tidak memasukkan lokasi penyimpanan, gunakan default
if [ -z "$RESULT_DIR" ]; then
  RESULT_DIR="/home/iperf3-results/server" # Lokasi penyimpanan default
fi

# Output directory dan file
mkdir -p "$RESULT_DIR"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
CSV_FILE="$RESULT_DIR/iperf3_server_$TIMESTAMP.csv"
TMP_OUTPUT="$RESULT_DIR/${TEST_TYPE}iperf3_raw_$TIMESTAMP.log"

# Fungsi cleanup dan parsing saat Ctrl+C
function cleanup() {
  echo -e "\nMenangkap output dan menyimpan hasil ke CSV..."

  # Header CSV
  echo "Interval,Transfer,Bandwidth" > "$CSV_FILE"

  OUTPUT=$(cat "$TMP_OUTPUT")
  # Parsing output iperf3
  while IFS= read -r line; do
    if [[ $line == *"receiver"* ]]; then
        interval=$(echo "$line" | awk '{print $3}')
        transfer=$(echo "$line" | awk '{print $5 " " $6}')
        bandwidth=$(echo "$line" | awk '{print $7 " " $8}')
        echo "$interval,$transfer,$bandwidth" >> "$CSV_FILE"
  fi
  done <<< "$OUTPUT"
  echo "Hasil disimpan di: $CSV_FILE"
  rm -f "$TMP_OUTPUT" # Hapus file sementara
  exit 0
}

# Trap Ctrl+C
trap cleanup SIGINT

echo "Menunggu koneksi dari klien..."
# Jalankan iperf3 sebagai server dan simpan output
iperf3 -s > "$TMP_OUTPUT"
