#!/bin/bash

set -euo pipefail

read -p "Masukkan jumlah vm yang berjalan: " VM_COUNT
read -p "Masukkan nama instance: " INSTANCE_NAME

RESULT_DIR="/home/sysbench_tests/io_results"
mkdir -p "$RESULT_DIR"

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
CSV_FILE="$RESULT_DIR/fileio_palapa_${TIMESTAMP}_${VM_COUNT}_${INSTANCE_NAME}.csv"

# Workload / concurrency
THREADS=$(nproc)
TEST_TIME=60
ITERATIONS=10

# I/O pattern
BLOCK_SIZE=4K
MODE=rndrw

# Ukuran total file = 2× RAM agar selalu lebih besar dari cache
RAM_MB=$(free -m | awk '/^Mem:/ {print $2}')
TOTAL_SIZE_MB=$(( RAM_MB * 2 ))
TOTAL_SIZE="${TOTAL_SIZE_MB}M"

FILE_NUM=1          # banyak file kecil
RW_RATIO=1
IO_MODE=async
FSYNC_FREQ=0        # flush setiap request (paling realistis)
EXTRA_FLAGS=direct  # bypass cache

echo "iteration,total_time_s,reads_s,writes_s,read_MiB_s,write_MiB_s,avg_lat_ms" > "$CSV_FILE"

echo -e "\nFile uji = $(pwd)"
echo "Tiap iterasi  = $TEST_TIME s"
echo "Threads       = $THREADS"
echo "Mode I/O      = $MODE"
echo "Block         = $BLOCK_SIZE"
echo "fsync         = $FSYNC_FREQ"
echo "CSV output    = $CSV_FILE"
echo "MEM total     = ${RAM_MB} MB ⇒ file_total_size = $TOTAL_SIZE"
echo "──────────────────────────────────────────────────────────────"

########### ─── PREPARE FILE TEST ───────────────────────────────────────
sysbench fileio \
  --file-total-size="$TOTAL_SIZE" \
  --file-num="$FILE_NUM" \
  --file-block-size="$BLOCK_SIZE" \
  --file-test-mode="$MODE" \
  prepare

########### ─── BENCHMARK LOOP ──────────────────────────────────────────
for i in $(seq 1 "$ITERATIONS"); do
    echo -e "\nIterasi $i / $ITERATIONS …"

    OUTPUT=$(sysbench fileio \
      --file-total-size="$TOTAL_SIZE" \
      --file-num="$FILE_NUM" \
      --file-block-size="$BLOCK_SIZE" \
      --file-test-mode="$MODE" \
      --file-io-mode="$IO_MODE" \
      --file-rw-ratio="$RW_RATIO" \
      --file-fsync-freq="$FSYNC_FREQ" \
      --file-extra-flags="$EXTRA_FLAGS" \
      --threads="$THREADS" \
      --time="$TEST_TIME" run)

    # ── parsing hasil ────────────────────────────────────────────
    total_time=$(echo "$OUTPUT" | awk '/total time:/ {print $3}')
    read_fio=$(echo "$OUTPUT" | awk '/reads\/s:/ {print $3}')
    write_fio=$(echo "$OUTPUT" | awk '/writes\/s:/ {print $3}')
    read_throughput=$(echo "$OUTPUT" | awk '/read, MiB\/s:/ {print $3}')
    write_throughput=$(echo "$OUTPUT" | awk '/written, MiB\/s:/ {print $3}')
    avg_lat=$(echo "$OUTPUT" | awk '/avg:/ {print $2}')
    echo "$i,$total_time,$read_throughput,$write_throughput,$avg_lat" >> "$CSV_FILE"
done

########### ─── BERSIH-BERSIH ───────────────────────────────────────────
sysbench fileio --file-total-size="$TOTAL_SIZE" --file-num="$FILE_NUM" cleanup
echo -e "\nBenchmark selesai. Hasil lengkap di: $CSV_FILE"